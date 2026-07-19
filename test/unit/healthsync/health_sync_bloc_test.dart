import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/sports_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/sync_health_activities_result.dart';
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
  late MockGetTodaySportsInteractor mockGetTodaySportsInteractor;
  late MockGetMasterFileInteractor mockGetMasterFileInteractor;

  // Use real whitelisted production IDs (61 Running, 103 Walking) so
  // step_estimation_utils' whitelist accepts these entries.
  final testSportsInfo = SportsInfoMaster(sportsInfoMaster: [
    SportInfoMaster(id: 61, en: 'Running', es: 'Correr', mets: 10),
    SportInfoMaster(id: 103, en: 'Walking', es: 'Caminar', mets: 3),
  ]);

  setUp(() {
    mockHealthSyncRepository = MockHealthSyncRepository();
    mockCheckHealthSyncStatusInteractor = MockCheckHealthSyncStatusInteractor();
    mockRequestHealthPermissionsInteractor = MockRequestHealthPermissionsInteractor();
    mockToggleHealthSyncInteractor = MockToggleHealthSyncInteractor();
    mockSyncHealthActivitiesInteractor = MockSyncHealthActivitiesInteractor();
    mockGetTodaySportsInteractor = MockGetTodaySportsInteractor();
    mockGetMasterFileInteractor = MockGetMasterFileInteractor();

    // Default stubs so the auto-init from the constructor always completes
    // cleanly. Individual tests override these as needed.
    when(() => mockGetMasterFileInteractor.execute(MasterFilesType.sportsInfo))
        .thenAnswer((_) async => testSportsInfo);
    when(() => mockGetTodaySportsInteractor.execute(dateTime: any(named: 'dateTime')))
        .thenAnswer((_) async => <SportEventComplete>[]);
  });

  HealthSyncBloc buildBloc() {
    return HealthSyncBloc(
      healthSyncRepository: mockHealthSyncRepository,
      checkHealthSyncStatusInteractor: mockCheckHealthSyncStatusInteractor,
      requestHealthPermissionsInteractor: mockRequestHealthPermissionsInteractor,
      toggleHealthSyncInteractor: mockToggleHealthSyncInteractor,
      syncHealthActivitiesInteractor: mockSyncHealthActivitiesInteractor,
      getTodaySportsInteractor: mockGetTodaySportsInteractor,
      getMasterFileInteractor: mockGetMasterFileInteractor,
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

  /// Stubs for estimated step calculation (sport events + master file)
  void stubEstimatedSteps({List<SportEventComplete>? sportEvents}) {
    when(() => mockGetMasterFileInteractor.execute(MasterFilesType.sportsInfo))
        .thenAnswer((_) async => testSportsInfo);
    when(() => mockGetTodaySportsInteractor.execute(dateTime: any(named: 'dateTime')))
        .thenAnswer((_) async => sportEvents ?? []);
  }

  SyncHealthActivitiesResult syncResult({
    List<SportEventComplete> events = const [],
    SyncHealthOutcome outcome = SyncHealthOutcome.syncedNoData,
    SyncPermissionResolution resolution = SyncPermissionResolution.none,
  }) =>
      SyncHealthActivitiesResult(
        syncedEvents: events,
        outcome: outcome,
        permissionResolution: resolution,
      );

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
          stubEstimatedSteps();
        },
        build: buildBloc,
        // Constructor auto-dispatches HealthSyncInitialization — no act needed.
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
        // Constructor auto-dispatches HealthSyncInitialization — no act needed.
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
          stubEstimatedSteps();
        },
        build: buildBloc,
        // Constructor auto-dispatches HealthSyncInitialization — no act needed.
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
          stubEstimatedSteps();
        },
        build: buildBloc,
        // Constructor auto-dispatches HealthSyncInitialization — no act needed.
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
          stubEstimatedSteps();
        },
        build: buildBloc,
        // Constructor auto-dispatches HealthSyncInitialization — no act needed.
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
          // Sync is now attempted even when hasPermissions is false,
          // because HC's hasPermissions check is unreliable on Android.
          stubSleepStepData(sleepHours: 7.0, stepCount: 5000);
          stubEstimatedSteps();
          // Init now chains a HealthSyncManualTrigger (verification sync)
          // whenever the probe reports isEnabled && isAvailable && !hasPermissions.
          when(() => mockSyncHealthActivitiesInteractor.execute(
                since: any(named: 'since'),
              )).thenAnswer((_) async => syncResult());
        },
        build: buildBloc,
        // Constructor auto-dispatches HealthSyncInitialization — no act needed.
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
          stubEstimatedSteps();
        },
        build: buildBloc,
        // Constructor auto-dispatches HealthSyncInitialization — no act needed.
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.isSyncEnabled, 'isSyncEnabled', false)
              .having((s) => s.todaySleepHours, 'todaySleepHours', null)
              .having((s) => s.todayStepCount, 'todayStepCount', null),
        ],
      );
    });

    group('privacy: no raw health values reach debugPrint/Crashlytics', () {
      late List<String> capturedLogs;
      late DebugPrintCallback originalDebugPrint;

      setUp(() {
        capturedLogs = [];
        originalDebugPrint = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) capturedLogs.add(message);
        };
      });

      tearDown(() {
        debugPrint = originalDebugPrint;
      });

      blocTest<HealthSyncBloc, HealthSyncState>(
        'init does not log the exact sleepHours/stepCount values',
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
          stubSleepStepData(sleepHours: 6.25, stepCount: 12345);
          stubEstimatedSteps();
        },
        build: buildBloc,
        verify: (_) {
          final joined = capturedLogs.join('\n');
          expect(joined, isNot(contains('6.25')));
          expect(joined, isNot(contains('12345')));
        },
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'loadForDate does not log the exact date/sleep/step values',
        setUp: () {
          when(() => mockHealthSyncRepository.getSavedSleepHours(any()))
              .thenAnswer((_) async => 8.0);
          when(() => mockHealthSyncRepository.getSavedStepCount(any()))
              .thenAnswer((_) async => 15000);
          stubEstimatedSteps();
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncLoadForDate(date: DateTime(2024, 3, 10))),
        verify: (_) {
          final joined = capturedLogs.join('\n');
          expect(joined, isNot(contains('8.0')));
          expect(joined, isNot(contains('15000')));
          expect(joined, isNot(contains('2024-03-10')));
          expect(joined, isNot(contains('2024, 3, 10')));
        },
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'recalculating estimated steps does not log the exact value',
        setUp: () {
          stubEstimatedSteps(sportEvents: [
            SportEventComplete(
              userId: 'test',
              eventId: 1,
              eventDate: DateTime.now().millisecondsSinceEpoch,
              source: 'manual',
              info: [SportEventInfo(id: 61, minutes: 30)], // Running 10 METs: (10-1)*32*30 = 8640
            ),
          ]);
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncRecalculateEstimatedSteps()),
        verify: (_) {
          final joined = capturedLogs.join('\n');
          expect(joined, isNot(contains('8640')));
        },
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
        skip: 2, // skip auto-init states from constructor
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
        skip: 2,
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
        skip: 2,
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
          when(() => mockHealthSyncRepository.setHealthSyncEnabled(any()))
              .thenAnswer((_) async {});
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime(2024, 1, 15));
        },
        build: buildBloc,
        skip: 2,
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
          when(() => mockHealthSyncRepository.setHealthSyncEnabled(any()))
              .thenAnswer((_) async {});
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => null);
        },
        build: buildBloc,
        skip: 2,
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
          when(() => mockHealthSyncRepository.setHealthSyncEnabled(any()))
              .thenAnswer((_) async {});
          when(() => mockHealthSyncRepository.hasPermissions())
              .thenAnswer((_) async => false);
          when(() => mockHealthSyncRepository.isHealthSyncEnabled())
              .thenAnswer((_) async => false);
        },
        build: buildBloc,
        skip: 2,
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
              .thenAnswer((_) async => SyncHealthActivitiesResult(
                    syncedEvents: [
                      SportEventComplete(
                        userId: 'test',
                        eventId: 1,
                        eventDate: DateTime.now().millisecondsSinceEpoch,
                        sportName: 'Running',
                        source: 'apple_health',
                        eventKcals: 200,
                        info: [],
                      ),
                    ],
                    outcome: SyncHealthOutcome.synced,
                  ));
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime.now());
          stubSleepStepData();
          stubEstimatedSteps();
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        verify: (bloc) {
          // Verify the final state after all events settle
          expect(bloc.state.syncSuccess, true);
          expect(bloc.state.syncedActivitiesCount, 1);
          expect(bloc.state.isSyncing, false);
        },
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'emits correct state when manual sync returns empty',
        setUp: () {
          when(() => mockSyncHealthActivitiesInteractor.execute(since: any(named: 'since')))
              .thenAnswer((_) async => const SyncHealthActivitiesResult(
                    syncedEvents: [],
                    outcome: SyncHealthOutcome.syncedNoData,
                  ));
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime.now());
          stubSleepStepData();
          stubEstimatedSteps();
        },
        build: buildBloc,
        skip: 2,
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
        skip: 2,
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
              .thenAnswer((_) async => const SyncHealthActivitiesResult(
                    syncedEvents: [],
                    outcome: SyncHealthOutcome.syncedNoData,
                  ));
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => DateTime.now());
          stubSleepStepData(sleepHours: 6.0, stepCount: 12000);
          stubEstimatedSteps();
        },
        build: buildBloc,
        skip: 2,
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

      blocTest<HealthSyncBloc, HealthSyncState>(
        'reports syncSuccess false when the fetch failed (no green snackbar)',
        setUp: () {
          when(() => mockSyncHealthActivitiesInteractor.execute(
                  since: any(named: 'since')))
              .thenAnswer((_) async => const SyncHealthActivitiesResult(
                    syncedEvents: [],
                    outcome: SyncHealthOutcome.fetchFailed,
                  ));
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => null);
          stubSleepStepData();
          stubEstimatedSteps();
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        verify: (bloc) {
          expect(bloc.state.syncSuccess, false);
          expect(bloc.state.syncedActivitiesCount, 0);
          expect(bloc.state.isSyncing, false);
          expect(bloc.state.onError, isNull);
        },
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'reports syncSuccess false on a permission-denied fetch',
        setUp: () {
          when(() => mockSyncHealthActivitiesInteractor.execute(
                  since: any(named: 'since')))
              .thenAnswer((_) async => const SyncHealthActivitiesResult(
                    syncedEvents: [],
                    outcome: SyncHealthOutcome.permissionDenied,
                  ));
          when(() => mockHealthSyncRepository.getLastSyncTime())
              .thenAnswer((_) async => null);
          stubSleepStepData();
          stubEstimatedSteps();
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        verify: (bloc) {
          expect(bloc.state.syncSuccess, false);
          expect(bloc.state.syncedActivitiesCount, 0);
          expect(bloc.state.isSyncing, false);
        },
      );

      test('notifies DashboardEventBus with sport category when activities are synced', () async {
        when(() => mockSyncHealthActivitiesInteractor.execute(since: any(named: 'since')))
            .thenAnswer((_) async => SyncHealthActivitiesResult(
                  syncedEvents: [
                    SportEventComplete(
                      userId: 'test',
                      eventId: 1,
                      eventDate: DateTime.now().millisecondsSinceEpoch,
                      sportName: 'Running',
                      source: 'apple_health',
                      eventKcals: 200,
                      info: [],
                    ),
                  ],
                  outcome: SyncHealthOutcome.synced,
                ));
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => DateTime.now());
        stubSleepStepData();
        stubEstimatedSteps();

        final busEvents = <DataChangedCategory>[];
        final sub = DashboardEventBus.instance.stream.listen(busEvents.add);

        final bloc = buildBloc();
        bloc.add(HealthSyncManualTrigger());
        await pumpEventQueue();

        expect(busEvents, contains(DataChangedCategory.sport));

        await sub.cancel();
        await bloc.close();
      });

      test('does not notify DashboardEventBus when no activities are synced', () async {
        when(() => mockSyncHealthActivitiesInteractor.execute(since: any(named: 'since')))
            .thenAnswer((_) async => const SyncHealthActivitiesResult(
                  syncedEvents: [],
                  outcome: SyncHealthOutcome.syncedNoData,
                ));
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => DateTime.now());
        stubSleepStepData();
        stubEstimatedSteps();

        final busEvents = <DataChangedCategory>[];
        final sub = DashboardEventBus.instance.stream.listen(busEvents.add);

        final bloc = buildBloc();
        bloc.add(HealthSyncManualTrigger());
        await pumpEventQueue();

        expect(busEvents, isEmpty);

        await sub.cancel();
        await bloc.close();
      });
    });

    group('permission attention (verified signals only)', () {
      void stubManualTriggerCollaborators() {
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => DateTime(2026, 7, 18, 10));
        stubSleepStepData();
        stubEstimatedSteps();
      }

      blocTest<HealthSyncBloc, HealthSyncState>(
        'verified denial raises attention and drops hasPermissions',
        setUp: () {
          stubManualTriggerCollaborators();
          when(() => mockSyncHealthActivitiesInteractor.execute(
                since: any(named: 'since'),
              )).thenAnswer((_) async => syncResult(
                outcome: SyncHealthOutcome.permissionDenied,
                resolution: SyncPermissionResolution.verifiedDenial,
              ));
        },
        build: buildBloc,
        skip: 2, // skip auto-init states from constructor
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        verify: (bloc) {
          expect(bloc.state.needsPermissionUpdate, isTrue);
          expect(bloc.state.hasPermissions, isFalse);
          expect(bloc.state.syncSuccess, isFalse);
          expect(bloc.state.isSyncing, isFalse);
        },
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'tolerated false negative clears previously raised attention',
        seed: () => HealthSyncState(
          needsPermissionUpdate: true,
          hasPermissions: false,
        ),
        setUp: () {
          stubManualTriggerCollaborators();
          when(() => mockSyncHealthActivitiesInteractor.execute(
                since: any(named: 'since'),
              )).thenAnswer((_) async => syncResult(
                outcome: SyncHealthOutcome.syncedNoData,
                resolution: SyncPermissionResolution.toleratedFalseNegative,
              ));
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        verify: (bloc) {
          // Explicit false must actually clear the flag (copyWith override).
          expect(bloc.state.needsPermissionUpdate, isFalse);
          expect(bloc.state.hasPermissions, isTrue);
          expect(bloc.state.syncSuccess, isTrue);
        },
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'resolution none leaves attention and hasPermissions untouched',
        seed: () => HealthSyncState(
          needsPermissionUpdate: true,
          hasPermissions: false,
        ),
        setUp: () {
          stubManualTriggerCollaborators();
          when(() => mockSyncHealthActivitiesInteractor.execute(
                since: any(named: 'since'),
              )).thenAnswer((_) async => syncResult(
                outcome: SyncHealthOutcome.fetchFailed,
                resolution: SyncPermissionResolution.none,
              ));
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncManualTrigger()),
        verify: (bloc) {
          // A real fetch failure is not a permission verdict either way.
          expect(bloc.state.needsPermissionUpdate, isTrue);
          expect(bloc.state.hasPermissions, isFalse);
        },
      );

      test(
          'init with a false probe does not raise attention and chains a '
          'verification sync', () async {
        when(() => mockHealthSyncRepository.isHealthSyncAvailable())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.isHealthSyncEnabled())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.hasPermissions())
            .thenAnswer((_) async => false);
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => DateTime(2026, 7, 18, 9));
        stubSavedData();
        stubSleepStepData();
        stubEstimatedSteps();
        when(() => mockSyncHealthActivitiesInteractor.execute(
              since: any(named: 'since'),
            )).thenAnswer((_) async => syncResult(
              outcome: SyncHealthOutcome.syncedNoData,
              resolution: SyncPermissionResolution.toleratedFalseNegative,
            ));

        final bloc = buildBloc();
        final states = <HealthSyncState>[];
        final sub = bloc.stream.listen(states.add);
        await pumpEventQueue();

        // The chained verification sync actually ran.
        verify(() => mockSyncHealthActivitiesInteractor.execute(
              since: any(named: 'since'),
            )).called(1);
        // No state — init's or the chained sync's — ever raised attention
        // from the probe alone.
        expect(
          states.map((s) => s.needsPermissionUpdate),
          everyElement(isFalse),
        );
        expect(bloc.state.hasPermissions, isTrue);

        await sub.cancel();
        await bloc.close();
      });

      test(
          'no-spam regression: repeated tolerated syncs never raise '
          'attention', () async {
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => DateTime(2026, 7, 18, 10));
        stubSleepStepData();
        stubEstimatedSteps();
        when(() => mockSyncHealthActivitiesInteractor.execute(
              since: any(named: 'since'),
            )).thenAnswer((_) async => syncResult(
              outcome: SyncHealthOutcome.syncedNoData,
              resolution: SyncPermissionResolution.toleratedFalseNegative,
            ));

        final bloc = buildBloc();
        await pumpEventQueue(); // let auto-init settle (errors are caught)

        final states = <HealthSyncState>[];
        final sub = bloc.stream.listen(states.add);
        bloc.add(HealthSyncManualTrigger());
        await pumpEventQueue();
        bloc.add(HealthSyncManualTrigger());
        await pumpEventQueue();

        expect(states, isNotEmpty);
        expect(
          states.map((s) => s.needsPermissionUpdate),
          everyElement(isFalse),
        );

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
          stubEstimatedSteps();
        },
        build: buildBloc,
        skip: 2,
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
          stubEstimatedSteps();
        },
        build: buildBloc,
        skip: 2,
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
          stubEstimatedSteps();
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncLoadForDate(date: DateTime(2024, 2, 15))),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.todaySleepHours, 'todaySleepHours', 5.5)
              .having((s) => s.todayStepCount, 'todayStepCount', null),
        ],
      );
    });
  });

    group('HealthSyncRecalculateEstimatedSteps', () {
      blocTest<HealthSyncBloc, HealthSyncState>(
        'calculates estimated steps from manual sport events',
        setUp: () {
          stubEstimatedSteps(sportEvents: [
            SportEventComplete(
              userId: 'test',
              eventId: 1,
              eventDate: DateTime.now().millisecondsSinceEpoch,
              source: 'manual',
              info: [SportEventInfo(id: 61, minutes: 30)], // Running 10 METs: (10-1)*32*30 = 8640
            ),
          ]);
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncRecalculateEstimatedSteps()),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.estimatedStepCount, 'estimatedStepCount', 8640),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'returns 0 when no manual sport events exist',
        setUp: () {
          stubEstimatedSteps(sportEvents: []);
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncRecalculateEstimatedSteps()),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.estimatedStepCount, 'estimatedStepCount', 0),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'skips health_connect synced events',
        setUp: () {
          stubEstimatedSteps(sportEvents: [
            SportEventComplete(
              userId: 'test',
              eventId: 1,
              eventDate: DateTime.now().millisecondsSinceEpoch,
              source: 'health_connect',
              info: [SportEventInfo(id: 61, minutes: 30)],
            ),
          ]);
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncRecalculateEstimatedSteps()),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.estimatedStepCount, 'estimatedStepCount', 0),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'handles master file not loaded gracefully',
        setUp: () {
          when(() => mockGetMasterFileInteractor.execute(MasterFilesType.sportsInfo))
              .thenAnswer((_) async => null);
          when(() => mockGetTodaySportsInteractor.execute(dateTime: any(named: 'dateTime')))
              .thenAnswer((_) async => []);
        },
        build: buildBloc,
        skip: 2,
        act: (bloc) => bloc.add(HealthSyncRecalculateEstimatedSteps()),
        expect: () => [
          isA<HealthSyncState>()
              .having((s) => s.estimatedStepCount, 'estimatedStepCount', 0),
        ],
      );

      blocTest<HealthSyncBloc, HealthSyncState>(
        'includes estimated steps during initialization',
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
          stubEstimatedSteps(sportEvents: [
            SportEventComplete(
              userId: 'test',
              eventId: 1,
              eventDate: DateTime.now().millisecondsSinceEpoch,
              info: [SportEventInfo(id: 103, minutes: 20)], // Walking 3 METs: (3-1)*32*20 = 1280
            ),
          ]);
        },
        build: buildBloc,
        // Constructor auto-dispatches HealthSyncInitialization — no act needed.
        expect: () => [
          isA<HealthSyncState>().having((s) => s.isLoading, 'isLoading', true),
          isA<HealthSyncState>()
              .having((s) => s.estimatedStepCount, 'estimatedStepCount', 1280),
        ],
      );

      test('recalculates when sport EventBus fires', () async {
        stubEstimatedSteps(sportEvents: [
          SportEventComplete(
            userId: 'test',
            eventId: 1,
            eventDate: DateTime.now().millisecondsSinceEpoch,
            info: [SportEventInfo(id: 61, minutes: 10)], // Running: (10-1)*32*10 = 2880
          ),
        ]);

        final bloc = buildBloc();
        // Wait for any initialization events to settle
        await pumpEventQueue();

        // Fire sport event on EventBus
        DashboardEventBus.instance.notify(DataChangedCategory.sport);
        await pumpEventQueue();

        expect(bloc.state.estimatedStepCount, 2880);

        await bloc.close();
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
      expect(state.estimatedStepCount, 0);
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

    test('copyWith updates estimatedStepCount', () {
      final state = HealthSyncState();
      final newState = state.copyWith(estimatedStepCount: 5000);

      expect(newState.estimatedStepCount, 5000);
    });

    test('copyWith preserves estimatedStepCount when not specified', () {
      final state = HealthSyncState(estimatedStepCount: 3000);
      final newState = state.copyWith(isLoading: true);

      expect(newState.estimatedStepCount, 3000);
    });
  });
}
