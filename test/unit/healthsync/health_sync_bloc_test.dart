import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/bloc/health_sync_bloc.dart';

import '../../mocks/health_sync_mocks.dart';

void main() {
  late MockHealthSyncRepository mockHealthSyncRepository;
  late MockCheckHealthSyncStatusInteractor mockCheckHealthSyncStatusInteractor;
  late MockRequestHealthPermissionsInteractor mockRequestHealthPermissionsInteractor;
  late MockToggleHealthSyncInteractor mockToggleHealthSyncInteractor;
  late MockSyncHealthActivitiesInteractor mockSyncHealthActivitiesInteractor;

  setUp(() {
    mockHealthSyncRepository = MockHealthSyncRepository();
    mockCheckHealthSyncStatusInteractor = MockCheckHealthSyncStatusInteractor();
    mockRequestHealthPermissionsInteractor = MockRequestHealthPermissionsInteractor();
    mockToggleHealthSyncInteractor = MockToggleHealthSyncInteractor();
    mockSyncHealthActivitiesInteractor = MockSyncHealthActivitiesInteractor();
  });

  HealthSyncBloc buildBloc() {
    return HealthSyncBloc(
      healthSyncRepository: mockHealthSyncRepository,
      checkHealthSyncStatusInteractor: mockCheckHealthSyncStatusInteractor,
      requestHealthPermissionsInteractor: mockRequestHealthPermissionsInteractor,
      toggleHealthSyncInteractor: mockToggleHealthSyncInteractor,
      syncHealthActivitiesInteractor: mockSyncHealthActivitiesInteractor,
    );
  }

  /// Stubs for fetching + saving sleep/step data (used when sync is enabled)
  void stubSleepStepData({double sleepHours = 7.5, int stepCount = 5000}) {
    when(() => mockHealthSyncRepository.fetchTodaySleepHours(any()))
        .thenAnswer((_) async => sleepHours);
    when(() => mockHealthSyncRepository.fetchTodayStepCount(any()))
        .thenAnswer((_) async => stepCount);
    when(() => mockHealthSyncRepository.saveSleepEvent(
          date: any(named: 'date'),
          sleepHours: any(named: 'sleepHours'),
        )).thenAnswer((_) async {});
    when(() => mockHealthSyncRepository.saveStepEvent(
          date: any(named: 'date'),
          stepCount: any(named: 'stepCount'),
        )).thenAnswer((_) async {});
  }

  /// Stubs for loading saved data from Hive (used on init fallback)
  void stubSavedData({double? sleepHours, int? stepCount}) {
    when(() => mockHealthSyncRepository.getSavedSleepHours(any()))
        .thenAnswer((_) async => sleepHours);
    when(() => mockHealthSyncRepository.getSavedStepCount(any()))
        .thenAnswer((_) async => stepCount);
  }

  group('HealthSyncBloc', () {
    group('HealthSyncInitialization', () {
      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits correct state when initialization succeeds',
        setUp: () {
          when(() => mockHealthSyncRepository.isHealthSyncAvailable())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.isHealthSyncEnabled())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.hasPermissions())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime(2024, 1, 15, 10, 30));
          stubSavedData();
          stubSleepStepData();
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncInitialization()),
        expect: () => [
          // Loading state
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          // Success state
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.isAvailable, 'isAvailable', true)
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', true)
              .having((s) => s.hasPermissions, 'hasPermissions', true)
              .having((s) => s.lastSyncTime, 'lastSyncTime', isNotNull),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits error state when initialization fails',
        setUp: () {
          when(() => mockHealthSyncRepository.isHealthSyncAvailable())
              .thenThrow(Exception('Test error'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncInitialization()),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.onError, 'onError', ErrorTypes.unknownError),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits correct state when health sync not available',
        setUp: () {
          when(() => mockHealthSyncRepository.isHealthSyncAvailable())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.isHealthSyncEnabled())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.hasPermissions())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => null);
          stubSavedData();
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncInitialization()),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.isAvailable, 'isAvailable', false)
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', false)
              .having((s) => s.hasPermissions, 'hasPermissions', false),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'fetches sleep/step data and saves when sync is enabled',
        setUp: () {
          when(() => mockHealthSyncRepository.isHealthSyncAvailable())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.isHealthSyncEnabled())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.hasPermissions())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime(2024, 1, 15));
          stubSavedData();
          stubSleepStepData(sleepHours: 7.5, stepCount: 8000);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncInitialization()),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', true)
              .having((s) => s.todaySleepHours, 'todaySleepHours', 7.5)
              .having((s) => s.todayStepCount, 'todayStepCount', 8000),
        ],
        verify: (_) {
          verify(() => mockHealthSyncRepository.saveSleepEvent(
                date: any(named: 'date'),
                sleepHours: any(named: 'sleepHours'),
              )).called(1);
          verify(() => mockHealthSyncRepository.saveStepEvent(
                date: any(named: 'date'),
                stepCount: any(named: 'stepCount'),
              )).called(1);
        },
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'loads saved data when sync is disabled (widgets remain visible)',
        setUp: () {
          when(() => mockHealthSyncRepository.isHealthSyncAvailable())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.isHealthSyncEnabled())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.hasPermissions())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => null);
          stubSavedData(sleepHours: 6.5, stepCount: 3000);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncInitialization()),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', false)
              .having((s) => s.todaySleepHours, 'todaySleepHours', 6.5)
              .having((s) => s.todayStepCount, 'todayStepCount', 3000),
        ],
        verify: (_) {
          verifyNever(() => mockHealthSyncRepository.fetchTodaySleepHours(any()));
          verifyNever(() => mockHealthSyncRepository.fetchTodayStepCount(any()));
        },
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'does not auto-disable sync when permissions are revoked',
        setUp: () {
          when(() => mockHealthSyncRepository.isHealthSyncAvailable())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.isHealthSyncEnabled())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.hasPermissions())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime(2024, 1, 15));
          stubSavedData(sleepHours: 7.0, stepCount: 5000);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncInitialization()),
        verify: (_) {
          // Should NOT call setHealthSyncEnabled(false)
          verifyNever(() => mockHealthSyncRepository.setHealthSyncEnabled(false));
          // Should still load saved data
          verify(() => mockHealthSyncRepository.getSavedSleepHours(any())).called(1);
          verify(() => mockHealthSyncRepository.getSavedStepCount(any())).called(1);
        },
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'sleep/step data is null when no saved data and sync disabled',
        setUp: () {
          when(() => mockHealthSyncRepository.isHealthSyncAvailable())
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.isHealthSyncEnabled())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.hasPermissions())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => null);
          stubSavedData(sleepHours: null, stepCount: null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncInitialization()),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', false)
              .having((s) => s.todaySleepHours, 'todaySleepHours', null)
              .having((s) => s.todayStepCount, 'todayStepCount', null),
        ],
      );
    });

    group('HealthSyncRequestPermissions', () {
      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits correct state when permissions granted',
        setUp: () {
          when(() => mockRequestHealthPermissionsInteractor.execute())
              .thenAnswer((_) async => true);
          when(() => mockToggleHealthSyncInteractor.execute(true))
              .thenAnswer((_) async => true);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncRequestPermissions()),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.hasPermissions, 'hasPermissions', true)
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', true)
              .having((s) => s.permissionGranted, 'permissionGranted', true),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits correct state when permissions denied',
        setUp: () {
          when(() => mockRequestHealthPermissionsInteractor.execute())
              .thenAnswer((_) async => false);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncRequestPermissions()),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.hasPermissions, 'hasPermissions', false)
              .having((s) => s.permissionGranted, 'permissionGranted', false),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits error state when request fails',
        setUp: () {
          when(() => mockRequestHealthPermissionsInteractor.execute())
              .thenThrow(Exception('Permission request failed'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncRequestPermissions()),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.onError, 'onError', ErrorTypes.unknownError),
        ],
      );
    });

    group('HealthSyncToggle', () {
      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits correct state when sync enabled successfully',
        setUp: () {
          when(() => mockToggleHealthSyncInteractor.execute(true))
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime(2024, 1, 15));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncToggle(enable: true)),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', true),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits correct state when sync disabled successfully',
        setUp: () {
          when(() => mockToggleHealthSyncInteractor.execute(false))
              .thenAnswer((_) async => true);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncToggle(enable: false)),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', false),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits permission denied state when toggle fails',
        setUp: () {
          when(() => mockToggleHealthSyncInteractor.execute(true))
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.hasPermissions())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.isHealthSyncEnabled())
              .thenAnswer((_) async => false);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncToggle(enable: true)),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', false)
              .having((s) => s.hasPermissions, 'hasPermissions', false)
              .having((s) => s.permissionGranted, 'permissionGranted', false),
        ],
      );
    });

    group('HealthSyncManualTrigger', () {
      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits correct state when manual sync succeeds',
        setUp: () {
          when(() => mockSyncHealthActivitiesInteractor.execute(since: any(named: 'since')))
              .thenAnswer((_) async => [
                SportEventComplete(
                  userId: 'test',
                  eventId: 1,
                  eventDate: DateTime.now().millisecondsSinceEpoch,
                  sportName: 'Running',
                  source: 'apple_health',
                  eventKcals: 200,
                  info: [],
                ),
              ]);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime.now());
          stubSleepStepData();
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.isSyncing, 'isSyncing', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.isSyncing, 'isSyncing', false)
              .having((s) => s.syncedActivitiesCount, 'syncedActivitiesCount', 1)
              .having((s) => s.syncSuccess, 'syncSuccess', true),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits correct state when manual sync returns empty',
        setUp: () {
          when(() => mockSyncHealthActivitiesInteractor.execute(since: any(named: 'since')))
              .thenAnswer((_) async => []);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime.now());
          stubSleepStepData();
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.isSyncing, 'isSyncing', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.isSyncing, 'isSyncing', false)
              .having((s) => s.syncedActivitiesCount, 'syncedActivitiesCount', 0)
              .having((s) => s.syncSuccess, 'syncSuccess', true),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits error state when manual sync fails',
        setUp: () {
          when(() => mockSyncHealthActivitiesInteractor.execute(since: any(named: 'since')))
              .thenThrow(Exception('Sync failed'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.isSyncing, 'isSyncing', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.isSyncing, 'isSyncing', false)
              .having((s) => s.onError, 'onError', ErrorTypes.unknownError),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'saves sleep/step data after successful sync',
        setUp: () {
          when(() => mockSyncHealthActivitiesInteractor.execute(since: any(named: 'since')))
              .thenAnswer((_) async => []);
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime.now());
          stubSleepStepData(sleepHours: 6.0, stepCount: 12000);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', true)
              .having((s) => s.isSyncing, 'isSyncing', true),
          isA<HealthSyncState>()
              .having((s) => s.todaySleepHours, 'todaySleepHours', 6.0)
              .having((s) => s.todayStepCount, 'todayStepCount', 12000)
              .having((s) => s.syncSuccess, 'syncSuccess', true),
        ],
        verify: (_) {
          verify(() => mockHealthSyncRepository.saveSleepEvent(
                date: any(named: 'date'),
                sleepHours: any(named: 'sleepHours'),
              )).called(1);
          verify(() => mockHealthSyncRepository.saveStepEvent(
                date: any(named: 'date'),
                stepCount: any(named: 'stepCount'),
              )).called(1);
        },
      );

      test('notifies DashboardEventBus with sport category when activities are synced', () async {
        when(() => mockSyncHealthActivitiesInteractor.execute(since: any(named: 'since')))
            .thenAnswer((_) async => [
                  SportEventComplete(
                    userId: 'test',
                    eventId: 1,
                    eventDate: DateTime.now().millisecondsSinceEpoch,
                    sportName: 'Running',
                    source: 'apple_health',
                    eventKcals: 200,
                    info: [],
                  ),
                ]);
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => DateTime.now());
        stubSleepStepData();

        final busEvents = <DataChangedCategory>[];
        final sub = DashboardEventBus.instance.stream.listen(busEvents.add);

        final bloc = buildBloc();
        bloc.add(HealthSyncManualTrigger());
        await Future.delayed(const Duration(milliseconds: 200));

        expect(busEvents, contains(DataChangedCategory.sport));

        await sub.cancel();
        await bloc.close();
      });

      test('does not notify DashboardEventBus when no activities are synced', () async {
        when(() => mockSyncHealthActivitiesInteractor.execute(since: any(named: 'since')))
            .thenAnswer((_) async => []);
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => DateTime.now());
        stubSleepStepData();

        final busEvents = <DataChangedCategory>[];
        final sub = DashboardEventBus.instance.stream.listen(busEvents.add);

        final bloc = buildBloc();
        bloc.add(HealthSyncManualTrigger());
        await Future.delayed(const Duration(milliseconds: 200));

        expect(busEvents, isEmpty);

        await sub.cancel();
        await bloc.close();
      });
    });

    group('HealthSyncLoadForDate', () {
      blocTest<HealthSyncBloc, HealthSyncState>(
        'loads saved data for a specific date',
        setUp: () {
          when(() => mockHealthSyncRepository.getSavedSleepHours(any()))
              .thenAnswer((_) async => 8.0);
          when(() => mockHealthSyncRepository.getSavedStepCount(any()))
              .thenAnswer((_) async => 15000);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncLoadForDate(date: DateTime(2024, 3, 10))),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.todaySleepHours, 'todaySleepHours', 8.0)
              .having((s) => s.todayStepCount, 'todayStepCount', 15000),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'clears data when date has no saved data',
        seed: () => HealthSyncState(todaySleepHours: 7.5, todayStepCount: 10000),
        setUp: () {
          when(() => mockHealthSyncRepository.getSavedSleepHours(any()))
              .thenAnswer((_) async => null);
          when(() => mockHealthSyncRepository.getSavedStepCount(any()))
              .thenAnswer((_) async => null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncLoadForDate(date: DateTime(2024, 1, 1))),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.todaySleepHours, 'todaySleepHours', null)
              .having((s) => s.todayStepCount, 'todayStepCount', null),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'handles partial data (sleep but no steps)',
        setUp: () {
          when(() => mockHealthSyncRepository.getSavedSleepHours(any()))
              .thenAnswer((_) async => 5.5);
          when(() => mockHealthSyncRepository.getSavedStepCount(any()))
              .thenAnswer((_) async => null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncLoadForDate(date: DateTime(2024, 2, 15))),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.todaySleepHours, 'todaySleepHours', 5.5)
              .having((s) => s.todayStepCount, 'todayStepCount', null),
        ],
      );
    });
  });

  group('HealthSyncState', () {
    test('initial state has correct defaults', () {
      final state = HealthSyncState();
      expect(state.isLoading, false);
      expect(state.isAvailable, false);
      expect(state.hasPermissions, false);
      expect(state.isSyncEnabled, false);
      expect(state.isSyncing, false);
      expect(state.lastSyncTime, null);
      expect(state.syncedActivitiesCount, null);
      expect(state.onError, null);
      expect(state.permissionGranted, null);
      expect(state.syncSuccess, null);
      expect(state.todaySleepHours, null);
      expect(state.todayStepCount, null);
    });

    test('copyWith creates a new state with updated values', () {
      final state = HealthSyncState();
      final newState = state.copyWith(
        isLoading: true,
        isAvailable: true,
        hasPermissions: true,
      );

      expect(newState.isLoading, true);
      expect(newState.isAvailable, true);
      expect(newState.hasPermissions, true);
      expect(newState.isSyncEnabled, false); // Unchanged
    });

    test('copyWith preserves values when not specified', () {
      final state = HealthSyncState(
        isLoading: true,
        isAvailable: true,
        hasPermissions: true,
        isSyncEnabled: true,
        lastSyncTime: DateTime(2024, 1, 15),
      );

      final newState = state.copyWith(isLoading: false);

      expect(newState.isLoading, false);
      expect(newState.isAvailable, true);
      expect(newState.hasPermissions, true);
      expect(newState.isSyncEnabled, true);
      expect(newState.lastSyncTime, DateTime(2024, 1, 15));
    });

    test('copyWith updates sleep/step data', () {
      final state = HealthSyncState();
      final newState = state.copyWith(
        todaySleepHours: 7.5,
        todayStepCount: 10000,
      );

      expect(newState.todaySleepHours, 7.5);
      expect(newState.todayStepCount, 10000);
    });

    test('copyWith preserves sleep/step data when not specified', () {
      final state = HealthSyncState(
        todaySleepHours: 6.0,
        todayStepCount: 5000,
      );

      final newState = state.copyWith(isLoading: true);

      expect(newState.todaySleepHours, 6.0);
      expect(newState.todayStepCount, 5000);
    });

    test('copyWith clears sleep hours with clearSleepHours flag', () {
      final state = HealthSyncState(todaySleepHours: 7.5, todayStepCount: 10000);
      final newState = state.copyWith(clearSleepHours: true);

      expect(newState.todaySleepHours, null);
      expect(newState.todayStepCount, 10000); // Unchanged
    });

    test('copyWith clears step count with clearStepCount flag', () {
      final state = HealthSyncState(todaySleepHours: 7.5, todayStepCount: 10000);
      final newState = state.copyWith(clearStepCount: true);

      expect(newState.todaySleepHours, 7.5); // Unchanged
      expect(newState.todayStepCount, null);
    });

    test('copyWith clears both with both flags', () {
      final state = HealthSyncState(todaySleepHours: 7.5, todayStepCount: 10000);
      final newState = state.copyWith(clearSleepHours: true, clearStepCount: true);

      expect(newState.todaySleepHours, null);
      expect(newState.todayStepCount, null);
    });
  });
}
