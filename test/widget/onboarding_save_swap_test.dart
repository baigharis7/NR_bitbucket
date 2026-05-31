import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mocktail/mocktail.dart' as mt;
import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/view/health_sync_onboarding_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/general_questions_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/common/objectives_screen.dart';
import 'package:nutrenaissance_flutter/presentation/profile/profile/bloc/profile_bloc.dart';

import '../bloc/bloc_test_mocks.mocks.dart';
import 'test_navigation_helpers.dart';

// MockBloc + whenListen come from bloc_test (built on mocktail);
// the interactor mocks are mockito-generated.
class _MockHealthSyncBloc
    extends MockBloc<HealthSyncEvent, HealthSyncState>
    implements HealthSyncBloc {}

class _FakeHealthSyncEvent extends mt.Fake implements HealthSyncEvent {}

UserProfileResponse _successResponse() => UserProfileResponse(
      uploadSuccess: true,
      micronutrients: const [],
      userAll: const [],
      temporaryMicronutrients: const [],
      temporaryAll: const [],
      userRdas: const [],
      kcal: 2000,
    );

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
    AppLocalizationsHelperDelegate.instance =
        AppLocalizationsHelper(const Locale('en'));
    mt.registerFallbackValue(_FakeHealthSyncEvent());
    mt.registerFallbackValue(HealthSyncState());
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

    when(mockGetProfile.execute())
        .thenAnswer((_) async => UserProfileModel.empty());
    when(mockGetUserId.execute()).thenReturn('user123');
    when(mockGetMasterFile.execute(MasterFilesType.objectivesInfo)).thenAnswer(
      (_) async => ObjectivesInfoMaster(
        objectives: [
          ObjectiveInfoMaster(id: 1, en: 'Obj 1', es: 'Obj 1'),
        ],
        metabolicObjectives: const [],
        bodyCompositionObjectives: const [],
      ),
    );
    when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
        .thenAnswer((_) async => FoodsAndDrinksNamesMaster(
              FoodsAndDrinkListsMaster(foodNames: [], drinkNames: []),
            ));
    when(mockGetMasterFile.execute(MasterFilesType.recommendationGroups))
        .thenAnswer((_) async =>
            RecommendationGroupsMaster(recommendationGroups: const []));

    // FinishProfileAction's success path: upload returns uploadSuccess=true,
    // then save (void) completes.
    when(mockUploadProfile.execute(any))
        .thenAnswer((_) async => _successResponse());
    when(mockSaveProfile.execute(any)).thenAnswer((_) async {});
  });

  ProfileBloc buildProfileBloc() {
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
    // Mutate the initial state so FinishProfileAction's validation passes:
    // it requires height + weight; profile defaults need name/sex/birthDate
    // to avoid null-deref in the handler body.
    bloc.state.profile = UserProfileModel.empty()
      ..commonName = 'Irfan'
      ..birthDate = DateTime(1990, 1, 1).millisecondsSinceEpoch
      ..sex = SexType.male
      ..objectives = <int>[1]
      ..physicalCharacteristics =
          PhysicalCharacteristics(unit: 1, height: 175, weight: 70);
    bloc.state.objectivesInfoMaster = ObjectivesInfoMaster(
      objectives: [ObjectiveInfoMaster(id: 1, en: 'Obj 1', es: 'Obj 1')],
      metabolicObjectives: const [],
      bodyCompositionObjectives: const [],
    );
    return bloc;
  }

  Widget objectivesHarness({
    required ProfileBloc bloc,
    required NavRecorder recorder,
    required bool onboarding,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      navigatorObservers: [recorder],
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute<dynamic>(
            settings: RouteSettings(
              name: ObjectivesScreen.routeName,
              arguments: onboarding ? const {'isOnboarding': true} : null,
            ),
            builder: (_) => BlocProvider<ProfileBloc>.value(
              value: bloc,
              child: const ObjectivesScreen(),
            ),
          );
        }
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => Scaffold(
            key: Key('stub:${settings.name}'),
            body: Text(settings.name ?? 'unknown'),
          ),
        );
      },
    );
  }

  Widget healthSyncHarness({
    required HealthSyncBloc healthSyncBloc,
    required NavRecorder recorder,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      navigatorObservers: [recorder],
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute<dynamic>(
            settings: RouteSettings(
              name: HealthSyncOnboardingScreen.routeName,
              arguments: const {'isOnboarding': true},
            ),
            builder: (_) => BlocProvider<HealthSyncBloc>.value(
              value: healthSyncBloc,
              child: const HealthSyncOnboardingScreen(),
            ),
          );
        }
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => Scaffold(
            key: Key('stub:${settings.name}'),
            body: Text(settings.name ?? 'unknown'),
          ),
        );
      },
    );
  }

  group('Objectives onboarding Next', () {
    testWidgets('dispatches FinishProfile (save) and navigates to HealthSync',
        (tester) async {
      setPhoneSurface(tester, size: const Size(800, 1600));
      final bloc = buildProfileBloc();
      final recorder = NavRecorder();
      await tester.pumpWidget(objectivesHarness(
          bloc: bloc, recorder: recorder, onboarding: true));
      await tester.pumpAndSettle();
      recorder.reset();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      verify(mockUploadProfile.execute(any)).called(1);
      verify(mockSaveProfile.execute(any)).called(1);
      expectNavigated(recorder, HealthSyncOnboardingScreen.routeName);
    });
  });

  group('Objectives edit mode Next', () {
    testWidgets('does NOT call save and navigates to GeneralQuestions',
        (tester) async {
      setPhoneSurface(tester, size: const Size(800, 1600));
      final bloc = buildProfileBloc();
      final recorder = NavRecorder();
      await tester.pumpWidget(objectivesHarness(
          bloc: bloc, recorder: recorder, onboarding: false));
      await tester.pumpAndSettle();
      recorder.reset();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verifyNever(mockUploadProfile.execute(any));
      verifyNever(mockSaveProfile.execute(any));
      expectNavigated(recorder, GeneralQuestionsScreen.routeName);
    });
  });

  group('HealthSync onboarding', () {
    testWidgets('Skip navigates to Dashboard without saving the profile',
        (tester) async {
      setPhoneSurface(tester, size: const Size(800, 1600));
      final hsBloc = _MockHealthSyncBloc();
      mt.when(() => hsBloc.state).thenReturn(HealthSyncState());
      whenListen(hsBloc, const Stream<HealthSyncState>.empty(),
          initialState: HealthSyncState());
      final recorder = NavRecorder();
      await tester.pumpWidget(
          healthSyncHarness(healthSyncBloc: hsBloc, recorder: recorder));
      await tester.pumpAndSettle();
      recorder.reset();

      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      verifyNever(mockUploadProfile.execute(any));
      verifyNever(mockSaveProfile.execute(any));
      expectNavigated(recorder, DashboardScreen.routeName);
    });

    testWidgets(
        'permissionGranted listener navigates to Dashboard without saving',
        (tester) async {
      setPhoneSurface(tester, size: const Size(800, 1600));
      final hsBloc = _MockHealthSyncBloc();
      final initial = HealthSyncState();
      final granted = HealthSyncState(permissionGranted: true);
      mt.when(() => hsBloc.state).thenReturn(initial);
      // The granted state is queued via whenListen and emits during the
      // first pumpAndSettle, so we observe the navigation push without
      // resetting the recorder.
      whenListen(hsBloc, Stream<HealthSyncState>.fromIterable([granted]),
          initialState: initial);
      final recorder = NavRecorder();
      await tester.pumpWidget(
          healthSyncHarness(healthSyncBloc: hsBloc, recorder: recorder));
      await tester.pumpAndSettle();

      verifyNever(mockUploadProfile.execute(any));
      verifyNever(mockSaveProfile.execute(any));
      // Dashboard should be the last push recorded; the initial route
      // (HealthSyncOnboardingScreen) is the first.
      expect(recorder.lastRoute, DashboardScreen.routeName,
          reason: 'permissionGranted listener should have pushed Dashboard. '
              'Push history: ${recorder.pushes.map((p) => p.routeName).toList()}');
    });
  });
}
