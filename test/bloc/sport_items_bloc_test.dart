import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/sportitems/bloc/sport_items_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetUserIdInteractor mockGetUserId;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockGetTodaySportsInteractor mockGetTodaySports;
  late MockDeleteSportEventInteractor mockDeleteSportEvent;
  late MockRemoveSportEventInteractor mockRemoveSportEvent;
  late MockUpdateEventsInteractor mockUpdateEvents;
  late MockHealthSyncRepository mockHealthSyncRepository;

  setUp(() {
    mockGetUserId = MockGetUserIdInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockGetTodaySports = MockGetTodaySportsInteractor();
    mockDeleteSportEvent = MockDeleteSportEventInteractor();
    mockRemoveSportEvent = MockRemoveSportEventInteractor();
    mockUpdateEvents = MockUpdateEventsInteractor();
    mockHealthSyncRepository = MockHealthSyncRepository();
  });

  SportItemsBloc buildBloc({bool withHealthSyncRepository = true}) => SportItemsBloc(
    getUserIdInteractor: mockGetUserId,
    getMasterFileInteractor: mockGetMasterFile,
    getTodaySportsInteractor: mockGetTodaySports,
    deleteSportEventInteractor: mockDeleteSportEvent,
    removeSportEventInteractor: mockRemoveSportEvent,
    updateEventsInteractor: mockUpdateEvents,
    healthSyncRepository: withHealthSyncRepository ? mockHealthSyncRepository : null,
  );

  group('SportItemsBloc', () {
    blocTest<SportItemsBloc, SportItemsState>(
      'DeleteSportItemSportItemsEvents deletes remotely and locally on success',
      build: () {
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(
          mockGetTodaySports.execute(dateTime: anyNamed('dateTime')),
        ).thenAnswer((_) async => <SportEventComplete>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        DeleteSportItemSportItemsEvents(
          sportEventComplete: SportEventComplete(
            userId: 'user123',
            eventId: 1,
            eventDate: 1000,
            info: [],
          ),
        ),
      ),
      verify: (bloc) {
        verify(mockDeleteSportEvent.execute('user123', 1)).called(1);
        verify(mockRemoveSportEvent.execute(any)).called(1);
      },
    );

    blocTest<SportItemsBloc, SportItemsState>(
      'DeleteSportItemSportItemsEvents emits error when remote delete fails',
      build: () {
        when(
          mockDeleteSportEvent.execute(any, any),
        ).thenThrow(Exception('fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        DeleteSportItemSportItemsEvents(
          sportEventComplete: SportEventComplete(
            userId: 'user123',
            eventId: 1,
            eventDate: 1000,
            info: [],
          ),
        ),
      ),
      expect: () => [
        isA<SportItemsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having(
              (s) => s.onError,
              'onError',
              ErrorTypes.deleteSportEventError,
            ),
      ],
    );

    blocTest<SportItemsBloc, SportItemsState>(
      'DeleteSportItemSportItemsEvents tombstones health sync metadata for a health-synced event',
      build: () {
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(mockHealthSyncRepository.tombstoneSyncMetadataBySportEventId(any)).thenAnswer((_) async {});
        when(
          mockGetTodaySports.execute(dateTime: anyNamed('dateTime')),
        ).thenAnswer((_) async => <SportEventComplete>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        DeleteSportItemSportItemsEvents(
          sportEventComplete: SportEventComplete(
            userId: 'user123',
            eventId: 42,
            eventDate: 86400000,
            info: [],
            source: 'health_connect',
          ),
        ),
      ),
      verify: (bloc) {
        verify(mockHealthSyncRepository.tombstoneSyncMetadataBySportEventId(42)).called(1);
      },
    );

    blocTest<SportItemsBloc, SportItemsState>(
      'DeleteSportItemSportItemsEvents never tombstones a manual event',
      build: () {
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(
          mockGetTodaySports.execute(dateTime: anyNamed('dateTime')),
        ).thenAnswer((_) async => <SportEventComplete>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        DeleteSportItemSportItemsEvents(
          sportEventComplete: SportEventComplete(
            userId: 'user123',
            eventId: 42,
            eventDate: 86400000,
            info: [],
            source: 'manual',
          ),
        ),
      ),
      verify: (bloc) {
        verifyNever(mockHealthSyncRepository.tombstoneSyncMetadataBySportEventId(any));
      },
    );

    blocTest<SportItemsBloc, SportItemsState>(
      'DeleteSportItemSportItemsEvents never tombstones a null-source event',
      build: () {
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(
          mockGetTodaySports.execute(dateTime: anyNamed('dateTime')),
        ).thenAnswer((_) async => <SportEventComplete>[]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        DeleteSportItemSportItemsEvents(
          sportEventComplete: SportEventComplete(
            userId: 'user123',
            eventId: 42,
            eventDate: 86400000,
            info: [],
          ),
        ),
      ),
      verify: (bloc) {
        verifyNever(mockHealthSyncRepository.tombstoneSyncMetadataBySportEventId(any));
      },
    );

    blocTest<SportItemsBloc, SportItemsState>(
      'DeleteSportItemSportItemsEvents does not crash for a health-synced event when healthSyncRepository is null',
      build: () {
        when(mockDeleteSportEvent.execute(any, any)).thenAnswer((_) async {});
        when(mockRemoveSportEvent.execute(any)).thenAnswer((_) async {});
        when(
          mockGetTodaySports.execute(dateTime: anyNamed('dateTime')),
        ).thenAnswer((_) async => <SportEventComplete>[]);
        return buildBloc(withHealthSyncRepository: false);
      },
      act: (bloc) => bloc.add(
        DeleteSportItemSportItemsEvents(
          sportEventComplete: SportEventComplete(
            userId: 'user123',
            eventId: 42,
            eventDate: 86400000,
            info: [],
            source: 'health_connect',
          ),
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.onError, isNull);
      },
    );
  });
}
