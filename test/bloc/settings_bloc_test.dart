import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/fcm_service.dart';
import 'package:nutrenaissance_flutter/presentation/settings/bloc/settings_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockSignOutInteractor mockSignOut;
  late MockEraseDatabaseInteractor mockEraseDb;
  late MockFcmApi mockFcmApi;
  late SharedPreferences sharedPrefs;

  setUp(() async {
    mockSignOut = MockSignOutInteractor();
    mockEraseDb = MockEraseDatabaseInteractor();
    mockFcmApi = MockFcmApi();
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  tearDown(() {
    FcmService.instance.tokenForTesting = null;
  });

  SettingsBloc _buildBloc({bool withFcm = false}) => SettingsBloc(
        signOutInteractor: mockSignOut,
        eraseDatabaseInteractor: mockEraseDb,
        sharedPreferences: sharedPrefs,
        fcmApi: withFcm ? mockFcmApi : null,
      );

  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'initial state has isLoading false',
      build: _buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.onError, isNull);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'SettingsLogOut success emits loading true then false',
      build: () {
        when(mockEraseDb.execute()).thenAnswer((_) async => true);
        return _buildBloc();
      },
      act: (bloc) => bloc.add(SettingsLogOut(goToLogin: () {})),
      expect: () => [
        isA<SettingsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<SettingsState>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'SettingsLogOut success calls goToLogin callback',
      build: () {
        when(mockEraseDb.execute()).thenAnswer((_) async => true);
        return _buildBloc();
      },
      act: (bloc) {
        bool goToLoginCalled = false;
        bloc.add(SettingsLogOut(goToLogin: () => goToLoginCalled = true));
        return Future.delayed(
          const Duration(milliseconds: 100),
          () => expect(goToLoginCalled, isTrue),
        );
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'SettingsLogOut error does not call goToLogin',
      build: () {
        when(mockSignOut.execute()).thenThrow(Exception('sign out failed'));
        return _buildBloc();
      },
      act: (bloc) {
        bool goToLoginCalled = false;
        bloc.add(SettingsLogOut(goToLogin: () => goToLoginCalled = true));
        return Future.delayed(
          const Duration(milliseconds: 100),
          () => expect(goToLoginCalled, isFalse),
        );
      },
      expect: () => [
        isA<SettingsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<SettingsState>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    group('logout sequencing — local clears must complete before nav', () {
      // Regression guard: previously dashboard_bloc and profile_bloc logout
      // were fire-and-forget, so navigation happened while the Hive clear
      // was still running. The next account opened to see User A's data.
      // settings_bloc was the only correct path. Now all three await
      // eraseDatabase + prefs.clear before calling goToLogin.

      blocTest<SettingsBloc, SettingsState>(
        'goToLogin is NOT called before eraseDatabase completes',
        build: () {
          // Make eraseDatabase take a measurable amount of time so the
          // race window is observable.
          when(mockEraseDb.execute()).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 80));
            return true;
          });
          return _buildBloc();
        },
        act: (bloc) async {
          var goToLoginCalledAt = -1;
          final stopwatch = Stopwatch()..start();
          bloc.add(SettingsLogOut(goToLogin: () {
            goToLoginCalledAt = stopwatch.elapsedMilliseconds;
          }));
          // Wait for the bloc to finish processing.
          await Future.delayed(const Duration(milliseconds: 200));
          // Must be at least 80ms (the erase delay) before goToLogin fires.
          // Use 70 as the threshold to allow a few ms of jitter.
          expect(goToLoginCalledAt, greaterThanOrEqualTo(70),
              reason: 'goToLogin fired before eraseDatabase finished — '
                  'this is the fire-and-forget regression we are guarding against');
        },
      );
    });

    group('FCM token unregister on logout', () {
      blocTest<SettingsBloc, SettingsState>(
        'unregisters FCM token before sign-out',
        build: () {
          FcmService.instance.tokenForTesting = 'test-token';
          when(mockFcmApi.unregisterToken('test-token'))
              .thenAnswer((_) async {});
          when(mockEraseDb.execute()).thenAnswer((_) async => true);
          return _buildBloc(withFcm: true);
        },
        act: (bloc) => bloc.add(SettingsLogOut(goToLogin: () {})),
        verify: (_) {
          verify(mockFcmApi.unregisterToken('test-token')).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'logout proceeds when unregisterToken fails',
        build: () {
          FcmService.instance.tokenForTesting = 'test-token';
          when(mockFcmApi.unregisterToken('test-token'))
              .thenThrow(Exception('network error'));
          when(mockEraseDb.execute()).thenAnswer((_) async => true);
          return _buildBloc(withFcm: true);
        },
        act: (bloc) => bloc.add(SettingsLogOut(goToLogin: () {})),
        expect: () => [
          isA<SettingsState>().having((s) => s.isLoading, 'isLoading', true),
          isA<SettingsState>().having((s) => s.isLoading, 'isLoading', false),
        ],
      );
    });
  });
}
