import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:nutrenaissance_flutter/data/api/routines/routines_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodroutines/food_routines_api.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/supplemets_api.dart';
import 'package:nutrenaissance_flutter/data/repository/routines/routines_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/foodroutines/food_routines_repository_impl.dart';
import 'package:nutrenaissance_flutter/data/repository/supplements/supplements_repository_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_routine.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

@GenerateNiceMocks([
  MockSpec<RoutinesApi>(),
  MockSpec<FoodRoutinesApi>(),
  MockSpec<SupplementApi>(),
  MockSpec<LocalStorageRepository>(),
  MockSpec<SyncQueueService>(),
])
import 'routine_fire_and_forget_test.mocks.dart';

void main() {
  // -------------------------------------------------------------------------
  // Sport Routines
  // -------------------------------------------------------------------------
  group('RoutinesRepositoryImpl (sport routines)', () {
    late MockRoutinesApi mockApi;
    late MockLocalStorageRepository mockLocalStorage;
    late MockSyncQueueService mockSyncQueue;
    late RoutinesRepositoryImpl repo;

    setUp(() {
      mockApi = MockRoutinesApi();
      mockLocalStorage = MockLocalStorageRepository();
      mockSyncQueue = MockSyncQueueService();
      repo = RoutinesRepositoryImpl(
        routinesApi: mockApi,
        localStorageRepository: mockLocalStorage,
        syncQueue: mockSyncQueue,
      );
    });

    SportRoutineCompleted _makeSportRoutine() => SportRoutineCompleted(
          userId: 'user-123',
          eventId: 1001,
          eventDate: 1700000000000,
          sportName: 'Running',
          isRoutine: true,
          daysOfWeek: [1, 3, 5],
          scheduleTime: '08:00',
          timeZone: 'Europe/Madrid',
        );

    group('uploadRoutine', () {
      test('returns true immediately without awaiting API', () async {
        final completer = Completer<Map<String, dynamic>>();
        when(mockApi.uploadRoutine(any)).thenAnswer((_) => completer.future);

        final result = await repo.uploadRoutine(_makeSportRoutine());

        expect(result, isTrue);
        // API future is still pending — proves we didn't await it
        verifyNever(mockSyncQueue.enqueue(any, any));
        completer.complete({'success': true});
      });

      test('enqueues to sync queue on API failure', () async {
        when(mockApi.uploadRoutine(any))
            .thenAnswer((_) => Future.error(Exception('network error')));

        await repo.uploadRoutine(_makeSportRoutine());
        // Let the microtask (catchError) execute
        await Future.delayed(Duration.zero);

        verify(mockSyncQueue.enqueue('/sport-routine/v2', any)).called(1);
      });

      test('does not enqueue on API success', () async {
        when(mockApi.uploadRoutine(any))
            .thenAnswer((_) async => {'success': true});

        await repo.uploadRoutine(_makeSportRoutine());
        await Future.delayed(Duration.zero);

        verifyNever(mockSyncQueue.enqueue(any, any));
      });
    });

    group('deleteSportRoutine', () {
      test('does not await API call', () async {
        final completer = Completer<Map<String, dynamic>>();
        when(mockApi.deleteSportRoutine(any, any))
            .thenAnswer((_) => completer.future);

        await repo.deleteSportRoutine('user-123', 1001);

        // Method returned while API is still pending
        verifyNever(mockSyncQueue.enqueueDelete(any, any));
        completer.complete({'success': true});
      });

      test('enqueues DELETE to sync queue on API failure', () async {
        when(mockApi.deleteSportRoutine(any, any))
            .thenAnswer((_) => Future.error(Exception('network error')));

        await repo.deleteSportRoutine('user-123', 1001);
        await Future.delayed(Duration.zero);

        verify(mockSyncQueue.enqueueDelete(
          '/sport-routine/v2',
          {'userId': 'user-123', 'eventId': 1001},
        )).called(1);
      });

      test('does not enqueue on API success', () async {
        when(mockApi.deleteSportRoutine(any, any))
            .thenAnswer((_) async => {'success': true});

        await repo.deleteSportRoutine('user-123', 1001);
        await Future.delayed(Duration.zero);

        verifyNever(mockSyncQueue.enqueueDelete(any, any));
      });
    });
  });

  // -------------------------------------------------------------------------
  // Food Routines
  // -------------------------------------------------------------------------
  group('FoodRoutinesRepositoryImpl', () {
    late MockFoodRoutinesApi mockApi;
    late MockLocalStorageRepository mockLocalStorage;
    late MockSyncQueueService mockSyncQueue;
    late FoodRoutinesRepositoryImpl repo;

    setUp(() {
      mockApi = MockFoodRoutinesApi();
      mockLocalStorage = MockLocalStorageRepository();
      mockSyncQueue = MockSyncQueueService();
      repo = FoodRoutinesRepositoryImpl(
        foodRoutinesApi: mockApi,
        localStorageRepository: mockLocalStorage,
        syncQueue: mockSyncQueue,
      );
    });

    FoodRoutineEvent _makeFoodRoutine() => FoodRoutineEvent(
          userId: 'user-456',
          eventDate: 1700000000000,
          eventId: 2002,
          foodName: 'Oatmeal Breakfast',
          comment: '',
          isRoutine: true,
          daysOfWeek: [1, 2, 3, 4, 5],
          time: '07:30',
          timeZone: 'Europe/Madrid',
        );

    group('uploadRoutine', () {
      test('returns true immediately without awaiting API', () async {
        final completer = Completer<Map<String, dynamic>>();
        when(mockApi.uploadRoutine(any)).thenAnswer((_) => completer.future);

        final result = await repo.uploadRoutine(_makeFoodRoutine());

        expect(result, isTrue);
        verifyNever(mockSyncQueue.enqueue(any, any));
        completer.complete({'success': true});
      });

      test('enqueues to sync queue on API failure', () async {
        when(mockApi.uploadRoutine(any))
            .thenAnswer((_) => Future.error(Exception('network error')));

        await repo.uploadRoutine(_makeFoodRoutine());
        await Future.delayed(Duration.zero);

        verify(mockSyncQueue.enqueue('/food-routines', any)).called(1);
      });

      test('does not enqueue on API success', () async {
        when(mockApi.uploadRoutine(any))
            .thenAnswer((_) async => {'success': true});

        await repo.uploadRoutine(_makeFoodRoutine());
        await Future.delayed(Duration.zero);

        verifyNever(mockSyncQueue.enqueue(any, any));
      });
    });

    group('deleteFoodRoutine', () {
      test('does not await API call', () async {
        final completer = Completer<Map<String, dynamic>>();
        when(mockApi.deleteRoutine(any))
            .thenAnswer((_) => completer.future);

        final routine = _makeFoodRoutine();
        await repo.deleteFoodRoutine(routine);

        verifyNever(mockSyncQueue.enqueueDelete(any, any));
        completer.complete({'success': true});
      });

      test('enqueues DELETE to sync queue on API failure', () async {
        when(mockApi.deleteRoutine(any))
            .thenAnswer((_) => Future.error(Exception('network error')));

        final routine = _makeFoodRoutine();
        await repo.deleteFoodRoutine(routine);
        await Future.delayed(Duration.zero);

        verify(mockSyncQueue.enqueueDelete(
          '/food-routines',
          {'userId': 'user-456', 'eventId': 2002},
        )).called(1);
      });

      test('does not enqueue on API success', () async {
        when(mockApi.deleteRoutine(any))
            .thenAnswer((_) async => {'success': true});

        final routine = _makeFoodRoutine();
        await repo.deleteFoodRoutine(routine);
        await Future.delayed(Duration.zero);

        verifyNever(mockSyncQueue.enqueueDelete(any, any));
      });
    });
  });

  // -------------------------------------------------------------------------
  // Supplement Routines
  // -------------------------------------------------------------------------
  group('SupplementsRepositoryImpl (routine methods)', () {
    late MockSupplementApi mockApi;
    late MockLocalStorageRepository mockLocalStorage;
    late MockSyncQueueService mockSyncQueue;
    late SupplementsRepositoryImpl repo;

    setUp(() {
      mockApi = MockSupplementApi();
      mockLocalStorage = MockLocalStorageRepository();
      mockSyncQueue = MockSyncQueueService();
      repo = SupplementsRepositoryImpl(
        supplementApi: mockApi,
        localStorageRepository: mockLocalStorage,
        syncQueue: mockSyncQueue,
      );
    });

    UploadSupplementRoutine _makeSupplementRoutine() =>
        UploadSupplementRoutine(
          userId: 'user-789',
          eventId: 3003,
          eventDate: 1700000000000,
          info: [
            UploadSupplementRoutineInfo(id: 1, amount: 5, unit: 'g'),
          ],
          name: 'Creatine routine',
          time: '09:00',
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
          timeZone: 'Europe/Madrid',
        );

    SupplementSimple _makeSupplementSimple() => SupplementSimple(
          userId: 'user-789',
          eventId: 3003,
          eventDate: 1700000000000,
          isRoutine: true,
        );

    group('uploadSupplementRoutine', () {
      test('does not await API call', () async {
        final completer = Completer<Map<String, dynamic>>();
        when(mockApi.uploadSupplementRoutine(any))
            .thenAnswer((_) => completer.future);

        await repo.uploadSupplementRoutine(_makeSupplementRoutine());

        verifyNever(mockSyncQueue.enqueue(any, any));
        completer.complete({'success': true});
      });

      test('enqueues to sync queue on API failure', () async {
        when(mockApi.uploadSupplementRoutine(any))
            .thenAnswer((_) => Future.error(Exception('network error')));

        await repo.uploadSupplementRoutine(_makeSupplementRoutine());
        await Future.delayed(Duration.zero);

        verify(mockSyncQueue.enqueue('/supplement-routines', any)).called(1);
      });

      test('does not enqueue on API success', () async {
        when(mockApi.uploadSupplementRoutine(any))
            .thenAnswer((_) async => {'success': true});

        await repo.uploadSupplementRoutine(_makeSupplementRoutine());
        await Future.delayed(Duration.zero);

        verifyNever(mockSyncQueue.enqueue(any, any));
      });
    });

    group('deleteSupplementRoutine', () {
      test('does not await API call', () async {
        final completer = Completer<Map<String, dynamic>>();
        when(mockApi.deleteSupplementRoutine(any))
            .thenAnswer((_) => completer.future);

        await repo.deleteSupplementRoutine(_makeSupplementSimple());

        verifyNever(mockSyncQueue.enqueueDelete(any, any));
        completer.complete({'success': true});
      });

      test('enqueues DELETE to sync queue on API failure', () async {
        when(mockApi.deleteSupplementRoutine(any))
            .thenAnswer((_) => Future.error(Exception('network error')));

        await repo.deleteSupplementRoutine(_makeSupplementSimple());
        await Future.delayed(Duration.zero);

        verify(mockSyncQueue.enqueueDelete(
          '/supplement-routines',
          {'userId': 'user-789', 'eventId': 3003},
        )).called(1);
      });

      test('does not enqueue on API success', () async {
        when(mockApi.deleteSupplementRoutine(any))
            .thenAnswer((_) async => {'success': true});

        await repo.deleteSupplementRoutine(_makeSupplementSimple());
        await Future.delayed(Duration.zero);

        verifyNever(mockSyncQueue.enqueueDelete(any, any));
      });
    });
  });
}
