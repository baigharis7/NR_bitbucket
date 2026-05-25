import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/diet_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/general_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/health_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/physical_activity_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/view/profile_screen.dart';
import 'package:nutrenaissance_flutter/presentation/settings/view/settings_screen.dart';

import '../bloc/bloc_test_mocks.mocks.dart';
import 'test_navigation_helpers.dart';

/// Full-screen navigation tests for [ProfileScreen]. The bloc is real with
/// mocked interactors that return empty/minimal master data so the screen
/// renders without exceptions, then we verify each "edit" tile navigates
/// to the correct profile sub-screen.
void main() {
  late MockGetProfileInteractor mockGetProfile;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockGetUserIdInteractor mockGetUserId;
  late MockUploadProfileInteractor mockUploadProfile;
  late MockSaveProfileInteractor mockSaveProfile;
  late MockSignOutInteractor mockSignOut;
  late MockEraseDatabaseInteractor mockEraseDb;
  late MockClearAuthPreferencesInteractor mockClearAuth;

  setUpAll(() {
    // Profile bloc init calls helpers like Allergens.listAllAllergens which
    // use the localizations helper singleton. Initialize once.
    AppLocalizationsHelperDelegate.instance =
        AppLocalizationsHelper(const Locale('en'));
  });

  setUp(() {
    mockGetProfile = MockGetProfileInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockUploadProfile = MockUploadProfileInteractor();
    mockSaveProfile = MockSaveProfileInteractor();
    mockSignOut = MockSignOutInteractor();
    mockEraseDb = MockEraseDatabaseInteractor();
    mockClearAuth = MockClearAuthPreferencesInteractor();

    when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel.empty());
    when(mockGetUserId.execute()).thenReturn('user123');
    when(mockGetMasterFile.execute(MasterFilesType.objectivesInfo)).thenAnswer(
        (_) async => ObjectivesInfoMaster(
              objectives: const [],
              metabolicObjectives: const [],
              bodyCompositionObjectives: const [],
            ));
    when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
        .thenAnswer((_) async => FoodsAndDrinksNamesMaster(
              FoodsAndDrinkListsMaster(foodNames: [], drinkNames: []),
            ));
    when(mockGetMasterFile.execute(MasterFilesType.recommendationGroups))
        .thenAnswer((_) async => RecommendationGroupsMaster(recommendationGroups: const []));
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
    final bloc = ProfileBloc(
      getProfileInteractor: mockGetProfile,
      getMasterFileInteractor: mockGetMasterFile,
      getUserIdInteractor: mockGetUserId,
      uploadProfileInteractor: mockUploadProfile,
      saveProfileInteractor: mockSaveProfile,
      signOutInteractor: mockSignOut,
      eraseDatabaseInteractor: mockEraseDb,
      clearAuthPreferencesInteractor: mockClearAuth,
    );
    return BlocProvider<ProfileBloc>.value(
      value: bloc,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        // Stub destination routes
        routes: {
          SettingsScreen.routeName: (_) => Scaffold(
                key: Key('stub:${SettingsScreen.routeName}'),
                body: const Text('settings'),
              ),
          GeneralQuestionsScreen.routeName: (_) => Scaffold(
                key: Key('stub:${GeneralQuestionsScreen.routeName}'),
                body: const Text('general'),
              ),
          HealthQuestionsScreen.routeName: (_) => Scaffold(
                key: Key('stub:${HealthQuestionsScreen.routeName}'),
                body: const Text('health'),
              ),
          DietQuestionsScreen.routeName: (_) => Scaffold(
                key: Key('stub:${DietQuestionsScreen.routeName}'),
                body: const Text('diet'),
              ),
          PhysicalActivityScreen.routeName: (_) => Scaffold(
                key: Key('stub:${PhysicalActivityScreen.routeName}'),
                body: const Text('pa'),
              ),
          ObjectivesProfileScreen.routeName: (_) => Scaffold(
                key: Key('stub:${ObjectivesProfileScreen.routeName}'),
                body: const Text('objectives'),
              ),
        },
        navigatorObservers: [recorder],
        home: const ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen navigation', () {
    testWidgets('Settings icon navigates to SettingsScreen', (tester) async {
      setPhoneSurface(tester, size: const Size(800, 1600));
      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      // Settings icon is in the trailing of ScreenTopBar
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expectNavigated(recorder, SettingsScreen.routeName);
    });

    testWidgets('Update goals tap navigates to ObjectivesProfileScreen',
        (tester) async {
      setPhoneSurface(tester, size: const Size(800, 1600));
      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      // Scroll to find "Update goals" if needed and tap it
      final updateGoals = find.text('Update goals');
      await tester.scrollUntilVisible(updateGoals, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(updateGoals);
      await tester.pumpAndSettle();

      expectNavigated(recorder, ObjectivesProfileScreen.routeName);
    });

    testWidgets('Medical history tile navigates to HealthQuestionsScreen',
        (tester) async {
      setPhoneSurface(tester, size: const Size(800, 1600));
      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      final tile = find.text('Medical history');
      await tester.scrollUntilVisible(tile, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(tile);
      await tester.pumpAndSettle();

      expectNavigated(recorder, HealthQuestionsScreen.routeName);
    });

    testWidgets('Diet tile navigates to DietQuestionsScreen',
        (tester) async {
      setPhoneSurface(tester, size: const Size(800, 1600));
      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      final tile = find.text('Diet');
      await tester.scrollUntilVisible(tile, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(tile);
      await tester.pumpAndSettle();

      expectNavigated(recorder, DietQuestionsScreen.routeName);
    });

    testWidgets('Physical Activity tile navigates to PhysicalActivityScreen',
        (tester) async {
      setPhoneSurface(tester, size: const Size(800, 1600));
      final recorder = NavRecorder();
      await tester.pumpWidget(buildHarness(recorder));
      await tester.pumpAndSettle();

      final tile = find.text('Physical Activity');
      await tester.scrollUntilVisible(tile, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(tile);
      await tester.pumpAndSettle();

      expectNavigated(recorder, PhysicalActivityScreen.routeName);
    });
  });
}
