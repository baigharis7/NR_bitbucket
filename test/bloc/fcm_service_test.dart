import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/fcm_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetUserIdInteractor mockGetUserId;
  late MockUpdateEventsInteractor mockUpdateEvents;
  late MockSynchronizeEventsInteractor mockSynchronizeEvents;

  setUp(() {
    mockGetUserId = MockGetUserIdInteractor();
    mockUpdateEvents = MockUpdateEventsInteractor();
    mockSynchronizeEvents = MockSynchronizeEventsInteractor();

    FcmService.instance.configureSyncHandler(
      getUserIdInteractor: mockGetUserId,
      updateEventsInteractor: mockUpdateEvents,
      synchronizeEventsInteractor: mockSynchronizeEvents,
    );
  });

  group('FcmService FCM sync handler', () {
    test('food FCM syncs foodEvents and notifies event bus with food', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async => true);

      final busEvents = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(busEvents.add);

      FcmService.instance.simulateMessage(RemoteMessage(data: {'category': 'food'}));
      await pumpEventQueue();

      verify(mockUpdateEvents.execute(userId: 'user123', categoryType: PrefsKeys.foodEvents, fullSync: false)).called(1);
      verifyNever(mockSynchronizeEvents.execute(any, fullSync: anyNamed('fullSync')));
      expect(busEvents, contains(DataChangedCategory.food));

      await sub.cancel();
    });

    test('sport FCM syncs sportEvents and notifies event bus with sport', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async => true);

      final busEvents = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(busEvents.add);

      FcmService.instance.simulateMessage(RemoteMessage(data: {'category': 'sport'}));
      await pumpEventQueue();

      verify(mockUpdateEvents.execute(userId: 'user123', categoryType: PrefsKeys.sportEvents, fullSync: false)).called(1);
      expect(busEvents, contains(DataChangedCategory.sport));

      await sub.cancel();
    });

    test('supplement FCM syncs supplementEvents and notifies event bus with supplement', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async => true);

      final busEvents = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(busEvents.add);

      FcmService.instance.simulateMessage(RemoteMessage(data: {'category': 'supplement'}));
      await pumpEventQueue();

      verify(mockUpdateEvents.execute(userId: 'user123', categoryType: PrefsKeys.supplementEvents, fullSync: false)).called(1);
      expect(busEvents, contains(DataChangedCategory.supplement));

      await sub.cancel();
    });

    test('unknown category falls back to full synchronizeEvents', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockSynchronizeEvents.execute(any, fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async {});

      FcmService.instance.simulateMessage(RemoteMessage(data: {'category': 'unknown'}));
      await pumpEventQueue();

      verify(mockSynchronizeEvents.execute('user123', fullSync: false)).called(1);
      verifyNever(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')));
    });

    test('null category falls back to full synchronizeEvents', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockSynchronizeEvents.execute(any, fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async {});

      FcmService.instance.simulateMessage(RemoteMessage(data: {}));
      await pumpEventQueue();

      verify(mockSynchronizeEvents.execute('user123', fullSync: false)).called(1);
    });

    test('empty userId skips sync entirely', () async {
      when(mockGetUserId.execute()).thenReturn('');

      final busEvents = <DataChangedCategory>[];
      final sub = DashboardEventBus.instance.stream.listen(busEvents.add);

      FcmService.instance.simulateMessage(RemoteMessage(data: {'category': 'food'}));
      await pumpEventQueue();

      verifyNever(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')));
      verifyNever(mockSynchronizeEvents.execute(any, fullSync: anyNamed('fullSync')));
      expect(busEvents, isEmpty);

      await sub.cancel();
    });

    test('retries with full sync on failure', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
          .thenThrow(Exception('network error'));
      when(mockSynchronizeEvents.execute(any, fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async {});

      FcmService.instance.simulateMessage(RemoteMessage(data: {'category': 'food'}));
      await Future.delayed(const Duration(seconds: 6));

      verify(mockUpdateEvents.execute(userId: 'user123', categoryType: PrefsKeys.foodEvents, fullSync: false)).called(1);
      verify(mockSynchronizeEvents.execute('user123', fullSync: false)).called(1);
    });
  });

  group('FcmService triggerSync', () {
    test('calls synchronizeEvents with current userId', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockSynchronizeEvents.execute(any, fullSync: anyNamed('fullSync')))
          .thenAnswer((_) async {});

      await FcmService.instance.triggerSync();

      verify(mockSynchronizeEvents.execute('user123', fullSync: false)).called(1);
    });

    test('skips sync when userId is empty', () async {
      when(mockGetUserId.execute()).thenReturn('');

      await FcmService.instance.triggerSync();

      verifyNever(mockSynchronizeEvents.execute(any, fullSync: anyNamed('fullSync')));
    });

    test('swallows exceptions silently', () async {
      when(mockGetUserId.execute()).thenReturn('user123');
      when(mockSynchronizeEvents.execute(any, fullSync: anyNamed('fullSync')))
          .thenThrow(Exception('network error'));

      // Should not throw
      await FcmService.instance.triggerSync();
    });
  });
}
