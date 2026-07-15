import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/supplements_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_actions.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/liquidsummarydetail/bloc/liquid_summary_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/sportitems/bloc/sport_items_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/presentation/updatesupplement/bloc/update_supplement_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/supplementsdetail/bloc/supplements_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/bloc/meal_time_details_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/weeklydashboarddetail/bloc/weekly_dashboard_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/macronutrients_detail/bloc/macro_nutrients_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/bloc/micro_nutrients_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/energy_balance_detail/bloc/energy_balance_detail_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_liquid_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_sport_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/routinestabs/bloc/routines_tab_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/bloc/favorites_tabs_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';

import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';

import 'bloc_test_mocks.mocks.dart';

class _MockProfileComputationService extends Mock
    implements ProfileComputationService {
  @override
  Future<Map<int, List<String>>?> getObjectiveNutrientsMap(List<int> objectiveIds) async => null;
}

final _stubNutrientsInfo = NutrientsInfoMaster(nutrientsInfo: [
  NutrientInfoMaster(officialName: 'proteinLabel', unit: 'g', en: 'Protein', es: 'Proteína'),
  NutrientInfoMaster(officialName: 'carbsAvailable', unit: 'g', en: 'Carbs', es: 'Carbohidratos'),
  NutrientInfoMaster(officialName: 'fatTotal', unit: 'g', en: 'Fat', es: 'Grasa'),
  NutrientInfoMaster(officialName: 'addedSugar', unit: 'g', en: 'Added Sugar', es: 'Azúcar'),
  NutrientInfoMaster(officialName: 'fiber', unit: 'g', en: 'Fiber', es: 'Fibra'),
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Stub flutter_timezone method channel to avoid MissingPluginException
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter_timezone'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'getLocalTimezone') {
        return 'UTC';
      }
      return null;
    },
  );

  // ---------------------------------------------------------------------------
  // SportItemsBloc EventBus
  // ---------------------------------------------------------------------------
  group('SportItemsBloc EventBus', () {
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

    test('sport event bus notification triggers SportItemsInitialization', () async {
      when(mockGetMasterFile.execute(any)).thenAnswer((_) async => null);
      when(mockGetTodaySports.execute(dateTime: anyNamed('dateTime'))).thenAnswer((_) async => <SportEventComplete>[]);
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async => false);

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verify(mockGetTodaySports.execute(dateTime: anyNamed('dateTime'))).called(1);

      await bloc.close();
    });

    test('non-sport event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetTodaySports.execute(dateTime: anyNamed('dateTime')));

      await bloc.close();
    });

    test('delete sport event notifies event bus', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
      when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
      when(mockGetTodaySports.execute(dateTime: anyNamed('dateTime'))).thenAnswer((_) async => <SportEventComplete>[]);
      when(mockGetMasterFile.execute(any)).thenAnswer((_) async => null);
      when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async => false);

      final bloc = buildBloc();

      // Listen for event bus notifications
      final notifications = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(notifications.add);

      bloc.add(DeleteSportItemSportItemsEvents(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 1, eventDate: 1000, info: []),
      ));
      await pumpEventQueue();

      expect(notifications, contains(DataChangedCategory.sport));

      await sub.cancel();
      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      // After close, notifications should not trigger events
      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verifyNever(mockGetTodaySports.execute(dateTime: anyNamed('dateTime')));
    });
  });

  // ---------------------------------------------------------------------------
  // CalendarBloc EventBus
  // ---------------------------------------------------------------------------
  group('CalendarBloc EventBus', () {
    late MockGetAllEventsSortedByDateInteractor mockGetAllEvents;
    late MockGetUserIdInteractor mockGetUserId;
    late MockRemoveFoodEventInteractor mockRemoveFoodEvent;
    late MockDeleteFoodEventInteractor mockDeleteFoodEvent;
    late MockRemoveSportEventInteractor mockRemoveSportEvent;
    late MockDeleteSportEventInteractor mockDeleteSportEvent;

    setUp(() {
      mockGetAllEvents = MockGetAllEventsSortedByDateInteractor();
      mockGetUserId = MockGetUserIdInteractor();
      mockRemoveFoodEvent = MockRemoveFoodEventInteractor();
      mockDeleteFoodEvent = MockDeleteFoodEventInteractor();
      mockRemoveSportEvent = MockRemoveSportEventInteractor();
      mockDeleteSportEvent = MockDeleteSportEventInteractor();
    });

    CalendarBloc buildBloc() => CalendarBloc(
          getAllEventsSortedByDateInteractor: mockGetAllEvents,
          getUserIdInteractor: mockGetUserId,
          removeFoodEventInteractor: mockRemoveFoodEvent,
          deleteFoodEventInteractor: mockDeleteFoodEvent,
          removeSportEventInteractor: mockRemoveSportEvent,
          deleteSportEventInteractor: mockDeleteSportEvent,
        );

    for (final category in [
      DataChangedCategory.food,
      DataChangedCategory.sport,
      DataChangedCategory.liquid,
      DataChangedCategory.water,
      DataChangedCategory.supplement,
      DataChangedCategory.fecesUrine,
    ]) {
      test('$category event bus notification triggers InitializeStateAction', () async {
        when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());

        final bloc = buildBloc();

        DashboardEventBus.instance.notify(category);
        await pumpEventQueue();

        verify(mockGetAllEvents.execute()).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('profile event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.profile);
      await pumpEventQueue();

      verifyNever(mockGetAllEvents.execute());

      await bloc.close();
    });

    test('remove food event notifies event bus with food category', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockDeleteFoodEvent.execute(any, any)).thenAnswer((_) async => true);
      when(mockRemoveFoodEvent.execute(any)).thenAnswer((_) async => true);
      when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());

      final bloc = buildBloc();

      final notifications = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(notifications.add);

      bloc.add(RemoveFoodEventAction(
        foodEventComplete: FoodEventComplete(userId: 'user123', eventDate: 1000, eventId: 1),
        onFinish: () {},
      ));
      await pumpEventQueue();

      expect(notifications, contains(DataChangedCategory.food));

      await sub.cancel();
      await bloc.close();
    });

    test('remove sport event notifies event bus with sport category', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
      when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
      when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());

      final bloc = buildBloc();

      final notifications = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(notifications.add);

      bloc.add(RemoveSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 1, eventDate: 1000, info: []),
        onFinish: () {},
      ));
      await pumpEventQueue();

      expect(notifications, contains(DataChangedCategory.sport));

      await sub.cancel();
      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetAllEvents.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // JournalBloc EventBus
  // ---------------------------------------------------------------------------
  group('JournalBloc EventBus', () {
    late MockGetUserKcalInteractor mockGetUserKcal;
    late MockGetWeekSportsInteractor mockGetWeekSports;
    late MockGetTodaySportsInteractor mockGetTodaySports;
    late MockGetWaterEventsTodayInteractor mockGetWaterEvents;
    late MockIsNecessaryToShowExplainingCardInteractor mockShowExplainingCard;
    late MockSaveExplainingCardInteractionInteractor mockSaveExplainingCard;
    late MockGetTodayLiquidEventsInteractor mockGetLiquidEvents;
    late MockGetProfileInteractor mockGetProfile;
    late MockGetFoodEventsOfTodayInteractor mockGetFoodEvents;

    setUp(() {
      mockGetUserKcal = MockGetUserKcalInteractor();
      mockGetWeekSports = MockGetWeekSportsInteractor();
      mockGetTodaySports = MockGetTodaySportsInteractor();
      mockGetWaterEvents = MockGetWaterEventsTodayInteractor();
      mockShowExplainingCard = MockIsNecessaryToShowExplainingCardInteractor();
      mockSaveExplainingCard = MockSaveExplainingCardInteractionInteractor();
      mockGetLiquidEvents = MockGetTodayLiquidEventsInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockGetFoodEvents = MockGetFoodEventsOfTodayInteractor();
    });

    JournalBloc buildBloc() => JournalBloc(
          getUserKcalInteractor: mockGetUserKcal,
          getWeekSportsInteractor: mockGetWeekSports,
          getTodaySportsInteractor: mockGetTodaySports,
          getWaterEventsTodayInteractor: mockGetWaterEvents,
          isNecessaryToShowExplainingCardInteractor: mockShowExplainingCard,
          saveExplainingCardInteractionInteractor: mockSaveExplainingCard,
          getLiquidEventsOfTodayInteractor: mockGetLiquidEvents,
          getProfileInteractor: mockGetProfile,
          getFoodEventsOfTodayInteractor: mockGetFoodEvents,
        );

    void stubAllInteractors() {
      when(mockGetUserKcal.execute()).thenAnswer((_) async => 2000);
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel());
      when(mockGetWeekSports.execute()).thenAnswer((_) async => <SportEventComplete>[]);
      when(mockGetTodaySports.execute(dateTime: anyNamed('dateTime'))).thenAnswer((_) async => <SportEventComplete>[]);
      when(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime'))).thenAnswer((_) async => <WaterEventMaster>[]);
      when(mockGetLiquidEvents.execute()).thenAnswer((_) async => <LiquidEventComplete>[]);
      when(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime'))).thenAnswer((_) async => <FoodEventComplete>[]);
      when(mockShowExplainingCard.execute(any)).thenAnswer((_) async => false);
    }

    for (final category in [
      DataChangedCategory.food,
      DataChangedCategory.sport,
      DataChangedCategory.liquid,
      DataChangedCategory.water,
    ]) {
      test('$category event bus notification triggers InitializeStateAction', () async {
        stubAllInteractors();

        final bloc = buildBloc();

        DashboardEventBus.instance.notify(category);
        await pumpEventQueue();

        verify(mockGetUserKcal.execute()).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('supplement event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.supplement);
      await pumpEventQueue();

      verifyNever(mockGetUserKcal.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetUserKcal.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // LiquidSummaryDetailBloc EventBus
  // ---------------------------------------------------------------------------
  group('LiquidSummaryDetailBloc EventBus', () {
    late MockGetTodayLiquidEventsInteractor mockGetLiquidEvents;
    late MockGetProfileInteractor mockGetProfile;
    late MockGetUserIdInteractor mockGetUserId;
    late MockUploadWaterEventInteractor mockUploadWaterEvent;
    late MockSaveWaterEventInteractor mockSaveWaterEvent;
    late MockGetFoodEventsOfTodayInteractor mockGetFoodEvents;
    late MockGetWaterEventsTodayInteractor mockGetWaterEvents;

    setUp(() {
      mockGetLiquidEvents = MockGetTodayLiquidEventsInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockGetUserId = MockGetUserIdInteractor();
      mockUploadWaterEvent = MockUploadWaterEventInteractor();
      mockSaveWaterEvent = MockSaveWaterEventInteractor();
      mockGetFoodEvents = MockGetFoodEventsOfTodayInteractor();
      mockGetWaterEvents = MockGetWaterEventsTodayInteractor();
    });

    LiquidSummaryDetailBloc buildBloc() => LiquidSummaryDetailBloc(
          getLiquidEventsOfTodayInteractor: mockGetLiquidEvents,
          getProfileInteractor: mockGetProfile,
          getUserIdInteractor: mockGetUserId,
          uploadWaterEventInteractor: mockUploadWaterEvent,
          saveWaterEventInteractor: mockSaveWaterEvent,
          getFoodEventsOfTodayInteractor: mockGetFoodEvents,
          getWaterEventsTodayInteractor: mockGetWaterEvents,
        );

    void stubAllInteractors() {
      when(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime'))).thenAnswer((_) async => <WaterEventMaster>[]);
      when(mockGetLiquidEvents.execute()).thenAnswer((_) async => <LiquidEventComplete>[]);
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel());
      when(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime'))).thenAnswer((_) async => <FoodEventComplete>[]);
    }

    for (final category in [
      DataChangedCategory.liquid,
      DataChangedCategory.water,
    ]) {
      test('$category event bus notification triggers LoadLiquidSummaryEventAction', () async {
        stubAllInteractors();

        final bloc = buildBloc();

        DashboardEventBus.instance.notify(category);
        await pumpEventQueue();

        verify(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime'))).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('food event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime')));

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.liquid);
      await pumpEventQueue();

      verifyNever(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime')));
    });
  });

  // ---------------------------------------------------------------------------
  // UpdateSupplementBloc EventBus (producer only)
  // ---------------------------------------------------------------------------
  group('UpdateSupplementBloc EventBus', () {
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockUploadSupplementFavoriteInteractor mockUploadSupplementFavorite;
    late MockSaveSupplementFavoriteInteractor mockSaveSupplementFavorite;
    late MockUploadSupplementRoutineInteractor mockUploadSupplementRoutine;
    late MockSaveSupplementRoutineInteractor mockSaveSupplementRoutine;
    late MockGetUserIdInteractor mockGetUserId;

    setUp(() {
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockUploadSupplementFavorite = MockUploadSupplementFavoriteInteractor();
      mockSaveSupplementFavorite = MockSaveSupplementFavoriteInteractor();
      mockUploadSupplementRoutine = MockUploadSupplementRoutineInteractor();
      mockSaveSupplementRoutine = MockSaveSupplementRoutineInteractor();
      mockGetUserId = MockGetUserIdInteractor();
    });

    UpdateSupplementBloc buildBloc() => UpdateSupplementBloc(
          getMasterFileInteractor: mockGetMasterFile,
          uploadSupplementFavoriteInteractor: mockUploadSupplementFavorite,
          saveSupplementFavoriteInteractor: mockSaveSupplementFavorite,
          uploadSupplementRoutineInteractor: mockUploadSupplementRoutine,
          saveSupplementRoutineInteractor: mockSaveSupplementRoutine,
          getUserIdInteractor: mockGetUserId,
        );

    test('saving supplement favorite notifies event bus with supplement category', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockUploadSupplementFavorite.execute(any)).thenAnswer((_) async {});
      when(mockSaveSupplementFavorite.execute(any, any)).thenAnswer((_) async {});

      final bloc = buildBloc();

      // Set up supplement object
      bloc.state.supplementObj = SupplementSimple(
        info: [NutriInfo(id: 1, unit: 'mg', amount: 100)],
        isFavorite: true,
        name: 'Test Supplement',
      );

      final notifications = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(notifications.add);

      var finished = false;
      bloc.add(SavingUpdateSupplementFavorite(onFinish: () { finished = true; }));
      await pumpEventQueue();

      expect(notifications, contains(DataChangedCategory.supplement));
      expect(finished, true);

      await sub.cancel();
      await bloc.close();
    });

    test('saving supplement routine notifies event bus with supplement category', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockUploadSupplementRoutine.execute(any)).thenAnswer((_) async {});
      when(mockSaveSupplementRoutine.execute(any, any)).thenAnswer((_) async {});

      final bloc = buildBloc();

      // Set up supplement object
      bloc.state.supplementObj = SupplementSimple(
        info: [NutriInfo(id: 1, unit: 'mg', amount: 100)],
        isRoutine: true,
        name: 'Test Routine',
        scheduleTime: '08:00',
        daysOfWeek: [1, 2, 3],
      );

      final notifications = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(notifications.add);

      var finished = false;
      bloc.add(SavingUpdateSupplementRoutine(onFinish: () { finished = true; }));
      await pumpEventQueue();

      expect(notifications, contains(DataChangedCategory.supplement));
      expect(finished, true);

      await sub.cancel();
      await bloc.close();
    });

    test('failed upload does NOT notify event bus', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockUploadSupplementFavorite.execute(any)).thenThrow(Exception('upload failed'));

      final bloc = buildBloc();

      bloc.state.supplementObj = SupplementSimple(
        info: [NutriInfo(id: 1, unit: 'mg', amount: 100)],
        isFavorite: true,
        name: 'Test Supplement',
      );

      final notifications = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(notifications.add);

      bloc.add(SavingUpdateSupplementFavorite(onFinish: () {}));
      await pumpEventQueue();

      expect(notifications, isNot(contains(DataChangedCategory.supplement)));

      await sub.cancel();
      await bloc.close();
    });
  });

  // ---------------------------------------------------------------------------
  // SupplementsDetailBloc EventBus
  // ---------------------------------------------------------------------------
  group('SupplementsDetailBloc EventBus', () {
    late MockGetDaySupplementEventsInteractor mockGetDaySuppEvents;
    late MockDeleteSupplementEventInteractor mockDeleteSuppEvent;
    late MockRemoveSupplementEventInteractor mockRemoveSuppEvent;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockGetProfileInteractor mockGetProfile;
    late MockUpdateEventsInteractor mockUpdateEvents;

    setUp(() {
      mockGetDaySuppEvents = MockGetDaySupplementEventsInteractor();
      mockDeleteSuppEvent = MockDeleteSupplementEventInteractor();
      mockRemoveSuppEvent = MockRemoveSupplementEventInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockUpdateEvents = MockUpdateEventsInteractor();
    });

    SupplementsDetailBloc buildBloc() => SupplementsDetailBloc(
          getDaySupplementEventsInteractor: mockGetDaySuppEvents,
          deleteSupplementEventInteractor: mockDeleteSuppEvent,
          removeSupplementEventInteractor: mockRemoveSuppEvent,
          getMasterFileInteractor: mockGetMasterFile,
          getProfileInteractor: mockGetProfile,
          updateEventsInteractor: mockUpdateEvents,
        );

    test('supplement event bus notification triggers reload', () async {
      when(mockGetDaySuppEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => <SupplementSimple>[]);

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.supplement);
      await pumpEventQueue();

      verify(mockGetDaySuppEvents.execute(dateTime: anyNamed('dateTime'))).called(greaterThanOrEqualTo(1));

      await bloc.close();
    });

    test('food event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetDaySuppEvents.execute(dateTime: anyNamed('dateTime')));

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.supplement);
      await pumpEventQueue();

      verifyNever(mockGetDaySuppEvents.execute(dateTime: anyNamed('dateTime')));
    });
  });

  // ---------------------------------------------------------------------------
  // MealTimeDetailsBloc EventBus
  // ---------------------------------------------------------------------------
  group('MealTimeDetailsBloc EventBus', () {
    late MockGetUserIdInteractor mockGetUserId;
    late MockGetFoodEventsOfTodayInteractor mockGetFoodEvents;
    late MockGetTodayLiquidEventsInteractor mockGetLiquidEvents;
    late MockGetProfileInteractor mockGetProfile;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockDeleteFoodEventInteractor mockDeleteFoodEvent;
    late MockRemoveFoodEventInteractor mockRemoveFoodEvent;
    late MockUpdateEventsInteractor mockUpdateEvents;
    late MockPreferencesRepository mockPreferencesRepo;

    setUp(() {
      mockGetUserId = MockGetUserIdInteractor();
      mockGetFoodEvents = MockGetFoodEventsOfTodayInteractor();
      mockGetLiquidEvents = MockGetTodayLiquidEventsInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockDeleteFoodEvent = MockDeleteFoodEventInteractor();
      mockRemoveFoodEvent = MockRemoveFoodEventInteractor();
      mockUpdateEvents = MockUpdateEventsInteractor();
      mockPreferencesRepo = MockPreferencesRepository();
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
          preferencesRepository: mockPreferencesRepo,
          profileComputationService: _MockProfileComputationService(),
        );

    void stubAllInteractors() {
      when(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => <FoodEventComplete>[]);
      when(mockGetLiquidEvents.execute(dateTime: anyNamed('dateTime')))
          .thenAnswer((_) async => <LiquidEventComplete>[]);
    }

    test('food event bus notification triggers summary reload', () async {
      stubAllInteractors();

      final bloc = buildBloc();
      // Summary handler depends on state set during full init
      bloc.state.nutrientsInfoMaster = _stubNutrientsInfo;

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verify(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime'))).called(greaterThanOrEqualTo(1));

      await bloc.close();
    });

    test('sport event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verifyNever(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')));

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')));
    });
  });

  // ---------------------------------------------------------------------------
  // WeeklyDashboardDetailBloc EventBus
  // ---------------------------------------------------------------------------
  group('WeeklyDashboardDetailBloc EventBus', () {
    late MockGetWeekFoodEventsInteractor mockGetWeekFood;
    late MockGetUserMicronutrientsInteractor mockGetUserMicro;
    late MockGetUserRdasInteractor mockGetUserRdas;
    late MockGetProfileInteractor mockGetProfile;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockGetWeekLiquidEventsInteractor mockGetWeekLiquid;
    late MockGetWeekSportsInteractor mockGetWeekSports;

    setUp(() {
      mockGetWeekFood = MockGetWeekFoodEventsInteractor();
      mockGetUserMicro = MockGetUserMicronutrientsInteractor();
      mockGetUserRdas = MockGetUserRdasInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockGetWeekLiquid = MockGetWeekLiquidEventsInteractor();
      mockGetWeekSports = MockGetWeekSportsInteractor();
    });

    WeeklyDashboardDetailBloc buildBloc() => WeeklyDashboardDetailBloc(
          getWeekFoodEventsInteractor: mockGetWeekFood,
          getUserMicronutrientsInteractor: mockGetUserMicro,
          getUserRdasInteractor: mockGetUserRdas,
          getProfileInteractor: mockGetProfile,
          getMasterFileInteractor: mockGetMasterFile,
          getWeekLiquidEventsInteractor: mockGetWeekLiquid,
          getWeekSportsInteractor: mockGetWeekSports,
        );

    void stubAllInteractors() {
      when(mockGetUserMicro.execute()).thenAnswer((_) async => []);
      when(mockGetUserRdas.execute()).thenAnswer((_) async => []);
      when(mockGetMasterFile.execute(any)).thenAnswer((_) async => _stubNutrientsInfo);
      when(mockGetWeekFood.execute()).thenAnswer((_) async => <FoodEventComplete>[]);
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel());
      when(mockGetWeekLiquid.execute()).thenAnswer((_) async => <LiquidEventComplete>[]);
      when(mockGetWeekSports.execute()).thenAnswer((_) async => <SportEventComplete>[]);
    }

    for (final category in [
      DataChangedCategory.food,
      DataChangedCategory.sport,
      DataChangedCategory.liquid,
    ]) {
      test('$category event bus notification triggers reload', () async {
        stubAllInteractors();

        final bloc = buildBloc();

        DashboardEventBus.instance.notify(category);
        await pumpEventQueue();

        verify(mockGetWeekFood.execute()).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('supplement event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.supplement);
      await pumpEventQueue();

      verifyNever(mockGetWeekFood.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      stubAllInteractors();
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetWeekFood.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // MacroNutrientsDetailBloc EventBus
  // ---------------------------------------------------------------------------
  group('MacroNutrientsDetailBloc EventBus', () {
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockGetProfileInteractor mockGetProfile;
    late MockGetWeekFoodEventsInteractor mockGetWeekFood;

    setUp(() {
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockGetWeekFood = MockGetWeekFoodEventsInteractor();
    });

    MacroNutrientsDetailBloc buildBloc() => MacroNutrientsDetailBloc(
          getMasterFileInteractor: mockGetMasterFile,
          getProfileInteractor: mockGetProfile,
          getWeekFoodEventsInteractor: mockGetWeekFood,
        );

    void stubAllInteractors() {
      when(mockGetMasterFile.execute(any)).thenAnswer((_) async => _stubNutrientsInfo);
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel());
      when(mockGetWeekFood.execute()).thenAnswer((_) async => <FoodEventComplete>[]);
    }

    for (final category in [
      DataChangedCategory.food,
      DataChangedCategory.liquid,
    ]) {
      test('$category event bus notification triggers reload', () async {
        stubAllInteractors();

        final bloc = buildBloc();

        DashboardEventBus.instance.notify(category);
        await pumpEventQueue();

        verify(mockGetWeekFood.execute()).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('sport event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verifyNever(mockGetWeekFood.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetWeekFood.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // MicroNutrientsDetailBloc EventBus
  // ---------------------------------------------------------------------------
  group('MicroNutrientsDetailBloc EventBus', () {
    late MockGetWeekFoodEventsInteractor mockGetWeekFood;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockGetProfileInteractor mockGetProfile;
    late MockGetFoodEventsOfTodayInteractor mockGetFoodEvents;
    late MockGetDaySupplementEventsInteractor mockGetDaySupplements;

    setUp(() {
      mockGetWeekFood = MockGetWeekFoodEventsInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockGetFoodEvents = MockGetFoodEventsOfTodayInteractor();
      mockGetDaySupplements = MockGetDaySupplementEventsInteractor();
    });

    MicroNutrientsDetailBloc buildBloc() => MicroNutrientsDetailBloc(
          getWeekFoodEventsInteractor: mockGetWeekFood,
          getMasterFileInteractor: mockGetMasterFile,
          getProfileInteractor: mockGetProfile,
          getFoodEventsOfTodayInteractor: mockGetFoodEvents,
          getDaySupplementEventsInteractor: mockGetDaySupplements,
        );

    void stubAllInteractors() {
      when(mockGetWeekFood.execute()).thenAnswer((_) async => <FoodEventComplete>[]);
      // Return the master file matching the argument so callers can safely
      // cast — the detail bloc now also fetches supplementsInfo.
      when(mockGetMasterFile.execute(any)).thenAnswer((invocation) async {
        final type = invocation.positionalArguments.first as MasterFilesType;
        return type == MasterFilesType.supplementsInfo
            ? SupplementsInfoMaster(v: 1, data: [])
            : _stubNutrientsInfo;
      });
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel());
      when(mockGetFoodEvents.execute(dateTime: anyNamed('dateTime'))).thenAnswer((_) async => <FoodEventComplete>[]);
      when(mockGetDaySupplements.execute(dateTime: anyNamed('dateTime'))).thenAnswer((_) async => <SupplementSimple>[]);
    }

    for (final category in [
      DataChangedCategory.food,
      DataChangedCategory.supplement,
    ]) {
      test('$category event bus notification triggers reload', () async {
        stubAllInteractors();

        final bloc = buildBloc();

        DashboardEventBus.instance.notify(category);
        await pumpEventQueue();

        verify(mockGetWeekFood.execute()).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('sport event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verifyNever(mockGetWeekFood.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetWeekFood.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // EnergyBalanceDetailBloc EventBus
  // ---------------------------------------------------------------------------
  group('EnergyBalanceDetailBloc EventBus', () {
    late MockGetWeekFoodEventsInteractor mockGetWeekFood;
    late MockGetWeekLiquidEventsInteractor mockGetWeekLiquid;
    late MockGetWeekSportsInteractor mockGetWeekSports;
    late MockGetProfileInteractor mockGetProfile;

    setUp(() {
      mockGetWeekFood = MockGetWeekFoodEventsInteractor();
      mockGetWeekLiquid = MockGetWeekLiquidEventsInteractor();
      mockGetWeekSports = MockGetWeekSportsInteractor();
      mockGetProfile = MockGetProfileInteractor();
    });

    EnergyBalanceDetailBloc buildBloc() => EnergyBalanceDetailBloc(
          getWeekFoodEventsInteractor: mockGetWeekFood,
          getWeekLiquidEventsInteractor: mockGetWeekLiquid,
          getWeekSportsInteractor: mockGetWeekSports,
          getProfileInteractor: mockGetProfile,
        );

    void stubAllInteractors() {
      when(mockGetWeekFood.execute()).thenAnswer((_) async => <FoodEventComplete>[]);
      when(mockGetWeekLiquid.execute()).thenAnswer((_) async => <LiquidEventComplete>[]);
      when(mockGetWeekSports.execute()).thenAnswer((_) async => <SportEventComplete>[]);
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel());
    }

    for (final category in [
      DataChangedCategory.food,
      DataChangedCategory.liquid,
      DataChangedCategory.sport,
    ]) {
      test('$category event bus notification triggers reload', () async {
        stubAllInteractors();

        final bloc = buildBloc();

        DashboardEventBus.instance.notify(category);
        await pumpEventQueue();

        verify(mockGetWeekFood.execute()).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('supplement event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.supplement);
      await pumpEventQueue();

      verifyNever(mockGetWeekFood.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetWeekFood.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // JournalFoodBloc EventBus
  // ---------------------------------------------------------------------------
  group('JournalFoodBloc EventBus', () {
    late MockGetFoodEventsOfTodayInteractor mockGetFoodEvents;
    late MockGetFoodFavoritesInteractor mockGetFoodFavorites;
    late MockGetWeekFoodEventsInteractor mockGetWeekFood;
    late MockGetUserKcalInteractor mockGetUserKcal;
    late MockIsNecessaryToShowExplainingCardInteractor mockShowExplainingCard;
    late MockSaveExplainingCardInteractionInteractor mockSaveExplainingCard;
    late MockSaveFoodFavoriteInteractor mockSaveFoodFavorite;
    late MockUploadFoodFavoriteInteractor mockUploadFoodFavorite;
    late MockGetUserIdInteractor mockGetUserId;
    late MockRemoveFoodFavoriteFromLocalInteractor mockRemoveFoodFavorite;
    late MockDeleteFoodFavoriteInteractor mockDeleteFoodFavorite;
    late MockDeleteFoodEventInteractor mockDeleteFoodEvent;
    late MockRemoveFoodEventInteractor mockRemoveFoodEvent;

    setUp(() {
      mockGetFoodEvents = MockGetFoodEventsOfTodayInteractor();
      mockGetFoodFavorites = MockGetFoodFavoritesInteractor();
      mockGetWeekFood = MockGetWeekFoodEventsInteractor();
      mockGetUserKcal = MockGetUserKcalInteractor();
      mockShowExplainingCard = MockIsNecessaryToShowExplainingCardInteractor();
      mockSaveExplainingCard = MockSaveExplainingCardInteractionInteractor();
      mockSaveFoodFavorite = MockSaveFoodFavoriteInteractor();
      mockUploadFoodFavorite = MockUploadFoodFavoriteInteractor();
      mockGetUserId = MockGetUserIdInteractor();
      mockRemoveFoodFavorite = MockRemoveFoodFavoriteFromLocalInteractor();
      mockDeleteFoodFavorite = MockDeleteFoodFavoriteInteractor();
      mockDeleteFoodEvent = MockDeleteFoodEventInteractor();
      mockRemoveFoodEvent = MockRemoveFoodEventInteractor();
    });

    JournalFoodBloc buildBloc() => JournalFoodBloc(
          getFoodEventsOfTodayInteractor: mockGetFoodEvents,
          getFoodFavoritesInteractor: mockGetFoodFavorites,
          getWeekFoodEventsInteractor: mockGetWeekFood,
          getUserKcalInteractor: mockGetUserKcal,
          isNecessaryToShowExplainingCardInteractor: mockShowExplainingCard,
          saveExplainingCardInteractionInteractor: mockSaveExplainingCard,
          saveFoodFavoriteInteractor: mockSaveFoodFavorite,
          uploadFoodFavoriteInteractor: mockUploadFoodFavorite,
          getUserIdInteractor: mockGetUserId,
          removeFoodFavoriteFromLocalInteractor: mockRemoveFoodFavorite,
          deleteFoodFavoriteInteractor: mockDeleteFoodFavorite,
          deleteFoodEventInteractor: mockDeleteFoodEvent,
          removeFoodEventInteractor: mockRemoveFoodEvent,
        );

    void stubAllInteractors() {
      when(mockGetUserKcal.execute()).thenAnswer((_) async => 2000);
      when(mockGetFoodEvents.execute()).thenAnswer((_) async => <FoodEventComplete>[]);
      when(mockGetFoodFavorites.execute()).thenAnswer((_) async => []);
      when(mockGetWeekFood.execute()).thenAnswer((_) async => <FoodEventComplete>[]);
      when(mockShowExplainingCard.execute(any)).thenAnswer((_) async => false);
    }

    test('food event bus notification triggers reload', () async {
      stubAllInteractors();

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verify(mockGetFoodEvents.execute()).called(greaterThanOrEqualTo(1));

      await bloc.close();
    });

    test('sport event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verifyNever(mockGetFoodEvents.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetFoodEvents.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // JournalLiquidBloc EventBus
  // ---------------------------------------------------------------------------
  group('JournalLiquidBloc EventBus', () {
    late MockGetTodayLiquidEventsInteractor mockGetLiquidEvents;
    late MockGetWeekLiquidEventsInteractor mockGetWeekLiquid;
    late MockGetUserKcalInteractor mockGetUserKcal;
    late MockIsNecessaryToShowExplainingCardInteractor mockShowExplainingCard;
    late MockSaveExplainingCardInteractionInteractor mockSaveExplainingCard;
    late MockGetWaterEventsTodayInteractor mockGetWaterEvents;
    late MockGetProfileInteractor mockGetProfile;
    late MockDeleteLiquidEventInteractor mockDeleteLiquidEvent;
    late MockRemoveLiquidEventInteractor mockRemoveLiquidEvent;
    late MockGetUserIdInteractor mockGetUserId;

    setUp(() {
      mockGetLiquidEvents = MockGetTodayLiquidEventsInteractor();
      mockGetWeekLiquid = MockGetWeekLiquidEventsInteractor();
      mockGetUserKcal = MockGetUserKcalInteractor();
      mockShowExplainingCard = MockIsNecessaryToShowExplainingCardInteractor();
      mockSaveExplainingCard = MockSaveExplainingCardInteractionInteractor();
      mockGetWaterEvents = MockGetWaterEventsTodayInteractor();
      mockGetProfile = MockGetProfileInteractor();
      mockDeleteLiquidEvent = MockDeleteLiquidEventInteractor();
      mockRemoveLiquidEvent = MockRemoveLiquidEventInteractor();
      mockGetUserId = MockGetUserIdInteractor();
    });

    JournalLiquidBloc buildBloc() => JournalLiquidBloc(
          getLiquidEventsOfTodayInteractor: mockGetLiquidEvents,
          getWeekLiquidEventsInteractor: mockGetWeekLiquid,
          getUserKcalInteractor: mockGetUserKcal,
          isNecessaryToShowExplainingCardInteractor: mockShowExplainingCard,
          saveExplainingCardInteractionInteractor: mockSaveExplainingCard,
          getWaterEventsTodayInteractor: mockGetWaterEvents,
          getProfileInteractor: mockGetProfile,
          deleteLiquidEventInteractor: mockDeleteLiquidEvent,
          removeLiquidEventInteractor: mockRemoveLiquidEvent,
          getUserIdInteractor: mockGetUserId,
        );

    void stubAllInteractors() {
      when(mockGetUserKcal.execute()).thenAnswer((_) async => 2000);
      when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel());
      when(mockGetLiquidEvents.execute()).thenAnswer((_) async => <LiquidEventComplete>[]);
      when(mockGetWeekLiquid.execute()).thenAnswer((_) async => <LiquidEventComplete>[]);
      when(mockGetWaterEvents.execute()).thenAnswer((_) async => <WaterEventMaster>[]);
      when(mockShowExplainingCard.execute(any)).thenAnswer((_) async => false);
    }

    for (final category in [
      DataChangedCategory.liquid,
      DataChangedCategory.water,
    ]) {
      test('$category event bus notification triggers reload', () async {
        stubAllInteractors();

        final bloc = buildBloc();

        DashboardEventBus.instance.notify(category);
        await pumpEventQueue();

        verify(mockGetLiquidEvents.execute()).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('food event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetLiquidEvents.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.liquid);
      await pumpEventQueue();

      verifyNever(mockGetLiquidEvents.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // JournalSportBloc EventBus
  // ---------------------------------------------------------------------------
  group('JournalSportBloc EventBus', () {
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockGetUserKcalInteractor mockGetUserKcal;
    late MockGetTodaySportsInteractor mockGetTodaySports;
    late MockGetWeekSportsInteractor mockGetWeekSports;
    late MockIsNecessaryToShowExplainingCardInteractor mockShowExplainingCard;
    late MockSaveExplainingCardInteractionInteractor mockSaveExplainingCard;
    late MockGetSportFavoritesInteractor mockGetSportFavorites;
    late MockUploadSportFavoriteInteractor mockUploadSportFavorite;
    late MockSaveSportFavoriteInteractor mockSaveSportFavorite;
    late MockGetUserIdInteractor mockGetUserId;
    late MockDeleteSportFavoriteInteractor mockDeleteSportFavorite;
    late MockRemoveSportFavoriteInteractor mockRemoveSportFavorite;
    late MockDeleteSportEventInteractor mockDeleteSportEvent;
    late MockRemoveSportEventInteractor mockRemoveSportEvent;
    late MockEraseDBLocalEventsInteractor mockEraseDBLocalEvents;
    late MockSynchronizeEventsInteractor mockSynchronizeEvents;

    setUp(() {
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockGetUserKcal = MockGetUserKcalInteractor();
      mockGetTodaySports = MockGetTodaySportsInteractor();
      mockGetWeekSports = MockGetWeekSportsInteractor();
      mockShowExplainingCard = MockIsNecessaryToShowExplainingCardInteractor();
      mockSaveExplainingCard = MockSaveExplainingCardInteractionInteractor();
      mockGetSportFavorites = MockGetSportFavoritesInteractor();
      mockUploadSportFavorite = MockUploadSportFavoriteInteractor();
      mockSaveSportFavorite = MockSaveSportFavoriteInteractor();
      mockGetUserId = MockGetUserIdInteractor();
      mockDeleteSportFavorite = MockDeleteSportFavoriteInteractor();
      mockRemoveSportFavorite = MockRemoveSportFavoriteInteractor();
      mockDeleteSportEvent = MockDeleteSportEventInteractor();
      mockRemoveSportEvent = MockRemoveSportEventInteractor();
      mockEraseDBLocalEvents = MockEraseDBLocalEventsInteractor();
      mockSynchronizeEvents = MockSynchronizeEventsInteractor();
    });

    JournalSportBloc buildBloc() => JournalSportBloc(
          getMasterFileInteractor: mockGetMasterFile,
          getUserKcalInteractor: mockGetUserKcal,
          getTodaySportsInteractor: mockGetTodaySports,
          getWeekSportsInteractor: mockGetWeekSports,
          isNecessaryToShowExplainingCardInteractor: mockShowExplainingCard,
          saveExplainingCardInteractionInteractor: mockSaveExplainingCard,
          getSportFavoritesInteractor: mockGetSportFavorites,
          uploadSportFavoriteInteractor: mockUploadSportFavorite,
          saveSportFavoriteInteractor: mockSaveSportFavorite,
          getUserIdInteractor: mockGetUserId,
          deleteSportFavoriteInteractor: mockDeleteSportFavorite,
          removeSportFavoriteInteractor: mockRemoveSportFavorite,
          deleteSportEventInteractor: mockDeleteSportEvent,
          removeSportEventInteractor: mockRemoveSportEvent,
          eraseDBLocalEventsInteractor: mockEraseDBLocalEvents,
          synchronizeEventsInteractor: mockSynchronizeEvents,
        );

    void stubAllInteractors() {
      when(mockGetMasterFile.execute(any)).thenAnswer((_) async => null);
      when(mockGetUserKcal.execute()).thenAnswer((_) async => 2000);
      when(mockGetTodaySports.execute()).thenAnswer((_) async => <SportEventComplete>[]);
      when(mockGetSportFavorites.execute()).thenAnswer((_) async => []);
      when(mockGetWeekSports.execute()).thenAnswer((_) async => <SportEventComplete>[]);
      when(mockShowExplainingCard.execute(any)).thenAnswer((_) async => false);
    }

    test('sport event bus notification triggers reload', () async {
      stubAllInteractors();

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verify(mockGetTodaySports.execute()).called(greaterThanOrEqualTo(1));

      await bloc.close();
    });

    test('food event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetTodaySports.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verifyNever(mockGetTodaySports.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // RoutinesTabBloc EventBus
  // ---------------------------------------------------------------------------
  group('RoutinesTabBloc EventBus', () {
    late MockGetFoodRoutinesInteractor mockGetFoodRoutines;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockGetRoutinesInteractor mockGetRoutines;
    late MockGetSupplementRoutinesInteractor mockGetSupplementRoutines;
    late MockDeleteFoodRoutineInteractor mockDeleteFoodRoutine;
    late MockRemoveFoodRoutineInteractor mockRemoveFoodRoutine;
    late MockDeleteSportRoutineInteractor mockDeleteSportRoutine;
    late MockRemoveSportRoutineInteractor mockRemoveSportRoutine;
    late MockDeleteSupplementRoutineInteractor mockDeleteSupplementRoutine;
    late MockRemoveSupplementRoutineInteractor mockRemoveSupplementRoutine;

    setUp(() {
      mockGetFoodRoutines = MockGetFoodRoutinesInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockGetRoutines = MockGetRoutinesInteractor();
      mockGetSupplementRoutines = MockGetSupplementRoutinesInteractor();
      mockDeleteFoodRoutine = MockDeleteFoodRoutineInteractor();
      mockRemoveFoodRoutine = MockRemoveFoodRoutineInteractor();
      mockDeleteSportRoutine = MockDeleteSportRoutineInteractor();
      mockRemoveSportRoutine = MockRemoveSportRoutineInteractor();
      mockDeleteSupplementRoutine = MockDeleteSupplementRoutineInteractor();
      mockRemoveSupplementRoutine = MockRemoveSupplementRoutineInteractor();
    });

    RoutinesTabBloc buildBloc() => RoutinesTabBloc(
          getFoodRoutinesInteractor: mockGetFoodRoutines,
          getMasterFileInteractor: mockGetMasterFile,
          getRoutinesInteractor: mockGetRoutines,
          getSupplementRoutinesInteractor: mockGetSupplementRoutines,
          deleteFoodRoutineInteractor: mockDeleteFoodRoutine,
          removeFoodRoutineInteractor: mockRemoveFoodRoutine,
          deleteSportRoutineInteractor: mockDeleteSportRoutine,
          removeSportRoutineInteractor: mockRemoveSportRoutine,
          deleteSupplementRoutineInteractor: mockDeleteSupplementRoutine,
          removeSupplementRoutineInteractor: mockRemoveSupplementRoutine,
        );

    test('food event bus notification triggers meal routines re-fetch', () async {
      when(mockGetFoodRoutines.execute()).thenAnswer((_) async => <FoodRoutineEvent>[]);

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verify(mockGetFoodRoutines.execute()).called(1);
      verifyNever(mockGetRoutines.execute());
      verifyNever(mockGetSupplementRoutines.execute());

      await bloc.close();
    });

    test('sport event bus notification triggers sport routines re-fetch', () async {
      when(mockGetRoutines.execute()).thenAnswer((_) async => <SportRoutineCompleted>[]);

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verify(mockGetRoutines.execute()).called(1);
      verifyNever(mockGetFoodRoutines.execute());
      verifyNever(mockGetSupplementRoutines.execute());

      await bloc.close();
    });

    test('supplement event bus notification triggers supplement routines re-fetch', () async {
      when(mockGetSupplementRoutines.execute()).thenAnswer((_) async => <SupplementSimple>[]);

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.supplement);
      await pumpEventQueue();

      verify(mockGetSupplementRoutines.execute()).called(1);
      verifyNever(mockGetFoodRoutines.execute());
      verifyNever(mockGetRoutines.execute());

      await bloc.close();
    });

    test('water event bus notification does NOT trigger any routine re-fetch', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.water);
      await pumpEventQueue();

      verifyNever(mockGetFoodRoutines.execute());
      verifyNever(mockGetRoutines.execute());
      verifyNever(mockGetSupplementRoutines.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetFoodRoutines.execute());
    });
  });

  // ---------------------------------------------------------------------------
  // FavoritesTabsBloc EventBus
  // ---------------------------------------------------------------------------
  group('FavoritesTabsBloc EventBus', () {
    late MockGetFoodFavoritesInteractor mockGetFoodFavorites;
    late MockDeleteFoodFavoriteInteractor mockDeleteFoodFavorite;
    late MockRemoveFoodFavoriteFromLocalInteractor mockRemoveFoodFavorite;
    late MockGetUserIdInteractor mockGetUserId;
    late MockGetMasterFileInteractor mockGetMasterFile;
    late MockGetSportFavoritesInteractor mockGetSportFavorites;
    late MockGetSupplementFavoritesInteractor mockGetSupplementFavorites;
    late MockDeleteSportFavoriteInteractor mockDeleteSportFavorite;
    late MockRemoveSportFavoriteInteractor mockRemoveSportFavorite;
    late MockDeleteSupplementFavoriteInteractor mockDeleteSupplementFavorite;
    late MockRemoveSupplementFavoriteInteractor mockRemoveSupplementFavorite;

    setUp(() {
      mockGetFoodFavorites = MockGetFoodFavoritesInteractor();
      mockDeleteFoodFavorite = MockDeleteFoodFavoriteInteractor();
      mockRemoveFoodFavorite = MockRemoveFoodFavoriteFromLocalInteractor();
      mockGetUserId = MockGetUserIdInteractor();
      mockGetMasterFile = MockGetMasterFileInteractor();
      mockGetSportFavorites = MockGetSportFavoritesInteractor();
      mockGetSupplementFavorites = MockGetSupplementFavoritesInteractor();
      mockDeleteSportFavorite = MockDeleteSportFavoriteInteractor();
      mockRemoveSportFavorite = MockRemoveSportFavoriteInteractor();
      mockDeleteSupplementFavorite = MockDeleteSupplementFavoriteInteractor();
      mockRemoveSupplementFavorite = MockRemoveSupplementFavoriteInteractor();
    });

    FavoritesTabsBloc buildBloc() => FavoritesTabsBloc(
          getFoodFavoritesInteractor: mockGetFoodFavorites,
          deleteFoodFavoriteInteractor: mockDeleteFoodFavorite,
          removeFoodFavoriteFromLocalInteractor: mockRemoveFoodFavorite,
          getUserIdInteractor: mockGetUserId,
          getMasterFileInteractor: mockGetMasterFile,
          getSportFavoritesInteractor: mockGetSportFavorites,
          getSupplementFavoritesInteractor: mockGetSupplementFavorites,
          deleteSportFavoriteInteractor: mockDeleteSportFavorite,
          removeSportFavoriteInteractor: mockRemoveSportFavorite,
          deleteSupplementFavoriteInteractor: mockDeleteSupplementFavorite,
          removeSupplementFavoriteInteractor: mockRemoveSupplementFavorite,
        );

    test('food event bus notification triggers food favorites re-fetch', () async {
      when(mockGetFoodFavorites.execute()).thenAnswer((_) async => <FoodFavorite>[]);

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verify(mockGetFoodFavorites.execute()).called(1);
      verifyNever(mockGetSportFavorites.execute());
      verifyNever(mockGetSupplementFavorites.execute());

      await bloc.close();
    });

    test('sport event bus notification triggers sport favorites re-fetch', () async {
      when(mockGetSportFavorites.execute()).thenAnswer((_) async => <AddSportFavorite>[]);

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await pumpEventQueue();

      verify(mockGetSportFavorites.execute()).called(1);
      verifyNever(mockGetFoodFavorites.execute());
      verifyNever(mockGetSupplementFavorites.execute());

      await bloc.close();
    });

    test('supplement event bus notification triggers supplement favorites re-fetch', () async {
      when(mockGetSupplementFavorites.execute()).thenAnswer((_) async => <SupplementSimple>[]);

      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.supplement);
      await pumpEventQueue();

      verify(mockGetSupplementFavorites.execute()).called(1);
      verifyNever(mockGetFoodFavorites.execute());
      verifyNever(mockGetSportFavorites.execute());

      await bloc.close();
    });

    test('water event bus notification does NOT trigger any favorites re-fetch', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.water);
      await pumpEventQueue();

      verifyNever(mockGetFoodFavorites.execute());
      verifyNever(mockGetSportFavorites.execute());
      verifyNever(mockGetSupplementFavorites.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await pumpEventQueue();

      verifyNever(mockGetFoodFavorites.execute());
    });
  });
}
