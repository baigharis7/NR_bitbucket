import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
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
import 'package:nutrenaissance_flutter/presentation/updatesupplement/bloc/update_supplement_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

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
      await Future.delayed(const Duration(milliseconds: 100));

      verify(mockGetTodaySports.execute(dateTime: anyNamed('dateTime'))).called(1);

      await bloc.close();
    });

    test('non-sport event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await Future.delayed(const Duration(milliseconds: 100));

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
      await Future.delayed(const Duration(milliseconds: 200));

      expect(notifications, contains(DataChangedCategory.sport));

      await sub.cancel();
      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      // After close, notifications should not trigger events
      DashboardEventBus.instance.notify(DataChangedCategory.sport);
      await Future.delayed(const Duration(milliseconds: 100));

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
        await Future.delayed(const Duration(milliseconds: 100));

        verify(mockGetAllEvents.execute()).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('profile event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.profile);
      await Future.delayed(const Duration(milliseconds: 100));

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
      await Future.delayed(const Duration(milliseconds: 200));

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
      await Future.delayed(const Duration(milliseconds: 200));

      expect(notifications, contains(DataChangedCategory.sport));

      await sub.cancel();
      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await Future.delayed(const Duration(milliseconds: 100));

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
        await Future.delayed(const Duration(milliseconds: 100));

        verify(mockGetUserKcal.execute()).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('supplement event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.supplement);
      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(mockGetUserKcal.execute());

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await Future.delayed(const Duration(milliseconds: 100));

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
        await Future.delayed(const Duration(milliseconds: 100));

        verify(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime'))).called(greaterThanOrEqualTo(1));

        await bloc.close();
      });
    }

    test('food event bus notification does NOT trigger reload', () async {
      final bloc = buildBloc();

      DashboardEventBus.instance.notify(DataChangedCategory.food);
      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(mockGetWaterEvents.execute(dateTime: anyNamed('dateTime')));

      await bloc.close();
    });

    test('close cancels event bus subscription', () async {
      final bloc = buildBloc();
      await bloc.close();

      DashboardEventBus.instance.notify(DataChangedCategory.liquid);
      await Future.delayed(const Duration(milliseconds: 100));

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
      await Future.delayed(const Duration(milliseconds: 200));

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
      await Future.delayed(const Duration(milliseconds: 200));

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
      await Future.delayed(const Duration(milliseconds: 200));

      expect(notifications, isNot(contains(DataChangedCategory.supplement)));

      await sub.cancel();
      await bloc.close();
    });
  });
}
