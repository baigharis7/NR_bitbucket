import 'package:bloc_test/bloc_test.dart';
import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/dashboard_all_calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/supplements_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/data/api/steps/models/step_event_response.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:nutrenaissance_flutter/presentation/fecesurine/bloc/feces_urine_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/bloc/meal_time_details_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportitems/bloc/sport_items_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/bloc/supplements_detail_bloc.dart';

import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';

import 'bloc_test_mocks.mocks.dart';

class _MockProfileComputationService extends Mock
    implements ProfileComputationService {
  @override
  Future<Map<int, List<String>>?> getObjectiveNutrientsMap(List<int> objectiveIds) async => null;
}

/// Tests that verify date filtering works correctly across all event categories.
/// Each category must query data for the selected date, not always "today".
void main() {
  // Common test dates
  final today = DateTime(2026, 2, 24);
  final pastDate = DateTime(2026, 2, 20);
  final futureDate = DateTime(2026, 2, 28);

  group('SupplementsDetailBloc date filtering', () {
    late MockGetDaySupplementEventsInteractor mockGetDaySupplementEvents;
    late MockDeleteSupplementEventInteractor mockDeleteSupplementEvent;
    late MockRemoveSupplementEventInteractor mockRemoveSupplementEvent;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockGetProfileInteractor mockGetProfile;
    late MockUpdateEventsInteractor mockUpdateEvents;

    setUp(() {
      mockGetDaySupplementEvents = MockGetDaySupplementEventsInteractor();
      mockDeleteSupplementEvent = MockDeleteSupplementEventInteractor();
      mockRemoveSupplementEvent = MockRemoveSupplementEventInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockUpdateEvents = MockUpdateEventsInteractor();
    });

    SupplementsDetailBloc buildBloc() => SupplementsDetailBloc(
          getDaySupplementEventsInteractor: mockGetDaySupplementEvents,
          deleteSupplementEventInteractor: mockDeleteSupplementEvent,
          removeSupplementEventInteractor: mockRemoveSupplementEvent,
          getMasterFileInteractor: mockGetMasterFile,
          getProfileInteractor: mockGetProfile,
          updateEventsInteractor: mockUpdateEvents,
        );

    void stubDefaults() {
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel(userId: 'user123'));
      when(mockGetMasterFile.execute(MasterFilesType.supplementsInfo))
          .thenAnswer((_) async => SupplementsInfoMaster(v: 1, data: []));
      when(mockGetDaySupplementEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => <SupplementSimple>[]);
      when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async => false);
    }

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'fetches supplements for a past date, not today',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeSupplementsDetailEvent(eventDate: pastDate)),
      verify: (bloc) {
        expect(bloc.state.eventDate, pastDate);
        verify(mockGetDaySupplementEvents.execute(dateTime: pastDate)).called(1);
      },
    );

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'fetches supplements for a future date, not today',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeSupplementsDetailEvent(eventDate: futureDate)),
      verify: (bloc) {
        expect(bloc.state.eventDate, futureDate);
        verify(mockGetDaySupplementEvents.execute(dateTime: futureDate)).called(1);
      },
    );

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'SummaryInitialize uses stored eventDate, not today',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(InitializeSupplementsDetailEvent(eventDate: pastDate));
        await pumpEventQueue();
        // Event bus or external trigger calls summary re-init — must use stored date
        bloc.add(SummaryInitializeSupplementsDetailEvent());
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        // SummaryInitialize calls getDaySupplementEvents with state.eventDate
        // Should be called twice: once from InitializeSupplementsDetailEvent, once from Summary
        verify(mockGetDaySupplementEvents.execute(dateTime: pastDate)).called(2);
      },
    );

    blocTest<SupplementsDetailBloc, SupplementsDetailState>(
      'UpdateEventsDate changes date and re-fetches for new date',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateEventsDateSupplementsDetailEvent(dateTime: pastDate)),
      verify: (bloc) {
        expect(bloc.state.eventDate, pastDate);
        verify(mockGetDaySupplementEvents.execute(dateTime: pastDate)).called(1);
      },
    );
  });

  group('SportItemsBloc date filtering', () {
    late MockGetUserIdInteractor mockGetUserId;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockGetTodaySportsInteractor mockGetTodaySports;
    late MockDeleteSportEventInteractor mockDeleteSportEvent;
    late MockRemoveSportEventInteractor mockRemoveSportEvent;
    late MockUpdateEventsInteractor mockUpdateEvents;

    setUp(() {
      mockGetUserId = MockGetUserIdInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockGetTodaySports = MockGetTodaySportsInteractor();
      mockDeleteSportEvent = MockDeleteSportEventInteractor();
      mockRemoveSportEvent = MockRemoveSportEventInteractor();
      mockUpdateEvents = MockUpdateEventsInteractor();
    });

    SportItemsBloc buildBloc() => SportItemsBloc(
          getUserIdInteractor: mockGetUserId,
          getMasterFileInteractor: mockGetMasterFile,
          getTodaySportsInteractor: mockGetTodaySports,
          deleteSportEventInteractor: mockDeleteSportEvent,
          removeSportEventInteractor: mockRemoveSportEvent,
          updateEventsInteractor: mockUpdateEvents,
        );

    void stubDefaults() {
      when(mockGetMasterFile.execute(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => SportsInfoMaster(sportsInfoMaster: []));
      when(mockGetTodaySports.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => <SportEventComplete>[]);
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async => false);
    }

    blocTest<SportItemsBloc, SportItemsState>(
      'UpdateDatetime sets date and fetches sports for that date',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateDatetimeSportItemsEvents(dateTime: pastDate)),
      verify: (bloc) {
        expect(bloc.state.dateTime, pastDate);
        verify(mockGetTodaySports.execute(dateTime: pastDate)).called(1);
      },
    );

    blocTest<SportItemsBloc, SportItemsState>(
      'UpdateDatetime fetches sports for a future date',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateDatetimeSportItemsEvents(dateTime: futureDate)),
      verify: (bloc) {
        expect(bloc.state.dateTime, futureDate);
        verify(mockGetTodaySports.execute(dateTime: futureDate)).called(1);
      },
    );

    blocTest<SportItemsBloc, SportItemsState>(
      'SportItemsInitialization uses stored date after date was set',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) async {
        // First set the date
        bloc.add(UpdateDatetimeSportItemsEvents(dateTime: pastDate));
        await pumpEventQueue();
        // Then re-initialize (e.g. from event bus) — should use stored date
        bloc.add(SportItemsInitialization());
      },
      wait: const Duration(milliseconds: 300),
      verify: (bloc) {
        // Should be called with pastDate both times
        verify(mockGetTodaySports.execute(dateTime: pastDate)).called(2);
      },
    );

    blocTest<SportItemsBloc, SportItemsState>(
      'SportItemsInitialization without prior date set uses null (defaults to today)',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(SportItemsInitialization()),
      verify: (bloc) {
        // state.dateTime is null, so should pass null
        verify(mockGetTodaySports.execute(dateTime: null)).called(1);
      },
    );
  });

  group('MealTimeDetailsBloc date filtering', () {
    late MockGetUserIdInteractor mockGetUserId;
    late MockGetFoodEventsOfTodayInteractor mockGetFoodEvents;
    late MockGetTodayLiquidEventsInteractor mockGetLiquidEvents;
    late MockGetProfileInteractor mockGetProfile;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockDeleteFoodEventInteractor mockDeleteFoodEvent;
    late MockRemoveFoodEventInteractor mockRemoveFoodEvent;
    late MockUpdateEventsInteractor mockUpdateEvents;
    late MockPreferencesRepository mockPreferencesRepository;

    setUp(() {
      mockGetUserId = MockGetUserIdInteractor();
      mockGetFoodEvents = MockGetFoodEventsOfTodayInteractor();
      mockGetLiquidEvents = MockGetTodayLiquidEventsInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockDeleteFoodEvent = MockDeleteFoodEventInteractor();
      mockRemoveFoodEvent = MockRemoveFoodEventInteractor();
      mockUpdateEvents = MockUpdateEventsInteractor();
      mockPreferencesRepository = MockPreferencesRepository();
    });

    MealTimeDetailsBloc buildBloc() => MealTimeDetailsBloc(
          getUserIdInteractor: mockGetUserId,
          getFoodEventsOfTodayInteractor: mockGetFoodEvents,
          getLiquidEventsOfTodayInteractor: mockGetLiquidEvents,
          getProfileInteractor: mockGetProfile,
          getMasterFileInteractor: mockGetMasterFile,
          deleteFoodEventInteractor: mockDeleteFoodEvent,
          removeFoodEventInteractor: mockRemoveFoodEvent,
          updateEventsInteractor: mockUpdateEvents,
          preferencesRepository: mockPreferencesRepository,
          profileComputationService: _MockProfileComputationService(),
        );

    void stubDefaults() {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel(
            userId: 'user123',
            kcal: 2000,
            objectives: [],
            micronutrients: [],
            temporaryMicronutrients: [],
            userRdas: UserRdas(userRdas: []),
          ));
      when(mockGetMasterFile.execute(MasterFilesType.nutrientsInfo))
          .thenAnswer((_) async => NutrientsInfoMaster(nutrientsInfo: []));
      when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
          .thenAnswer((_) async => null);
      when(mockGetMasterFile.execute(MasterFilesType.unitsInfo))
          .thenAnswer((_) async => null);
      when(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => <FoodEventComplete>[]);
      when(mockGetLiquidEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => []);
      when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async => false);
    }

    blocTest<MealTimeDetailsBloc, MealTimeDetailsState>(
      'UpdateDateTimeMealTimeDetailsEvent stores the selected date',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateDateTimeMealTimeDetailsEvent(dateTime: pastDate)),
      wait: const Duration(milliseconds: 500),
      verify: (bloc) {
        expect(bloc.state.selectedDateTime, pastDate);
        verify(mockGetFoodEvents.execute(dateTime: pastDate)).called(greaterThanOrEqualTo(1));
        verify(mockGetLiquidEvents.execute(dateTime: pastDate)).called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<MealTimeDetailsBloc, MealTimeDetailsState>(
      'UpdateDateTimeMealTimeDetailsEvent with future date fetches for that date',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateDateTimeMealTimeDetailsEvent(dateTime: futureDate)),
      wait: const Duration(milliseconds: 500),
      verify: (bloc) {
        expect(bloc.state.selectedDateTime, futureDate);
        verify(mockGetFoodEvents.execute(dateTime: futureDate)).called(greaterThanOrEqualTo(1));
        verify(mockGetLiquidEvents.execute(dateTime: futureDate)).called(greaterThanOrEqualTo(1));
      },
    );

    blocTest<MealTimeDetailsBloc, MealTimeDetailsState>(
      'SummaryInitialization uses stored selectedDateTime, not today',
      build: () {
        stubDefaults();
        final bloc = buildBloc();
        bloc.state.selectedDateTime = pastDate;
        bloc.state.mealTime = MealTime(id: 1, name: 'breakfast');
        bloc.state.profile = UserProfileModel(
          userId: 'user123', kcal: 2000, objectives: [],
          micronutrients: [], temporaryMicronutrients: [],
          userRdas: UserRdas(userRdas: []),
          userAll: [],
        );
        bloc.state.nutrientsInfoMaster = NutrientsInfoMaster(nutrientsInfo: []);
        return bloc;
      },
      act: (bloc) => bloc.add(SummaryInitializationMealTimeDetailsEventState()),
      verify: (bloc) {
        verify(mockGetFoodEvents.execute(dateTime: pastDate)).called(1);
        verify(mockGetLiquidEvents.execute(dateTime: pastDate)).called(1);
      },
    );
  });

  group('FecesUrineBloc date filtering', () {
    late MockGetUserIdInteractor mockGetUserId;
    late MockUploadFecesInteractor mockUploadFeces;
    late MockGetFecesEventsInteractor mockGetFecesEvents;
    late MockSaveFecesEventInteractor mockSaveFecesEvent;
    late MockUploadUrineInteractor mockUploadUrine;
    late MockSaveUrineInteractor mockSaveUrine;
    late MockGetUrineEventsInteractor mockGetUrineEvents;
    late MockDeleteFecesEventInteractor mockDeleteFeces;
    late MockRemoveFecesEventInteractor mockRemoveFeces;
    late MockDeleteUrineEventInteractor mockDeleteUrine;
    late MockRemoveUrineEventInteractor mockRemoveUrine;
    late MockGetFaecesByDateInteractor mockGetFaecesByDate;
    late MockGetUrineByDateInteractor mockGetUrineByDate;

    setUp(() {
      mockGetUserId = MockGetUserIdInteractor();
      mockUploadFeces = MockUploadFecesInteractor();
      mockGetFecesEvents = MockGetFecesEventsInteractor();
      mockSaveFecesEvent = MockSaveFecesEventInteractor();
      mockUploadUrine = MockUploadUrineInteractor();
      mockSaveUrine = MockSaveUrineInteractor();
      mockGetUrineEvents = MockGetUrineEventsInteractor();
      mockDeleteFeces = MockDeleteFecesEventInteractor();
      mockRemoveFeces = MockRemoveFecesEventInteractor();
      mockDeleteUrine = MockDeleteUrineEventInteractor();
      mockRemoveUrine = MockRemoveUrineEventInteractor();
      mockGetFaecesByDate = MockGetFaecesByDateInteractor();
      mockGetUrineByDate = MockGetUrineByDateInteractor();
    });

    FecesUrineBloc buildBloc() => FecesUrineBloc(
          getUserIdInteractor: mockGetUserId,
          uploadFecesInteractor: mockUploadFeces,
          getFecesEventsInteractor: mockGetFecesEvents,
          saveFecesEventInteractor: mockSaveFecesEvent,
          uploadUrineInteractor: mockUploadUrine,
          saveUrineInteractor: mockSaveUrine,
          getUrineEventsInteractor: mockGetUrineEvents,
          deleteFecesEventInteractor: mockDeleteFeces,
          removeFecesEventInteractor: mockRemoveFeces,
          deleteUrineEventInteractor: mockDeleteUrine,
          removeUrineEventInteractor: mockRemoveUrine,
          getFaecesByDateInteractor: mockGetFaecesByDate,
          getUrineByDateInteractor: mockGetUrineByDate,
        );

    void stubDefaults() {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockGetFaecesByDate.execute(dateTime: anyNamed('dateTime'), days: anyNamed('days')))
          .thenAnswer((_) async => <UploadFeces>[]);
      when(mockGetUrineByDate.execute(dateTime: anyNamed('dateTime'), days: anyNamed('days')))
          .thenAnswer((_) async => <UploadFeces>[]);
    }

    blocTest<FecesUrineBloc, FecesUrineState>(
      'UpdateCalendarDate fetches feces and urine for the selected date',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateCalendarDateFecesUrineEventAction(dateTime: pastDate)),
      verify: (bloc) {
        expect(bloc.state.calendarDateTime, pastDate);
        // Day events
        verify(mockGetFaecesByDate.execute(dateTime: pastDate)).called(1);
        verify(mockGetUrineByDate.execute(dateTime: pastDate)).called(1);
        // 14-day chart data centered on selected date
        verify(mockGetFaecesByDate.execute(dateTime: pastDate, days: 14)).called(1);
        verify(mockGetUrineByDate.execute(dateTime: pastDate, days: 14)).called(1);
      },
    );

    blocTest<FecesUrineBloc, FecesUrineState>(
      'UpdateCalendarDate fetches data for a future date',
      build: () {
        stubDefaults();
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateCalendarDateFecesUrineEventAction(dateTime: futureDate)),
      verify: (bloc) {
        expect(bloc.state.calendarDateTime, futureDate);
        verify(mockGetFaecesByDate.execute(dateTime: futureDate)).called(1);
        verify(mockGetUrineByDate.execute(dateTime: futureDate)).called(1);
      },
    );
  });

  group('DashboardBloc date filtering', () {
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
    late MockClearAuthPreferencesInteractor mockClearAuth;
    late MockEraseDatabaseInteractor mockEraseDatabase;
    late MockSignOutInteractor mockSignOut;
    late MockGetRoutinesInteractor mockGetRoutines;
    late MockEraseDBLocalEventsInteractor mockEraseDBLocalEvents;
    late MockSynchronizeEventsInteractor mockSynchronizeEvents;
    late Chuck mockChuck;
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
      mockClearAuth = MockClearAuthPreferencesInteractor();
      mockEraseDatabase = MockEraseDatabaseInteractor();
      mockSignOut = MockSignOutInteractor();
      mockGetRoutines = MockGetRoutinesInteractor();
      mockEraseDBLocalEvents = MockEraseDBLocalEventsInteractor();
      mockSynchronizeEvents = MockSynchronizeEventsInteractor();
      mockChuck = Chuck(showNotification: false);
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
          clearAuthPreferencesInteractor: mockClearAuth,
          eraseDatabaseInteractor: mockEraseDatabase,
          signOutInteractor: mockSignOut,
          getRoutinesInteractor: mockGetRoutines,
          eraseDBLocalEventsInteractor: mockEraseDBLocalEvents,
          synchronizeEventsInteractor: mockSynchronizeEvents,
          chuck: mockChuck,
          showModelAppearanceInteractor: mockShowModelAppearance,
          saveModelAppearanceInteractor: mockSaveModelAppearance,
          getTodaySportsInteractor: mockGetTodaySports,
          getDaySupplementEventsInteractor: mockGetDaySupplementEvents,
          updateEventsInteractor: mockUpdateEvents,
        );

    void stubInitializeDefaults() {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockGetMasterFile.execute(any)).thenAnswer((_) async => null);
      when(mockGetMasterFile.execute(MasterFilesType.nutrientsInfo))
          .thenAnswer((_) async => NutrientsInfoMaster(nutrientsInfo: []));
      when(mockGetMasterFile.execute(MasterFilesType.supplementsInfo))
          .thenAnswer((_) async => SupplementsInfoMaster(v: 1, data: []));
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel(
            userId: 'user123', kcal: 2000, objectives: [],
            micronutrients: [], temporaryMicronutrients: [],
            userRdas: UserRdas(userRdas: []),
          ));
      when(mockShowModelAppearance.execute(any)).thenAnswer((_) async => null);
      when(mockGetDayCalories.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => 0);
      when(mockGetTodayCreatine.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => null);
      when(mockGetTodayCollagen.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => null);
      when(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => <FoodEventComplete>[]);
      when(mockGetLiquidEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => []);
      when(mockGetWeekFoodEvents.execute()).thenAnswer((_) async => []);
      when(mockGetWeekLiquidEvents.execute()).thenAnswer((_) async => []);
      when(mockGetWeekSports.execute()).thenAnswer((_) async => []);
      when(mockGetTodayStep.execute()).thenAnswer((_) async => StepEventResponse(eventId: 0, initialSteps: 0, actualSteps: 0));
      when(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => []);
      when(mockGetAllDashboardEvents.execute())
          .thenAnswer((_) async => DashboardAllCalendarEvents());
      when(mockGetDaySupplementEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => <SupplementSimple>[]);
    }

    group('InitializeState with selected date', () {
      blocTest<DashboardBloc, DashboardState>(
        'passes pastDate to all date-sensitive interactors',
        build: () {
          stubInitializeDefaults();
          return buildBloc();
        },
        act: (bloc) => bloc.add(InitializeState(dateTime: pastDate, onFinish: () {})),
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          verify(mockGetDayCalories.execute(dateTime: pastDate)).called(1);
          verify(mockGetTodayCreatine.execute(dateTime: pastDate)).called(1);
          verify(mockGetTodayCollagen.execute(dateTime: pastDate)).called(1);
          verify(mockGetFoodEvents.execute(dateTime: pastDate)).called(1);
          verify(mockGetLiquidEvents.execute(dateTime: pastDate)).called(1);
          verify(mockGetWaterEvents.execute(dateTime: pastDate)).called(1);
          verify(mockGetDaySupplementEvents.execute(dateTime: pastDate)).called(1);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'passes futureDate to all date-sensitive interactors',
        build: () {
          stubInitializeDefaults();
          return buildBloc();
        },
        act: (bloc) => bloc.add(InitializeState(dateTime: futureDate, onFinish: () {})),
        wait: const Duration(milliseconds: 500),
        verify: (bloc) {
          verify(mockGetDayCalories.execute(dateTime: futureDate)).called(1);
          verify(mockGetFoodEvents.execute(dateTime: futureDate)).called(1);
          verify(mockGetLiquidEvents.execute(dateTime: futureDate)).called(1);
          verify(mockGetWaterEvents.execute(dateTime: futureDate)).called(1);
          verify(mockGetDaySupplementEvents.execute(dateTime: futureDate)).called(1);
        },
      );
    });

    group('RefreshCategoryAction uses _lastSelectedDate', () {
      blocTest<DashboardBloc, DashboardState>(
        'food refresh uses the previously selected past date',
        build: () {
          stubInitializeDefaults();
          when(mockGetAllDashboardEvents.execute())
              .thenAnswer((_) async => DashboardAllCalendarEvents());
          return buildBloc();
        },
        act: (bloc) async {
          // Set _lastSelectedDate by initializing with pastDate
          bloc.add(InitializeState(dateTime: pastDate, onFinish: () {}));
          await pumpEventQueue();
          // Now trigger a food refresh — should use _lastSelectedDate (pastDate)
          bloc.add(RefreshCategoryAction(category: DataChangedCategory.food));
        },
        wait: const Duration(milliseconds: 700),
        verify: (bloc) {
          // InitializeState calls it once, RefreshCategoryAction calls it again — both with pastDate
          verify(mockGetFoodEvents.execute(dateTime: pastDate)).called(2);
          verify(mockGetDayCalories.execute(dateTime: pastDate)).called(2);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'supplement refresh uses the previously selected past date',
        build: () {
          stubInitializeDefaults();
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(InitializeState(dateTime: pastDate, onFinish: () {}));
          await pumpEventQueue();
          bloc.add(RefreshCategoryAction(category: DataChangedCategory.supplement));
        },
        wait: const Duration(milliseconds: 700),
        verify: (bloc) {
          verify(mockGetDaySupplementEvents.execute(dateTime: pastDate)).called(2);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'water refresh uses the previously selected past date',
        build: () {
          stubInitializeDefaults();
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(InitializeState(dateTime: pastDate, onFinish: () {}));
          await pumpEventQueue();
          bloc.add(RefreshCategoryAction(category: DataChangedCategory.water));
        },
        wait: const Duration(milliseconds: 700),
        verify: (bloc) {
          verify(mockGetWaterEvents.execute(dateTime: pastDate)).called(2);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'liquid refresh uses the previously selected past date',
        build: () {
          stubInitializeDefaults();
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(InitializeState(dateTime: pastDate, onFinish: () {}));
          await pumpEventQueue();
          bloc.add(RefreshCategoryAction(category: DataChangedCategory.liquid));
        },
        wait: const Duration(milliseconds: 700),
        verify: (bloc) {
          verify(mockGetLiquidEvents.execute(dateTime: pastDate)).called(2);
        },
      );
    });
  });
}
