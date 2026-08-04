import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/domain/interactor/eventssync/synchronize_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/presentation/splash/provider/splash_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSynchronizeEventsInteractor extends Mock
    implements SynchronizeEventsInteractor {}

class _MockGetProfileInteractor extends Mock implements GetProfileInteractor {}

class _MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

/// Launch path of the splash screen.
///
/// Apple rejected builds 239-243 under Guideline 2.1(a) — "failed to load any
/// content at launch" — on a review device with no cellular service. The cause
/// was network-dependent initialization in `main()` before `runApp()`, fixed in
/// April 2026 by `2f6762a7`, which guarantees the splash paints. It did not
/// guarantee the app gets *past* the splash: `SplashProvider.init` awaited the
/// event sync, and `ApiHelper` sets no request timeout, so a connection that
/// hangs rather than failing held the splash for as long as the OS socket did.
/// A try/catch cannot catch a hang, only an error.
///
/// These tests pin the invariant that closes that gap: nothing on the launch
/// path may block navigation on the network. The first test fails against the
/// awaited version of the code.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'cognito-sub-under-test';

  late _MockSynchronizeEventsInteractor synchronizeEvents;
  late _MockGetProfileInteractor getProfile;
  late _MockLocalStorageRepository localStorage;
  late SplashProvider provider;

  int toLoginCalls = 0;
  int toDashboardCalls = 0;

  /// Runs `init` and drains the microtask queue. `init` is `void async`, so it
  /// cannot be awaited — draining is what lets its completed futures settle.
  Future<void> runInit() async {
    provider.init(
      toLogin: () => toLoginCalls++,
      toDashboard: () => toDashboardCalls++,
    );
    await pumpEventQueue();
  }

  setUp(() {
    // `sub` is the key GetUserIdInteractor reads (PrefsKeys.sub).
    SharedPreferences.setMockInitialValues({'sub': userId});

    synchronizeEvents = _MockSynchronizeEventsInteractor();
    getProfile = _MockGetProfileInteractor();
    localStorage = _MockLocalStorageRepository();

    toLoginCalls = 0;
    toDashboardCalls = 0;

    provider = SplashProvider.withCollaborators(
      synchronizeEvents: synchronizeEvents,
      getProfile: getProfile,
      localStorage: localStorage,
    );
  });

  void givenCompleteProfile({String? profileUserId = userId}) {
    when(() => getProfile.execute()).thenAnswer(
      (_) async => UserProfileModel(userId: profileUserId, objectives: [1]),
    );
  }

  group('event sync must not block navigation', () {
    test('reaches the dashboard while the sync is still hanging', () async {
      // A network that accepts the connection and never answers: the future
      // never completes and never throws. This is the reviewer's condition.
      final hangingSync = Completer<void>();
      addTearDown(() => hangingSync.complete());
      when(() => synchronizeEvents.execute(any(),
          fullSync: any(named: 'fullSync'))).thenAnswer(
        (_) => hangingSync.future,
      );
      givenCompleteProfile();

      await runInit();

      expect(toDashboardCalls, 1,
          reason: 'a hanging sync must not hold the splash');
      expect(toLoginCalls, 0);
      expect(hangingSync.isCompleted, isFalse,
          reason: 'the sync is still in flight — navigation did not wait');
    });

    test('still starts the sync (fire and forget, not dropped)', () async {
      final hangingSync = Completer<void>();
      addTearDown(() => hangingSync.complete());
      when(() => synchronizeEvents.execute(any(),
          fullSync: any(named: 'fullSync'))).thenAnswer(
        (_) => hangingSync.future,
      );
      givenCompleteProfile();

      await runInit();

      verify(() => synchronizeEvents.execute(userId, fullSync: false))
          .called(1);
    });

    test('reaches the dashboard when the sync fails outright', () async {
      // Airplane mode: DNS fails immediately, so the future rejects. The
      // unawaited future must not surface as an unhandled async error either.
      when(() => synchronizeEvents.execute(any(),
              fullSync: any(named: 'fullSync')))
          .thenAnswer((_) async => throw const SocketExceptionStub());
      givenCompleteProfile();

      await runInit();

      expect(toDashboardCalls, 1);
      expect(toLoginCalls, 0);
    });
  });

  group('profile gating is unchanged', () {
    setUp(() {
      when(() => synchronizeEvents.execute(any(),
          fullSync: any(named: 'fullSync'))).thenAnswer((_) async {});
    });

    test('goes to login when the stored profile has no objectives', () async {
      when(() => getProfile.execute())
          .thenAnswer((_) async => UserProfileModel(userId: userId));

      await runInit();

      expect(toLoginCalls, 1);
      expect(toDashboardCalls, 0);
    });

    test('wipes local data and goes to login on a userId mismatch', () async {
      givenCompleteProfile(profileUserId: 'a-different-cognito-sub');
      when(() => localStorage.eraseDatabaseInformation())
          .thenAnswer((_) async => true);

      await runInit();

      verify(() => localStorage.eraseDatabaseInformation()).called(1);
      expect(toLoginCalls, 1);
      expect(toDashboardCalls, 0);
    });
  });
}

/// Stand-in for a transport failure. A real `SocketException` would pull in
/// `dart:io`, which this test does not otherwise need.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();

  @override
  String toString() => 'SocketExceptionStub: no route to host';
}
