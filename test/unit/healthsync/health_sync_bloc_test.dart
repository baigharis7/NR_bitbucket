import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
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
        'emits error state when toggle fails',
        setUp: () {
          when(() => mockToggleHealthSyncInteractor.execute(true))
              .thenAnswer((_) async => false);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(HealthSyncToggle(enable: true)),
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.onError, 'onError', ErrorTypes.unknownError),
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
  });
}
