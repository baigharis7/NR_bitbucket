import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/view/health_sync_settings_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/privacy/view/policy_screen.dart';
import 'package:nutrenaissance_flutter/presentation/settings/bloc/settings_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/settings/view/settings_screen.dart';

import '../bloc/bloc_test_mocks.mocks.dart';
import 'test_navigation_helpers.dart';

/// Full-screen navigation tests for [SettingsScreen]. Real [SettingsBloc] is
/// instantiated with mocked interactors; the screen is wrapped in a
/// [BlocProvider] above [MaterialApp] so [BlocProvider.of] resolves correctly.
void main() {
  late MockSignOutInteractor mockSignOut;
  late MockEraseDatabaseInteractor mockEraseDb;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockSignOut = MockSignOutInteractor();
    mockEraseDb = MockEraseDatabaseInteractor();
    mockPrefs = MockSharedPreferences();
  });

  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      FlutterError.presentError(details);
    };
  });
  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  Widget buildHarness(NavRecorder recorder) {
    final bloc = SettingsBloc(
      signOutInteractor: mockSignOut,
      eraseDatabaseInteractor: mockEraseDb,
      sharedPreferences: mockPrefs,
    );
    return BlocProvider<SettingsBloc>.value(
      value: bloc,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        // Stub destination routes so taps don't fail to push.
        routes: {
          HealthSyncSettingsScreen.routeName: (_) =>
              Scaffold(key: Key('stub:${HealthSyncSettingsScreen.routeName}'), body: const Text('health-sync')),
          PolicyScreen.routeName: (_) =>
              Scaffold(key: Key('stub:${PolicyScreen.routeName}'), body: const Text('policy')),
          LoginScreen.routeName: (_) =>
              Scaffold(key: Key('stub:${LoginScreen.routeName}'), body: const Text('login')),
        },
        navigatorObservers: [recorder],
        home: const SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen navigation', () {
    testWidgets('renders all menu sections', (tester) async {
      setPhoneSurface(tester, size: const Size(500, 1000));
      await tester.pumpWidget(buildHarness(NavRecorder()));
      await tester.pumpAndSettle();

      // Section headers + items
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(find.textContaining('Health'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Privacy'), findsOneWidget);
    });

    testWidgets('Health Sync menu tap navigates to HealthSyncSettingsScreen',
        (tester) async {
      setPhoneSurface(tester, size: const Size(500, 1000));
      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      // l10n value health_sync_enable_link → "Enable Health Data Sync"
      await tester.tap(find.text('Enable Health Data Sync'));
      await tester.pumpAndSettle();

      expectNavigated(recorder, HealthSyncSettingsScreen.routeName);
    });

    testWidgets('Privacy Policy menu tap navigates to PolicyScreen',
        (tester) async {
      setPhoneSurface(tester, size: const Size(500, 1000));
      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      // l10n value privacy_polic → "Privacy policy"
      await tester.tap(find.text('Privacy policy'));
      await tester.pumpAndSettle();

      expectNavigated(recorder, PolicyScreen.routeName);
    });

    testWidgets('Log Out menu tap fires SettingsLogOut on bloc',
        (tester) async {
      setPhoneSurface(tester, size: const Size(500, 1000));
      // Stub the sign out chain. SignOutResult comes from amplify_core; an
      // exception inside the bloc's try is caught and set onError, but the
      // tap-wiring is what we want to verify here.
      when(mockSignOut.execute()).thenThrow(Exception('stubbed'));

      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log out'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // The tap fired the bloc action, which invoked the sign-out interactor.
      verify(mockSignOut.execute()).called(1);
    });

    testWidgets('close icon pops the screen', (tester) async {
      setPhoneSurface(tester, size: const Size(500, 1000));
      // Wrap SettingsScreen in a parent with its own home so we can check pop
      var popped = false;
      final bloc = SettingsBloc(
        signOutInteractor: mockSignOut,
        eraseDatabaseInteractor: mockEraseDb,
        sharedPreferences: mockPrefs,
      );
      await tester.pumpWidget(BlocProvider<SettingsBloc>.value(
        value: bloc,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ).then((_) => popped = true);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // We are now on Settings — find and tap the close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });
}
