import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/api/steps/models/step_event_response.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/dashboard_all_calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/supplements_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetFoodEventsOfTodayInteractor mockGetFoodEvents;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockGetAdviceInteractor mockGetAdvice;
  late MockGetUserIdInteractor mockGetUserId;
  late MockGetProfileInteractor mockGetProfile;
  late MockGetWaterEventsTodayInteractor mockGetWaterEvents;
  late MockIsNecessaryToShowExplainingCardInteractor mockShowExplainingCard;
  late MockSaveExplainingCardInteractionInteractor mockSaveExplainingCard;
  late MockGetDayCaloriesInteractor mockGetDayCalories;
  late MockGetTodayLiquidEventsInteractor mockGetLiquidEvents;
  late MockGetWeekFoodEventsInteractor mockGetWeekFoodEvents;
  late MockGetWeekLiquidEventsInteractor mockGetWeekLiquidEvents;
  late MockGetWeekSportsInteractor mockGetWeekSports;
  late MockUploadProfileInteractor mockUploadProfile;
  late MockSaveProfileInteractor mockSaveProfile;
  late MockUploadWaterEventInteractor mockUploadWaterEvent;
  late MockSaveWaterEventInteractor mockSaveWaterEvent;
  late MockUploadStepsInteractor mockUploadSteps;
  late MockSaveStepsInteractor mockSaveSteps;
  late MockGetStepsInteractor mockGetSteps;
  late MockGetTodayStepInteractor mockGetTodayStep;
  late MockGetAllEventsSortedByDateInteractor mockGetAllEvents;
  late MockGetTodayCreatineEventInteractor mockGetTodayCreatine;
  late MockUploadCreatineEventInteractor mockUploadCreatine;
  late MockSaveCreatineEventInteractor mockSaveCreatine;
  late MockGetTodayCollagenEventInteractor mockGetTodayCollagen;
  late MockUploadCollagenEventInteractor mockUploadCollagen;
  late MockSaveCollagenEventInteractor mockSaveCollagen;
  late MockGetAllDashboardEventsSortedByDateInteractor mockGetAllDashboardEvents;
  late MockGetMasterFileVersionInteractor mockGetMasterFileVersion;
  late MockManageMasterFilesInteractor mockManageMasterFiles;
  late MockSharedPreferences mockSharedPreferences;
  late MockEraseDatabaseInteractor mockEraseDatabase;
  late MockSignOutInteractor mockSignOut;
  late MockGetRoutinesInteractor mockGetRoutines;
  late MockEraseDBLocalEventsInteractor mockEraseDBLocalEvents;
  late MockSynchronizeEventsInteractor mockSynchronizeEvents;
  late MockChuck mockChuck;
  late MockShowModelAppearanceInteractor mockShowModelAppearance;
  late MockSaveModelAppearanceInteractor mockSaveModelAppearance;
  late MockGetTodaySportsInteractor mockGetTodaySports;
  late MockGetDaySupplementEventsInteractor mockGetDaySupplementEvents;
  late MockUpdateEventsInteractor mockUpdateEvents;

  setUp(() {
    mockGetFoodEvents = MockGetFoodEventsOfTodayInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockGetAdvice = MockGetAdviceInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockGetProfile = MockGetProfileInteractor();
    mockGetWaterEvents = MockGetWaterEventsTodayInteractor();
    mockShowExplainingCard = MockIsNecessaryToShowExplainingCardInteractor();
    mockSaveExplainingCard = MockSaveExplainingCardInteractionInteractor();
    mockGetDayCalories = MockGetDayCaloriesInteractor();
    mockGetLiquidEvents = MockGetTodayLiquidEventsInteractor();
    mockGetWeekFoodEvents = MockGetWeekFoodEventsInteractor();
    mockGetWeekLiquidEvents = MockGetWeekLiquidEventsInteractor();
    mockGetWeekSports = MockGetWeekSportsInteractor();
    mockUploadProfile = MockUploadProfileInteractor();
    mockSaveProfile = MockSaveProfileInteractor();
    mockUploadWaterEvent = MockUploadWaterEventInteractor();
    mockSaveWaterEvent = MockSaveWaterEventInteractor();
    mockUploadSteps = MockUploadStepsInteractor();
    mockSaveSteps = MockSaveStepsInteractor();
    mockGetSteps = MockGetStepsInteractor();
    mockGetTodayStep = MockGetTodayStepInteractor();
    mockGetAllEvents = MockGetAllEventsSortedByDateInteractor();
    mockGetTodayCreatine = MockGetTodayCreatineEventInteractor();
    mockUploadCreatine = MockUploadCreatineEventInteractor();
    mockSaveCreatine = MockSaveCreatineEventInteractor();
    mockGetTodayCollagen = MockGetTodayCollagenEventInteractor();
    mockUploadCollagen = MockUploadCollagenEventInteractor();
    mockSaveCollagen = MockSaveCollagenEventInteractor();
    mockGetAllDashboardEvents = MockGetAllDashboardEventsSortedByDateInteractor();
    mockGetMasterFileVersion = MockGetMasterFileVersionInteractor();
    mockManageMasterFiles = MockManageMasterFilesInteractor();
    mockSharedPreferences = MockSharedPreferences();
    mockEraseDatabase = MockEraseDatabaseInteractor();
    mockSignOut = MockSignOutInteractor();
    mockGetRoutines = MockGetRoutinesInteractor();
    mockEraseDBLocalEvents = MockEraseDBLocalEventsInteractor();
    mockSynchronizeEvents = MockSynchronizeEventsInteractor();
    mockChuck = MockChuck();
    mockShowModelAppearance = MockShowModelAppearanceInteractor();
    mockSaveModelAppearance = MockSaveModelAppearanceInteractor();
    mockGetTodaySports = MockGetTodaySportsInteractor();
    mockGetDaySupplementEvents = MockGetDaySupplementEventsInteractor();
    mockUpdateEvents = MockUpdateEventsInteractor();
  });

  DashboardBloc buildBloc() => DashboardBloc(
    getFoodEventsOfTodayInteractor: mockGetFoodEvents,
    getMasterFileInteractor: mockGetMasterFile,
    getAdviceInteractor: mockGetAdvice,
    getUserIdInteractor: mockGetUserId,
    getProfileInteractor: mockGetProfile,
    getWaterEventsTodayInteractor: mockGetWaterEvents,
    isNecessaryToShowExplainingCardInteractor: mockShowExplainingCard,
    saveExplainingCardInteractionInteractor: mockSaveExplainingCard,
    getDayCaloriesInteractor: mockGetDayCalories,
    getLiquidEventsOfTodayInteractor: mockGetLiquidEvents,
    getWeekFoodEventsInteractor: mockGetWeekFoodEvents,
    getWeekLiquidEventsInteractor: mockGetWeekLiquidEvents,
    getWeekSportsInteractor: mockGetWeekSports,
    uploadProfileInteractor: mockUploadProfile,
    saveProfileInteractor: mockSaveProfile,
    uploadWaterEventInteractor: mockUploadWaterEvent,
    saveWaterEventInteractor: mockSaveWaterEvent,
    uploadStepsInteractor: mockUploadSteps,
    saveStepsInteractor: mockSaveSteps,
    getStepsInteractor: mockGetSteps,
    getTodayStepInteractor: mockGetTodayStep,
    getAllEventsSortedByDateInteractor: mockGetAllEvents,
    getTodayCreatineEventInteractor: mockGetTodayCreatine,
    uploadCreatineEventInteractor: mockUploadCreatine,
    saveCreatineEventInteractor: mockSaveCreatine,
    getTodayCollagenEventInteractor: mockGetTodayCollagen,
    uploadCollagenEventInteractor: mockUploadCollagen,
    saveCollagenEventInteractor: mockSaveCollagen,
    getAllDashboardEventsSortedByDateInteractor: mockGetAllDashboardEvents,
    getMasterFilesVersionInteractor: mockGetMasterFileVersion,
    manageMasterFilesInteractor: mockManageMasterFiles,
    sharedPreferences: mockSharedPreferences,
    eraseDatabaseInteractor: mockEraseDatabase,
    signOutInteractor: mockSignOut,
    getRoutinesInteractor: mockGetRoutines,
    eraseDBLocalEventsInteractor: mockEraseDBLocalEvents,
    synchronizeEventsInteractor: mockSynchronizeEvents,
    updateEventsInteractor: mockUpdateEvents,
    chuck: mockChuck,
    showModelAppearanceInteractor: mockShowModelAppearance,
    saveModelAppearanceInteractor: mockSaveModelAppearance,
    getTodaySportsInteractor: mockGetTodaySports,
    getDaySupplementEventsInteractor: mockGetDaySupplementEvents,
  );

  /// Pre-populates state with minimal data so recompute methods don't crash on null access.
  void seedState(DashboardBloc bloc) {
    bloc.state.foodEvents = [];
    bloc.state.todayLiquidEvents = [];
    bloc.state.waterEvents = [];
    bloc.state.weeklyFoodEvents = [];
    bloc.state.weeklyLiquidEvents = [];
    bloc.state.weeklySportEvents = [];
    bloc.state.supplementEvents = [];
    bloc.state.userKcal = 2000;
    bloc.state.nutrientsInfoMaster = NutrientsInfoMaster(nutrientsInfo: []);
    bloc.state.supplementsInfoMaster = SupplementsInfoMaster(v: 1, data: []);
    bloc.state.profile = UserProfileModel(
      micronutrients: [],
      temporaryMicronutrients: [],
      userRdas: UserRdas(userRdas: []),
      objectives: [],
      kcal: 2000,
    );
  }

  group('DashboardBloc', () {
    blocTest<DashboardBloc, DashboardState>(
      'initial state has correct defaults',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.waterEvents, isEmpty);
        expect(bloc.state.foodEvents, isEmpty);
        expect(bloc.state.userKcal, 0);
      },
    );

    group('RefreshCategoryAction', () {
      group('food', () {
        blocTest<DashboardBloc, DashboardState>(
          'refreshes food events, weekly food, calories, calendar, and recomputes nutrients',
          build: () {
            final foodEvents = [FoodEventComplete(foodInfo: [], eventKcals: 100)];
            when(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')))
                .thenAnswer((_) async => foodEvents);
            when(mockGetWeekFoodEvents.execute())
                .thenAnswer((_) async => foodEvents);
            when(mockGetDayCalories.execute(dateTime: anyNamed('dateTime')))
                .thenAnswer((_) async => 500);
            when(mockGetAllDashboardEvents.execute())
                .thenAnswer((_) async => DashboardAllCalendarEvents());
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.food)),
          expect: () => [
            isA<DashboardState>().having((s) => s.isLoading, 'isLoading', false),
          ],
          verify: (bloc) {
            verify(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime'))).called(1);
            verify(mockGetWeekFoodEvents.execute()).called(1);
            verify(mockGetDayCalories.execute(dateTime: anyNamed('dateTime'))).called(1);
            verify(mockGetAllDashboardEvents.execute()).called(1);
            expect(bloc.state.foodEvents, isNotNull);
            expect(bloc.state.foodEvents!.length, 1);
            expect(bloc.state.energyModel, isNotNull);
            expect(bloc.state.micronutrients, isNotNull);
            expect(bloc.state.sugarAndFiberModel, isNotNull);
          },
        );
      });

      group('water', () {
        blocTest<DashboardBloc, DashboardState>(
          'refreshes only water events',
          build: () {
            final waterEvents = [WaterEventMaster('user1', 1000, 1000, 250)];
            when(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime')))
                .thenAnswer((_) async => waterEvents);
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.water)),
          expect: () => [
            isA<DashboardState>().having((s) => s.isLoading, 'isLoading', false),
          ],
          verify: (bloc) {
            verify(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime'))).called(1);
            expect(bloc.state.waterEvents!.length, 1);
            // Should NOT touch food, sport, or other data
            verifyNever(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')));
            verifyNever(mockGetWeekSports.execute());
          },
        );
      });

      group('liquid', () {
        blocTest<DashboardBloc, DashboardState>(
          'refreshes today and weekly liquid events',
          build: () {
            when(mockGetLiquidEvents.execute(dateTime: anyNamed('dateTime')))
                .thenAnswer((_) async => []);
            when(mockGetWeekLiquidEvents.execute())
                .thenAnswer((_) async => []);
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.liquid)),
          expect: () => [
            isA<DashboardState>().having((s) => s.isLoading, 'isLoading', false),
          ],
          verify: (bloc) {
            verify(mockGetLiquidEvents.execute(dateTime: anyNamed('dateTime'))).called(1);
            verify(mockGetWeekLiquidEvents.execute()).called(1);
            verifyNever(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')));
          },
        );
      });

      group('sport', () {
        blocTest<DashboardBloc, DashboardState>(
          'refreshes weekly sports, calories, calendar, and recomputes energy',
          build: () {
            when(mockGetWeekSports.execute()).thenAnswer((_) async => []);
            when(mockGetDayCalories.execute(dateTime: anyNamed('dateTime')))
                .thenAnswer((_) async => 300);
            when(mockGetAllDashboardEvents.execute())
                .thenAnswer((_) async => DashboardAllCalendarEvents());
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.sport)),
          expect: () => [
            isA<DashboardState>().having((s) => s.isLoading, 'isLoading', false),
          ],
          verify: (bloc) {
            verify(mockGetWeekSports.execute()).called(1);
            verify(mockGetDayCalories.execute(dateTime: anyNamed('dateTime'))).called(1);
            verify(mockGetAllDashboardEvents.execute()).called(1);
            expect(bloc.state.energyModel, isNotNull);
            // Should NOT touch food or water
            verifyNever(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')));
            verifyNever(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime')));
          },
        );
      });

      group('supplement', () {
        blocTest<DashboardBloc, DashboardState>(
          'refreshes supplement events and recomputes nutrients',
          build: () {
            when(mockGetDaySupplementEvents.execute(dateTime: anyNamed('dateTime')))
                .thenAnswer((_) async => <SupplementSimple>[]);
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.supplement)),
          expect: () => [
            isA<DashboardState>().having((s) => s.isLoading, 'isLoading', false),
          ],
          verify: (bloc) {
            verify(mockGetDaySupplementEvents.execute(dateTime: anyNamed('dateTime'))).called(1);
            expect(bloc.state.micronutrients, isNotNull);
            verifyNever(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')));
          },
        );
      });

      group('fecesUrine', () {
        blocTest<DashboardBloc, DashboardState>(
          'refreshes only calendar events',
          build: () {
            when(mockGetAllDashboardEvents.execute())
                .thenAnswer((_) async => DashboardAllCalendarEvents());
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.fecesUrine)),
          expect: () => [
            isA<DashboardState>().having((s) => s.isLoading, 'isLoading', false),
          ],
          verify: (bloc) {
            verify(mockGetAllDashboardEvents.execute()).called(1);
            verifyNever(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')));
            verifyNever(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime')));
            verifyNever(mockGetWeekSports.execute());
          },
        );
      });

      group('profile', () {
        blocTest<DashboardBloc, DashboardState>(
          'refreshes profile, recalculates kcal, and recomputes nutrients/energy/sugar',
          build: () {
            final profile = UserProfileModel(
              kcal: 2500,
              objectives: [],
              micronutrients: ['vitaminC'],
              temporaryMicronutrients: [],
              userRdas: UserRdas(userRdas: [UserRda(name: 'vitaminC', rda: 90, ul: 0, upperLimit: 2000)]),
              physicalCharacteristics: PhysicalCharacteristics(height: 175, weight: 70, unit: 1),
            );
            when(mockGetProfile.execute()).thenAnswer((_) async => profile);
            when(mockGetDayCalories.execute(dateTime: anyNamed('dateTime')))
                .thenAnswer((_) async => 400);
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.profile)),
          expect: () => [
            isA<DashboardState>().having((s) => s.isLoading, 'isLoading', false),
          ],
          verify: (bloc) {
            verify(mockGetProfile.execute()).called(1);
            verify(mockGetDayCalories.execute(dateTime: anyNamed('dateTime'))).called(1);
            expect(bloc.state.profile, isNotNull);
            expect(bloc.state.profile!.kcal, 2500);
            expect(bloc.state.userKcal, isNotNull);
            expect(bloc.state.energyModel, isNotNull);
            expect(bloc.state.micronutrients, isNotNull);
            expect(bloc.state.sugarAndFiberModel, isNotNull);
          },
        );

        blocTest<DashboardBloc, DashboardState>(
          'converts weight from imperial (unit==2) to metric',
          build: () {
            final profile = UserProfileModel(
              kcal: 2000,
              objectives: [],
              micronutrients: [],
              temporaryMicronutrients: [],
              userRdas: UserRdas(userRdas: []),
              physicalCharacteristics: PhysicalCharacteristics(height: 175, weight: 154.0, unit: 2),
            );
            when(mockGetProfile.execute()).thenAnswer((_) async => profile);
            when(mockGetDayCalories.execute(dateTime: anyNamed('dateTime')))
                .thenAnswer((_) async => 0);
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.profile)),
          verify: (bloc) {
            // 154 lbs / 2.20462 ≈ 69.85 kg
            expect(bloc.state.profile!.physicalCharacteristics!.weight, closeTo(69.85, 0.1));
          },
        );
      });

      group('steps', () {
        blocTest<DashboardBloc, DashboardState>(
          'refreshes only today step',
          build: () {
            when(mockGetTodayStep.execute())
                .thenAnswer((_) async => StepEventResponse(eventId: 1, initialSteps: 0, actualSteps: 8000));
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.steps)),
          expect: () => [
            isA<DashboardState>().having((s) => s.isLoading, 'isLoading', false),
          ],
          verify: (bloc) {
            verify(mockGetTodayStep.execute()).called(1);
            expect(bloc.state.todayStep, isNotNull);
            expect(bloc.state.todayStep!.actualSteps, 8000);
            verifyNever(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')));
          },
        );
      });

      group('error handling', () {
        blocTest<DashboardBloc, DashboardState>(
          'silently handles errors without emitting error state',
          build: () {
            when(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')))
                .thenThrow(Exception('network error'));
            final bloc = buildBloc();
            seedState(bloc);
            return bloc;
          },
          act: (bloc) => bloc.add(RefreshCategoryAction(category: DataChangedCategory.food)),
          expect: () => [],
          verify: (bloc) {
            expect(bloc.state.onError, isNull);
          },
        );
      });
    });

    group('DashboardEventBus integration', () {
      test('event bus notification triggers RefreshCategoryAction', () async {
        when(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime')))
            .thenAnswer((_) async => <WaterEventMaster>[]);
        final bloc = buildBloc();
        seedState(bloc);

        // Notify the event bus — the BLoC's stream listener should dispatch RefreshCategoryAction
        DashboardEventBus.instance.notify(DataChangedCategory.water);

        // Give the event loop time to process the event
        await Future.delayed(const Duration(milliseconds: 100));

        verify(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime'))).called(1);

        await bloc.close();
      });
    });
  });
}
