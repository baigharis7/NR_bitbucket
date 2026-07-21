import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_actions.dart';
import 'package:nutrenaissance_flutter/presentation/calendar/bloc/calendar_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetAllEventsSortedByDateInteractor mockGetAllEvents;
  late MockGetUserIdInteractor mockGetUserId;
  late MockRemoveFoodEventInteractor mockRemoveFoodEvent;
  late MockDeleteFoodEventInteractor mockDeleteFoodEvent;
  late MockRemoveSportEventInteractor mockRemoveSportEvent;
  late MockDeleteSportEventInteractor mockDeleteSportEvent;
  late MockHealthSyncRepository mockHealthSyncRepository;

  setUp(() {
    mockGetAllEvents = MockGetAllEventsSortedByDateInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockRemoveFoodEvent = MockRemoveFoodEventInteractor();
    mockDeleteFoodEvent = MockDeleteFoodEventInteractor();
    mockRemoveSportEvent = MockRemoveSportEventInteractor();
    mockDeleteSportEvent = MockDeleteSportEventInteractor();
    mockHealthSyncRepository = MockHealthSyncRepository();
  });

  // Deliberately omits healthSyncRepository to prove it remains optional —
  // all pre-existing tests below build via this function unchanged.
  CalendarBloc buildBloc() => CalendarBloc(
        getAllEventsSortedByDateInteractor: mockGetAllEvents,
        getUserIdInteractor: mockGetUserId,
        removeFoodEventInteractor: mockRemoveFoodEvent,
        deleteFoodEventInteractor: mockDeleteFoodEvent,
        removeSportEventInteractor: mockRemoveSportEvent,
        deleteSportEventInteractor: mockDeleteSportEvent,
      );

  CalendarBloc buildBlocWithHealthSync() => CalendarBloc(
        getAllEventsSortedByDateInteractor: mockGetAllEvents,
        getUserIdInteractor: mockGetUserId,
        removeFoodEventInteractor: mockRemoveFoodEvent,
        deleteFoodEventInteractor: mockDeleteFoodEvent,
        removeSportEventInteractor: mockRemoveSportEvent,
        deleteSportEventInteractor: mockDeleteSportEvent,
        healthSyncRepository: mockHealthSyncRepository,
      );

  group('CalendarBloc', () {
    blocTest<CalendarBloc, CalendarState>(
      'initial state is not loading with empty calendar events',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.allCalendarEvents, isNotNull);
        expect(bloc.state.dayEvents, isEmpty);
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'InitializeStateAction loads all calendar events',
      build: () {
        when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeStateAction()),
      expect: () => [
        isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
        isA<CalendarState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockGetAllEvents.execute()).called(1);
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'RefreshEventsAction reloads events and updates day events',
      build: () {
        when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(RefreshEventsAction(selectedDay: DateTime(2026, 2, 17))),
      expect: () => [
        isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
        isA<CalendarState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockGetAllEvents.execute()).called(1);
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'RemoveFoodEventAction deletes remotely and locally on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteFoodEvent.execute(any, any)).thenAnswer((_) async => true);
        when(mockRemoveFoodEvent.execute(any)).thenAnswer((_) async => true);
        when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveFoodEventAction(
        foodEventComplete: FoodEventComplete(userId: 'user123', eventDate: 1000, eventId: 1),
        onFinish: () {},
      )),
      verify: (bloc) {
        verify(mockDeleteFoodEvent.execute('user123', 1000)).called(1);
        verify(mockRemoveFoodEvent.execute(any)).called(1);
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'RemoveFoodEventAction emits error when remote delete fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteFoodEvent.execute(any, any)).thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveFoodEventAction(
        foodEventComplete: FoodEventComplete(userId: 'user123', eventDate: 1000, eventId: 1),
        onFinish: () {},
      )),
      expect: () => [
        isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
        isA<CalendarState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteFoodFavoriteError),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'RemoveFoodEventAction emits error when local remove fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteFoodEvent.execute(any, any)).thenAnswer((_) async => true);
        when(mockRemoveFoodEvent.execute(any)).thenThrow(Exception('local fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveFoodEventAction(
        foodEventComplete: FoodEventComplete(userId: 'user123', eventDate: 1000, eventId: 1),
        onFinish: () {},
      )),
      expect: () => [
        isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
        isA<CalendarState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.removeFoodFavoriteError),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'RemoveSportEventAction deletes remotely and locally on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 1, eventDate: 1000, info: []),
        onFinish: () {},
      )),
      verify: (bloc) {
        verify(mockDeleteSportEvent.execute('user123', 1)).called(1);
        verify(mockRemoveSportEvent.execute(any)).called(1);
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'RemoveSportEventAction emits error when remote delete fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportEvent.execute(any, any)).thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 1, eventDate: 1000, info: []),
        onFinish: () {},
      )),
      expect: () => [
        isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
        isA<CalendarState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteSportFavoriteError),
      ],
    );

    blocTest<CalendarBloc, CalendarState>(
      'RemoveSportEventAction tombstones health sync metadata for a health-synced event',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());
        when(mockHealthSyncRepository.tombstoneSyncMetadataBySportEventId(any)).thenAnswer((_) async {});
        return buildBlocWithHealthSync();
      },
      act: (bloc) => bloc.add(RemoveSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 42, eventDate: 86400000, info: [], source: 'health_connect'),
        onFinish: () {},
      )),
      verify: (bloc) {
        verify(mockHealthSyncRepository.tombstoneSyncMetadataBySportEventId(42)).called(1);
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'RemoveSportEventAction never tombstones a manual event',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());
        return buildBlocWithHealthSync();
      },
      act: (bloc) => bloc.add(RemoveSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 42, eventDate: 86400000, info: [], source: 'manual'),
        onFinish: () {},
      )),
      verify: (bloc) {
        verifyNever(mockHealthSyncRepository.tombstoneSyncMetadataBySportEventId(any));
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'RemoveSportEventAction never tombstones a null-source event',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());
        return buildBlocWithHealthSync();
      },
      act: (bloc) => bloc.add(RemoveSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 42, eventDate: 86400000, info: []),
        onFinish: () {},
      )),
      verify: (bloc) {
        verifyNever(mockHealthSyncRepository.tombstoneSyncMetadataBySportEventId(any));
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'RemoveSportEventAction does not crash for a health-synced event when constructed without healthSyncRepository',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(mockGetAllEvents.execute()).thenAnswer((_) async => CalendarEvents.empty());
        return buildBloc();
      },
      act: (bloc) => bloc.add(RemoveSportEventAction(
        sportEventComplete: SportEventComplete(userId: 'user123', eventId: 42, eventDate: 86400000, info: [], source: 'health_connect'),
        onFinish: () {},
      )),
      verify: (bloc) {
        expect(bloc.state.onError, isNull);
      },
    );
  });
}
