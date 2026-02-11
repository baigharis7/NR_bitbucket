import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrenaissance_flutter/presentation/settings/bloc/settings_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockSignOutInteractor mockSignOut;
  late MockEraseDatabaseInteractor mockEraseDb;
  late SharedPreferences sharedPrefs;

  setUp(() async {
    mockSignOut = MockSignOutInteractor();
    mockEraseDb = MockEraseDatabaseInteractor();
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  SettingsBloc _buildBloc() => SettingsBloc(
        signOutInteractor: mockSignOut,
        eraseDatabaseInteractor: mockEraseDb,
        sharedPreferences: sharedPrefs,
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
  });
}
