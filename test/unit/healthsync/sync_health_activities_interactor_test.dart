import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/profile/user_profile_entity.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor_impl.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_fetch_result.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/sync_health_activities_result.dart';
import 'package:nutrenaissance_flutter/data/local/models/sportevents/sport_event_entity.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sink.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_fingerprint.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/imported_workout_event_id_factory.dart';

import '../../mocks/health_sync_mocks.dart';
import '../../support/healthsync/health_activity_builder.dart';
import '../../support/healthsync/health_fetch_result_builders.dart';

class FakeHealthActivity extends Fake implements HealthActivity {}
class FakeSportEventComplete extends Fake implements SportEventComplete {}
class FakeSportEventSimple extends Fake implements SportEventSimple {}
class FakeHealthSyncMetadata extends Fake implements HealthSyncMetadata {}

void main() {
  late MockHealthSyncRepository mockHealthSyncRepository;
  late MockLocalStorageRepository mockLocalStorageRepository;
  late MockPreferencesRepository mockPreferencesRepository;
  late MockSaveSportEventInteractor mockSaveSportEventInteractor;
  late MockSportEventsRepository mockSportEventsRepository;
  late MockSportKcalCalculationService mockSportKcalCalculationService;
  late SyncHealthActivitiesInteractorImpl interactor;
  late SportsInfoEntity testSportsInfo;
  late InMemoryHealthSyncDiagnosticsSink diagnostics;

  setUpAll(() {
    registerFallbackValue(FakeHealthActivity());
    registerFallbackValue(FakeSportEventComplete());
    registerFallbackValue(FakeSportEventSimple());
    registerFallbackValue(FakeHealthSyncMetadata());
    registerFallbackValue(MasterFilesType.sportsInfo);
    registerFallbackValue(DateTime(2024, 1, 1));
  });

  setUp(() {
    mockHealthSyncRepository = MockHealthSyncRepository();
    mockLocalStorageRepository = MockLocalStorageRepository();
    mockPreferencesRepository = MockPreferencesRepository();
    mockSaveSportEventInteractor = MockSaveSportEventInteractor();
    mockSportEventsRepository = MockSportEventsRepository();
    mockSportKcalCalculationService = MockSportKcalCalculationService();
    diagnostics = InMemoryHealthSyncDiagnosticsSink();

    // Default: no local event occupies any generated id (collision tests
    // override per-id).
    when(() => mockLocalStorageRepository.findSportEventByEventId(any()))
        .thenAnswer((_) async => null);

    interactor = SyncHealthActivitiesInteractorImpl(
      healthSyncRepository: mockHealthSyncRepository,
      localStorageRepository: mockLocalStorageRepository,
      preferencesRepository: mockPreferencesRepository,
      saveSportEventInteractor: mockSaveSportEventInteractor,
      sportEventsRepository: mockSportEventsRepository,
      sportKcalCalculationService: mockSportKcalCalculationService,
      diagnostics: diagnostics,
    );

    testSportsInfo = SportsInfoEntity(
      id: 1,
      v: 1,
      data: [
        SportInfoEntity(id: 1, en: 'Running', es: 'Correr', mets: 8),
        SportInfoEntity(id: 2, en: 'Walking', es: 'Caminar', mets: 3),
        SportInfoEntity(id: 9, en: 'General Exercise', es: 'Ejercicio General', mets: 4),
      ],
    );
  });

  group('SyncHealthActivitiesInteractorImpl.execute', () {
    test('returns skippedDisabled when sync is disabled', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => false);

      final result = await interactor.execute();

      expect(result.syncedEvents, isEmpty);
      expect(result.outcome, SyncHealthOutcome.skippedDisabled);
      verifyNever(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ));
      expect(diagnostics.events, hasLength(1));
      expect(diagnostics.events.single.type, HealthSyncDiagnosticType.syncSkipped);
      expect(diagnostics.events.single.metadata['reason'], 'skippedDisabled');
    });

    test('returns skippedThrottled when synced recently (throttling)', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      // Last sync was 1 minute ago (within the 5 min throttle). Captured
      // once, up front, so the comparison inside execute() isn't racing a
      // lazily-evaluated DateTime.now() against its own clock.
      final recentSync = DateTime.now().subtract(const Duration(minutes: 1));
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => recentSync);

      final result = await interactor.execute();

      expect(result.syncedEvents, isEmpty);
      expect(result.outcome, SyncHealthOutcome.skippedThrottled);
      verifyNever(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ));
      expect(diagnostics.events, hasLength(1));
      expect(diagnostics.events.single.type, HealthSyncDiagnosticType.syncSkipped);
      expect(diagnostics.events.single.metadata['reason'], 'skippedThrottled');
    });

    test('returns skippedPreconditions when user ID is empty', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('');

      final result = await interactor.execute();

      expect(result.syncedEvents, isEmpty);
      expect(result.outcome, SyncHealthOutcome.skippedPreconditions);
      expect(diagnostics.events, hasLength(1));
      expect(diagnostics.events.single.type, HealthSyncDiagnosticType.syncSkipped);
      expect(diagnostics.events.single.metadata['reason'], 'skippedPreconditions');
    });

    test('returns skippedPreconditions when sports info not available', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository.getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => null);

      final result = await interactor.execute();

      expect(result.syncedEvents, isEmpty);
      expect(result.outcome, SyncHealthOutcome.skippedPreconditions);
      expect(diagnostics.events, hasLength(1));
      expect(diagnostics.events.single.type, HealthSyncDiagnosticType.syncSkipped);
      expect(diagnostics.events.single.metadata['reason'], 'skippedPreconditions');
    });

    test('fetches activities from last 7 days on first sync', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null); // First sync
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository.getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => testSportsInfo);
      when(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => noDataResult());
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      final result = await interactor.execute();

      verify(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).called(1);
      expect(result.outcome, SyncHealthOutcome.syncedNoData);
    });

    test('deduplicates already synced activities', () async {
      final activity = HealthActivity(
        healthPlatformId: 'already_synced_id',
        legacyPlatformId: 'legacy_already_synced_id',
        activityType: 'RUNNING',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now(),
        durationMinutes: 60,
        caloriesBurned: 500,
        distance: 10000,
        avgHeartRate: 150,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository.getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => testSportsInfo);
      when(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => successResult([activity]));
      // Activity is already synced — its canonical id is a stored metadata key
      when(() => mockHealthSyncRepository.getSyncedMetadata())
          .thenAnswer((_) async => [
                HealthSyncMetadata(
                  healthPlatformId: 'already_synced_id',
                  sportEventId: 1,
                  syncedAt: DateTime(2026, 7, 9),
                  sourceType: 'apple_health',
                ),
              ]);
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      final result = await interactor.execute();

      expect(result.syncedEvents, isEmpty);
      expect(result.outcome, SyncHealthOutcome.synced);
      verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));

      final dupEvents = diagnostics.events
          .where((e) => e.type == HealthSyncDiagnosticType.duplicateDiscarded)
          .toList();
      expect(dupEvents, hasLength(1));
      expect(dupEvents.single.metadata['exactCount'], 1);
    });

    test('processes new activities successfully', () async {
      final activity = aHealthActivity(
        healthPlatformId: 'new_activity_id',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now(),
      );

      final uploadedEvent = SportEventComplete(
        userId: 'user123',
        eventId: 1,
        eventDate: DateTime.now().millisecondsSinceEpoch,
        sportName: 'Running',
        source: 'apple_health',
        eventKcals: 500,
        info: [],
      );

      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository.getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => testSportsInfo);
      when(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => successResult([activity]));
      when(() => mockHealthSyncRepository.getSyncedMetadata())
          .thenAnswer((_) async => <HealthSyncMetadata>[]);

      var saveCalled = false;
      var metadataSaved = false;
      var syncToBackendCalled = false;

      when(() => mockSaveSportEventInteractor.execute(any(), any()))
          .thenAnswer((_) async {
        saveCalled = true;
      });
      when(() => mockSportEventsRepository.syncToBackend(any()))
          .thenAnswer((_) {
        syncToBackendCalled = true;
      });
      when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
          .thenAnswer((_) async {
        metadataSaved = true;
      });
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      final result = await interactor.execute();

      expect(result.syncedEvents, hasLength(1));
      expect(result.outcome, SyncHealthOutcome.synced);
      expect(result.syncedEvents.first.source, 'apple_health');
      expect(result.syncedEvents.first.eventKcals, 500); // Preserves health platform calories
      expect(saveCalled, isTrue);
      expect(syncToBackendCalled, isTrue);
      expect(metadataSaved, isTrue);
    });

    test('bypasses throttle when specific date provided', () async {
      var fetchActivitiesCalled = false;

      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      // Last sync was 5 minutes ago (within throttle period)
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(minutes: 5)));
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository.getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => testSportsInfo);
      when(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async {
        fetchActivitiesCalled = true;
        return noDataResult();
      });
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      // Passing a specific date bypasses throttle
      await interactor.execute(since: DateTime.now().subtract(const Duration(days: 1)));

      expect(fetchActivitiesCalled, isTrue);
    });

    test('handles errors gracefully and returns error outcome', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenThrow(Exception('Test error'));

      final result = await interactor.execute();

      expect(result.syncedEvents, isEmpty);
      expect(result.outcome, SyncHealthOutcome.error);
    });

    test('computes kcal locally via METs when platform calories are missing', () async {
      // Synced workout with duration but no platform-supplied calories
      final activity = HealthActivity(
        healthPlatformId: 'no_calories_id',
        legacyPlatformId: 'legacy_no_calories_id',
        activityType: 'RUNNING',
        startTime: DateTime(2024, 5, 1, 10, 0),
        endTime: DateTime(2024, 5, 1, 10, 30),
        durationMinutes: 30,
        caloriesBurned: null, // ← scenario under test
        distance: 5000,
        avgHeartRate: null,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      // Profile with a known weight so we can assert it propagates
      final profile = UserProfileEntity(
        userId: 'user123',
        commonName: 'Test',
        birthDate: 0,
        sex: 0,
        occupationActivityFactor: 1.4,
        objectives: const [],
        physicalCharacteristics: PhysicalCharacteristics(height: 175.0, weight: 80.0),
      );

      // Service returns enriched event with computed kcal
      final enriched = SportEventComplete(
        userId: 'user123',
        eventId: activity.startTime.millisecondsSinceEpoch,
        eventDate: DateTime(2024, 5, 1).millisecondsSinceEpoch,
        sportName: 'Running',
        source: 'apple_health',
        eventKcals: 336, // arbitrary plausible value
        info: [],
      );

      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository.getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => testSportsInfo);
      when(() => mockLocalStorageRepository.getProfile())
          .thenAnswer((_) async => profile);
      when(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => successResult([activity]));
      when(() => mockHealthSyncRepository.getSyncedMetadata())
          .thenAnswer((_) async => <HealthSyncMetadata>[]);
      when(() => mockSportKcalCalculationService.enrichSportEvent(
            any(),
            userWeight: any(named: 'userWeight'),
          )).thenAnswer((_) async => enriched);
      when(() => mockSaveSportEventInteractor.execute(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockSportEventsRepository.syncToBackend(any())).thenAnswer((_) {});
      when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
          .thenAnswer((_) async {});
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      final result = await interactor.execute();

      expect(result.syncedEvents, hasLength(1));
      expect(result.outcome, SyncHealthOutcome.synced);
      expect(result.syncedEvents.first.eventKcals, 336); // computed kcal flows through
      expect(result.syncedEvents.first.info, isNotEmpty);
      expect(result.syncedEvents.first.info!.first.kcal, 336); // info kcal stays in sync with eventKcals
      verify(() => mockSportKcalCalculationService.enrichSportEvent(
            any(),
            userWeight: 80.0,
          )).called(1);
    });

    test('does not call kcal service when platform calories are present', () async {
      final activity = HealthActivity(
        healthPlatformId: 'has_calories_id',
        legacyPlatformId: 'legacy_has_calories_id',
        activityType: 'RUNNING',
        startTime: DateTime(2024, 5, 2, 10, 0),
        endTime: DateTime(2024, 5, 2, 11, 0),
        durationMinutes: 60,
        caloriesBurned: 420,
        distance: 8000,
        avgHeartRate: 145,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository.getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => testSportsInfo);
      when(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => successResult([activity]));
      when(() => mockHealthSyncRepository.getSyncedMetadata())
          .thenAnswer((_) async => <HealthSyncMetadata>[]);
      when(() => mockSaveSportEventInteractor.execute(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockSportEventsRepository.syncToBackend(any())).thenAnswer((_) {});
      when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
          .thenAnswer((_) async {});
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      final result = await interactor.execute();

      expect(result.syncedEvents, hasLength(1));
      expect(result.outcome, SyncHealthOutcome.synced);
      expect(result.syncedEvents.first.eventKcals, 420);
      expect(result.syncedEvents.first.info!.first.kcal, 420); // info kcal mirrors eventKcals
      verifyNever(() => mockSportKcalCalculationService.enrichSportEvent(
            any(),
            userWeight: any(named: 'userWeight'),
          ));
      verifyNever(() => mockLocalStorageRepository.getProfile());
    });

    test('falls back to 0 kcal when both calories and duration are missing', () async {
      final activity = HealthActivity(
        healthPlatformId: 'zero_duration_id',
        legacyPlatformId: 'legacy_zero_duration_id',
        activityType: 'RUNNING',
        startTime: DateTime(2024, 5, 3, 10, 0),
        endTime: DateTime(2024, 5, 3, 10, 0),
        durationMinutes: 0,
        caloriesBurned: null,
        distance: null,
        avgHeartRate: null,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository.getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => testSportsInfo);
      when(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => successResult([activity]));
      when(() => mockHealthSyncRepository.getSyncedMetadata())
          .thenAnswer((_) async => <HealthSyncMetadata>[]);
      when(() => mockSaveSportEventInteractor.execute(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockSportEventsRepository.syncToBackend(any())).thenAnswer((_) {});
      when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
          .thenAnswer((_) async {});
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      final result = await interactor.execute();

      expect(result.syncedEvents, hasLength(1));
      expect(result.outcome, SyncHealthOutcome.synced);
      expect(result.syncedEvents.first.eventKcals, 0);
      verifyNever(() => mockSportKcalCalculationService.enrichSportEvent(
            any(),
            userWeight: any(named: 'userWeight'),
          ));
    });

    test('continues processing when individual activity fails', () async {
      final activity1 = HealthActivity(
        healthPlatformId: 'activity_1',
        legacyPlatformId: 'legacy_activity_1',
        activityType: 'RUNNING',
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1)),
        durationMinutes: 60,
        caloriesBurned: 500,
        distance: 10000,
        avgHeartRate: 150,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      final activity2 = HealthActivity(
        healthPlatformId: 'activity_2',
        legacyPlatformId: 'legacy_activity_2',
        activityType: 'WALKING',
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now(),
        durationMinutes: 60,
        caloriesBurned: 200,
        distance: 5000,
        avgHeartRate: null,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      final uploadedEvent2 = SportEventComplete(
        userId: 'user123',
        eventId: 2,
        eventDate: DateTime.now().millisecondsSinceEpoch,
        sportName: 'Walking',
        source: 'apple_health',
        eventKcals: 200,
        info: [],
      );

      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository.getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => testSportsInfo);
      when(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => successResult([activity1, activity2]));
      when(() => mockHealthSyncRepository.getSyncedMetadata())
          .thenAnswer((_) async => <HealthSyncMetadata>[]);

      // First activity save fails
      var callCount = 0;
      when(() => mockSaveSportEventInteractor.execute(any(), any()))
          .thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Save failed for first activity');
        }
      });
      when(() => mockSportEventsRepository.syncToBackend(any()))
          .thenAnswer((_) {});
      when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
          .thenAnswer((_) async {});
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      final result = await interactor.execute();

      // Second activity should still be processed despite first failing
      expect(result.syncedEvents, hasLength(1));
      expect(result.outcome, SyncHealthOutcome.synced);
      expect(result.syncedEvents.first.source, 'apple_health');
      expect(result.syncedEvents.first.eventKcals, 200); // Preserves health platform calories
      verify(() => mockHealthSyncRepository.setLastSyncTime(any())).called(1);
    });

    group('typed fetch outcomes drive sync state', () {
      void stubPreconditions() {
        when(() => mockHealthSyncRepository.isHealthSyncEnabled())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.hasPermissions())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => null);
        when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
        when(() => mockLocalStorageRepository
                .getMasterFile(MasterFilesType.sportsInfo))
            .thenAnswer((_) async => testSportsInfo);
        when(() => mockHealthSyncRepository.setLastSyncTime(any()))
            .thenAnswer((_) async {});
      }

      void stubFetch(HealthFetchResult<List<HealthActivity>> fetchResult) {
        when(() => mockHealthSyncRepository.fetchActivitiesResult(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => fetchResult);
      }

      void stubProcessing() {
        when(() => mockHealthSyncRepository.getSyncedMetadata())
            .thenAnswer((_) async => <HealthSyncMetadata>[]);
        when(() => mockSaveSportEventInteractor.execute(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockSportEventsRepository.syncToBackend(any()))
            .thenAnswer((_) {});
        when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
            .thenAnswer((_) async {});
      }

      test(
        'failed fetch: no import, no lastSyncTime advance, fetchFailed '
        'diagnostic with the mapped category',
        () async {
          stubPreconditions();
          stubFetch(failedResult(reason: HealthFetchFailureReason.timeout));

          final result = await interactor.execute();

          expect(result.syncedEvents, isEmpty);
          expect(result.outcome, SyncHealthOutcome.fetchFailed);
          expect(result.isSuccess, isFalse);
          verifyNever(() => mockHealthSyncRepository.setLastSyncTime(any()));
          verifyNever(() => mockHealthSyncRepository.getSyncedMetadata());
          verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));

          expect(diagnostics.events, hasLength(3));
          expect(diagnostics.events[0].type, HealthSyncDiagnosticType.syncStarted);
          final event = diagnostics.events[1];
          expect(event.type, HealthSyncDiagnosticType.fetchFailed);
          expect(event.domain, HealthSyncDomain.workout);
          expect(event.metadata['errorCategory'], 'timeout');
          expect(event.metadata.containsKey('phase'), isFalse);
          expect(diagnostics.events[2].type, HealthSyncDiagnosticType.syncCompleted);
          expect(diagnostics.events[2].metadata['outcome'], 'fetchFailed');
        },
      );

      test(
        'permissionDenied fetch: no advance, matching outcome + diagnostic',
        () async {
          stubPreconditions();
          stubFetch(permissionDeniedResult());

          final result = await interactor.execute();

          expect(result.syncedEvents, isEmpty);
          expect(result.outcome, SyncHealthOutcome.permissionDenied);
          expect(result.isSuccess, isFalse);
          verifyNever(() => mockHealthSyncRepository.setLastSyncTime(any()));

          expect(diagnostics.events, hasLength(3));
          expect(diagnostics.events[0].type, HealthSyncDiagnosticType.syncStarted);
          expect(
            diagnostics.events[1].type,
            HealthSyncDiagnosticType.permissionDenied,
          );
          expect(diagnostics.events[1].domain, HealthSyncDomain.workout);
          expect(diagnostics.events[2].type, HealthSyncDiagnosticType.syncCompleted);
          expect(diagnostics.events[2].metadata['outcome'], 'permissionDenied');
        },
      );

      test(
        'platformUnavailable fetch: no advance, matching outcome + diagnostic',
        () async {
          stubPreconditions();
          stubFetch(platformUnavailableResult());

          final result = await interactor.execute();

          expect(result.syncedEvents, isEmpty);
          expect(result.outcome, SyncHealthOutcome.platformUnavailable);
          verifyNever(() => mockHealthSyncRepository.setLastSyncTime(any()));

          expect(diagnostics.events, hasLength(3));
          expect(diagnostics.events[0].type, HealthSyncDiagnosticType.syncStarted);
          expect(
            diagnostics.events[1].type,
            HealthSyncDiagnosticType.platformUnavailable,
          );
          expect(diagnostics.events[2].type, HealthSyncDiagnosticType.syncCompleted);
          expect(diagnostics.events[2].metadata['outcome'], 'platformUnavailable');
        },
      );

      test(
        'successNoData: advances lastSyncTime, syncedNoData outcome, '
        'fetchNoData diagnostic',
        () async {
          stubPreconditions();
          stubFetch(noDataResult());

          final result = await interactor.execute();

          expect(result.syncedEvents, isEmpty);
          expect(result.outcome, SyncHealthOutcome.syncedNoData);
          expect(result.isSuccess, isTrue);
          verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
              .called(1);

          expect(diagnostics.events, hasLength(3));
          expect(diagnostics.events[0].type, HealthSyncDiagnosticType.syncStarted);
          expect(
            diagnostics.events[1].type,
            HealthSyncDiagnosticType.fetchNoData,
          );
          expect(diagnostics.events[2].type, HealthSyncDiagnosticType.syncCompleted);
          expect(diagnostics.events[2].metadata['outcome'], 'syncedNoData');
        },
      );

      test(
        'success: saves event, syncs backend, saves metadata, advances, '
        'synced outcome, fetchSucceeded diagnostic',
        () async {
          stubPreconditions();
          stubProcessing();
          stubFetch(successResult([
            aHealthActivity(healthPlatformId: 'typed_success_id'),
          ]));

          final result = await interactor.execute();

          expect(result.syncedEvents, hasLength(1));
          expect(result.outcome, SyncHealthOutcome.synced);
          expect(result.isSuccess, isTrue);
          verify(() => mockSaveSportEventInteractor.execute(any(), any()))
              .called(1);
          verify(() => mockSportEventsRepository.syncToBackend(any()))
              .called(1);
          verify(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
              .called(1);
          verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
              .called(1);
          verifyNever(() => mockHealthSyncRepository.fetchActivities(
                startDate: any(named: 'startDate'),
                endDate: any(named: 'endDate'),
              ));

          expect(diagnostics.events, hasLength(3));
          expect(diagnostics.events[0].type, HealthSyncDiagnosticType.syncStarted);
          final event = diagnostics.events[1];
          expect(event.type, HealthSyncDiagnosticType.fetchSucceeded);
          expect(event.domain, HealthSyncDomain.workout);
          expect(event.metadata['count'], 1);
          expect(diagnostics.events[2].type, HealthSyncDiagnosticType.syncCompleted);
          expect(diagnostics.events[2].metadata['outcome'], 'synced');
        },
      );

      test(
        'partialSuccess: imports, advances, syncedPartial outcome, '
        'fetchSucceeded + phase-tagged fetchFailed diagnostics',
        () async {
          stubPreconditions();
          stubProcessing();
          stubFetch(partialSuccessResult(
            [aHealthActivity(healthPlatformId: 'typed_partial_id')],
            reason: HealthFetchFailureReason.pluginError,
          ));

          final result = await interactor.execute();

          expect(result.syncedEvents, hasLength(1));
          expect(result.outcome, SyncHealthOutcome.syncedPartial);
          expect(result.isSuccess, isTrue);
          verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
              .called(1);

          expect(diagnostics.events, hasLength(4));
          expect(diagnostics.events[0].type, HealthSyncDiagnosticType.syncStarted);
          expect(
            diagnostics.events[1].type,
            HealthSyncDiagnosticType.fetchSucceeded,
          );
          expect(diagnostics.events[1].metadata['count'], 1);
          expect(
            diagnostics.events[2].type,
            HealthSyncDiagnosticType.fetchFailed,
          );
          expect(diagnostics.events[2].metadata['errorCategory'], 'plugin');
          expect(diagnostics.events[2].metadata['phase'], 'enrichment');
          expect(diagnostics.events[3].type, HealthSyncDiagnosticType.syncCompleted);
          expect(diagnostics.events[3].metadata['outcome'], 'syncedPartial');
        },
      );

      test(
        'per-activity processing failure is still isolated and still advances',
        () async {
          stubPreconditions();
          stubProcessing();
          stubFetch(successResult([
            aHealthActivity(healthPlatformId: 'first_fails'),
            aHealthActivity(
              healthPlatformId: 'second_ok',
              startTime: DateTime(2026, 7, 1, 12, 0),
              endTime: DateTime(2026, 7, 1, 13, 0),
            ),
          ]));
          var callCount = 0;
          when(() => mockSaveSportEventInteractor.execute(any(), any()))
              .thenAnswer((_) async {
            callCount++;
            if (callCount == 1) throw Exception('save failed');
          });

          final result = await interactor.execute();

          expect(result.syncedEvents, hasLength(1));
          expect(result.outcome, SyncHealthOutcome.synced);
          verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
              .called(1);
        },
      );

      test(
        'exception after syncStarted still gets a syncCompleted(error) '
        'bookend',
        () async {
          stubPreconditions();
          stubFetch(successResult(
            [aHealthActivity(healthPlatformId: 'post_start_boom_id')],
          ));
          when(() => mockHealthSyncRepository.getSyncedMetadata())
              .thenThrow(Exception('boom'));

          final result = await interactor.execute();

          expect(result.outcome, SyncHealthOutcome.error);
          expect(
            diagnostics.events.map((e) => e.type),
            containsAllInOrder([
              HealthSyncDiagnosticType.syncStarted,
              HealthSyncDiagnosticType.fetchSucceeded,
            ]),
          );
          final completed = diagnostics.events.singleWhere(
            (e) => e.type == HealthSyncDiagnosticType.syncCompleted,
          );
          expect(completed.metadata['outcome'], 'error');
        },
      );

      test('constructs with the default Noop sink when none is injected', () {
        expect(
          () => SyncHealthActivitiesInteractorImpl(
            healthSyncRepository: mockHealthSyncRepository,
            localStorageRepository: mockLocalStorageRepository,
            preferencesRepository: mockPreferencesRepository,
            saveSportEventInteractor: mockSaveSportEventInteractor,
            sportEventsRepository: mockSportEventsRepository,
            sportKcalCalculationService: mockSportKcalCalculationService,
          ),
          returnsNormally,
        );
      });
    });

    group('deterministic type mapping drives import policy', () {
      void stubPreconditions({SportsInfoEntity? sportsInfo}) {
        when(() => mockHealthSyncRepository.isHealthSyncEnabled())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.hasPermissions())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => null);
        when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
        when(() => mockLocalStorageRepository
                .getMasterFile(MasterFilesType.sportsInfo))
            .thenAnswer((_) async => sportsInfo ?? testSportsInfo);
        when(() => mockHealthSyncRepository.setLastSyncTime(any()))
            .thenAnswer((_) async {});
      }

      void stubFetch(HealthFetchResult<List<HealthActivity>> fetchResult) {
        when(() => mockHealthSyncRepository.fetchActivitiesResult(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => fetchResult);
      }

      void stubProcessing() {
        when(() => mockHealthSyncRepository.getSyncedMetadata())
            .thenAnswer((_) async => <HealthSyncMetadata>[]);
        when(() => mockSaveSportEventInteractor.execute(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockSportEventsRepository.syncToBackend(any()))
            .thenAnswer((_) {});
        when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
            .thenAnswer((_) async {});
      }

      test(
        'unmapped type: controlled skip — no save, no backend, no metadata '
        'write, typeMappingUnmapped diagnostic, window still advances',
        () async {
          final noGenericSportsInfo = SportsInfoEntity(
            id: 1,
            v: 1,
            data: [
              SportInfoEntity(id: 1, en: 'Running', es: 'Correr', mets: 8),
              SportInfoEntity(id: 7, en: 'Tennis', es: 'Tenis', mets: 7),
            ],
          );
          stubPreconditions(sportsInfo: noGenericSportsInfo);
          stubProcessing();
          stubFetch(successResult([
            aHealthActivity(
              healthPlatformId: 'exotic_unmapped',
              activityType: 'TAI_CHI',
            ),
          ]));

          final result = await interactor.execute();

          expect(result.syncedEvents, isEmpty);
          expect(result.outcome, SyncHealthOutcome.synced);
          verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));
          verifyNever(() => mockSportEventsRepository.syncToBackend(any()));
          verifyNever(
              () => mockHealthSyncRepository.saveHealthSyncMetadata(any()));
          // The platform read succeeded — the per-activity skip must not
          // block the window from advancing (unchanged 'Skipped' semantics).
          verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
              .called(1);

          final unmapped = diagnostics.events.singleWhere(
            (e) => e.type == HealthSyncDiagnosticType.typeMappingUnmapped,
          );
          expect(unmapped.severity, HealthSyncDiagnosticSeverity.warning);
          expect(unmapped.domain, HealthSyncDomain.workout);
          expect(unmapped.metadata, {'activityType': 'TAI_CHI'});
          expect(
            diagnostics.events.where(
              (e) => e.type == HealthSyncDiagnosticType.typeMappingFallback,
            ),
            isEmpty,
          );
        },
      );

      test(
        'generic fallback: imports under the generic sport with a '
        'typeMappingFallback diagnostic; platform kcal still wins',
        () async {
          stubPreconditions();
          stubProcessing();
          stubFetch(successResult([
            aHealthActivity(
              healthPlatformId: 'exotic_generic',
              activityType: 'TAI_CHI',
              caloriesBurned: 250,
            ),
          ]));

          final result = await interactor.execute();

          expect(result.syncedEvents, hasLength(1));
          expect(result.outcome, SyncHealthOutcome.synced);
          expect(result.syncedEvents.single.sportName, 'General Exercise');
          expect(result.syncedEvents.single.eventKcals, 250);
          verify(() => mockSaveSportEventInteractor.execute(any(), any()))
              .called(1);
          verify(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
              .called(1);
          verifyNever(() => mockSportKcalCalculationService.enrichSportEvent(
                any(),
                userWeight: any(named: 'userWeight'),
              ));

          final fallback = diagnostics.events.singleWhere(
            (e) => e.type == HealthSyncDiagnosticType.typeMappingFallback,
          );
          expect(fallback.severity, HealthSyncDiagnosticSeverity.info);
          expect(fallback.domain, HealthSyncDomain.workout);
          expect(fallback.metadata, {'activityType': 'TAI_CHI'});
        },
      );

      test(
        'generic fallback without platform kcal: MET path runs with the '
        'generic sport id (any mapped confidence may use METs)',
        () async {
          stubPreconditions();
          stubProcessing();
          when(() => mockLocalStorageRepository.getProfile())
              .thenAnswer((_) async => null); // default 70.0 kg weight path
          final enriched = SportEventComplete(
            userId: 'user123',
            eventId: 1,
            eventDate: DateTime(2026, 7, 1).millisecondsSinceEpoch,
            sportName: 'General Exercise',
            source: 'apple_health',
            eventKcals: 147,
            info: [],
          );
          when(() => mockSportKcalCalculationService.enrichSportEvent(
                any(),
                userWeight: any(named: 'userWeight'),
              )).thenAnswer((_) async => enriched);
          stubFetch(successResult([
            aHealthActivity(
              healthPlatformId: 'exotic_met',
              activityType: 'TAI_CHI',
              caloriesBurned: null,
              durationMinutes: 30,
            ),
          ]));

          final result = await interactor.execute();

          expect(result.syncedEvents, hasLength(1));
          expect(result.syncedEvents.single.eventKcals, 147);
          final simple = verify(
            () => mockSportKcalCalculationService.enrichSportEvent(
              captureAny(),
              userWeight: any(named: 'userWeight'),
            ),
          ).captured.single as SportEventSimple;
          expect(simple.info!.first.id, 9); // the generic sport feeds METs
        },
      );

      test(
        'generic sport absent from the MET table: the existing 0-kcal path '
        'still applies (enrichment yields no kcal, event saves with 0)',
        () async {
          stubPreconditions();
          stubProcessing();
          when(() => mockLocalStorageRepository.getProfile())
              .thenAnswer((_) async => null);
          // SportKcalCalculationService yields 0/absent kcal when the drift
          // SportMets table lacks the sport id — unchanged service behavior,
          // represented here by an enrichment result without kcal.
          final enriched = SportEventComplete(
            userId: 'user123',
            eventId: 1,
            eventDate: DateTime(2026, 7, 1).millisecondsSinceEpoch,
            sportName: 'General Exercise',
            source: 'apple_health',
            info: [],
          );
          when(() => mockSportKcalCalculationService.enrichSportEvent(
                any(),
                userWeight: any(named: 'userWeight'),
              )).thenAnswer((_) async => enriched);
          stubFetch(successResult([
            aHealthActivity(
              healthPlatformId: 'exotic_no_mets',
              activityType: 'TAI_CHI',
              caloriesBurned: null,
              durationMinutes: 30,
            ),
          ]));

          final result = await interactor.execute();

          expect(result.syncedEvents, hasLength(1));
          expect(result.syncedEvents.single.eventKcals, 0);
        },
      );

      test(
        'explicit-name/keyword mapping imports silently — no typeMapping* '
        'diagnostics on the happy path',
        () async {
          stubPreconditions();
          stubProcessing();
          stubFetch(successResult([
            aHealthActivity(healthPlatformId: 'plain_running'),
          ]));

          final result = await interactor.execute();

          expect(result.syncedEvents, hasLength(1));
          expect(result.outcome, SyncHealthOutcome.synced);
          expect(
            diagnostics.events.where((e) =>
                e.type == HealthSyncDiagnosticType.typeMappingFallback ||
                e.type == HealthSyncDiagnosticType.typeMappingUnmapped),
            isEmpty,
          );
        },
      );
    });

    group('fingerprint dedupe drives imports', () {
      final start = DateTime(2026, 7, 10, 8, 0);
      final end = DateTime(2026, 7, 10, 9, 0);

      void stubPreconditions() {
        when(() => mockHealthSyncRepository.isHealthSyncEnabled())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.hasPermissions())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => null);
        when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
        when(() => mockLocalStorageRepository
                .getMasterFile(MasterFilesType.sportsInfo))
            .thenAnswer((_) async => testSportsInfo);
        when(() => mockHealthSyncRepository.setLastSyncTime(any()))
            .thenAnswer((_) async {});
      }

      void stubFetch(HealthFetchResult<List<HealthActivity>> fetchResult) {
        when(() => mockHealthSyncRepository.fetchActivitiesResult(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => fetchResult);
      }

      void stubProcessing({
        List<HealthSyncMetadata> existing = const [],
      }) {
        when(() => mockHealthSyncRepository.getSyncedMetadata())
            .thenAnswer((_) async => existing);
        when(() => mockSaveSportEventInteractor.execute(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockSportEventsRepository.syncToBackend(any()))
            .thenAnswer((_) {});
        when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
            .thenAnswer((_) async {});
      }

      Iterable<HealthSyncDiagnosticEvent> dupEvents() => diagnostics.events
          .where((e) => e.type == HealthSyncDiagnosticType.duplicateDiscarded);

      test(
        'legacy-keyed metadata still blocks re-import after the uuid upgrade',
        () async {
          final legacyKey =
              'Apple Health_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';
          stubPreconditions();
          stubProcessing(existing: [
            HealthSyncMetadata(
              healthPlatformId: legacyKey,
              sportEventId: 1,
              syncedAt: DateTime(2026, 7, 9),
              sourceType: 'apple_health',
            ),
          ]);
          stubFetch(successResult([
            aHealthActivity(
              healthPlatformId: 'fresh-platform-uuid',
              startTime: start,
              endTime: end,
            ),
          ]));

          final result = await interactor.execute();

          expect(result.syncedEvents, isEmpty);
          expect(result.outcome, SyncHealthOutcome.synced);
          verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));
          verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
              .called(1);

          expect(dupEvents(), hasLength(1));
          expect(dupEvents().single.metadata['exactCount'], 1);
          expect(dupEvents().single.metadata['strongCount'], 0);
          expect(dupEvents().single.metadata['suspectedImportedCount'], 0);
        },
      );

      test('within-batch strong duplicate imports the first record only',
          () async {
        stubPreconditions();
        stubProcessing();
        stubFetch(successResult([
          aHealthActivity(
            healthPlatformId: 'uuid-watch',
            startTime: start,
            endTime: end,
            sourceName: 'Apple Watch',
          ),
          aHealthActivity(
            healthPlatformId: 'uuid-phone',
            startTime: start.add(const Duration(minutes: 1)),
            endTime: end.add(const Duration(minutes: 1)),
            sourceName: 'com.sec.android.app.shealth',
            sourceType: 'health_connect',
          ),
        ]));

        final result = await interactor.execute();

        expect(result.syncedEvents, hasLength(1));
        verify(() => mockSaveSportEventInteractor.execute(any(), any()))
            .called(1);
        expect(dupEvents().single.metadata['strongCount'], 1);
        expect(dupEvents().single.metadata['exactCount'], 0);
      });

      test('suspected overlap imports both and is counted', () async {
        stubPreconditions();
        stubProcessing();
        stubFetch(successResult([
          aHealthActivity(
            healthPlatformId: 'uuid-a',
            startTime: start,
            endTime: end,
          ),
          aHealthActivity(
            healthPlatformId: 'uuid-b',
            startTime: start.add(const Duration(minutes: 5)),
            endTime: end.add(const Duration(minutes: 3)),
          ),
        ]));

        final result = await interactor.execute();

        expect(result.syncedEvents, hasLength(2));
        verify(() => mockSaveSportEventInteractor.execute(any(), any()))
            .called(2);
        expect(dupEvents().single.metadata['suspectedImportedCount'], 1);
        expect(dupEvents().single.metadata['exactCount'], 0);
        expect(dupEvents().single.metadata['strongCount'], 0);
      });

      test('a tombstone-only skip emits duplicateDiscarded with '
          'tombstoneBlockedCount == 1 and does not import the activity',
          () async {
        stubPreconditions();
        stubProcessing(existing: [
          HealthSyncMetadata(
            healthPlatformId: 'uuid-deleted',
            sportEventId: 1,
            syncedAt: DateTime(2026, 7, 9),
            sourceType: 'apple_health',
            deletedAt: DateTime(2026, 7, 15),
          ),
        ]);
        stubFetch(successResult([
          aHealthActivity(
            healthPlatformId: 'uuid-deleted',
            startTime: start,
            endTime: end,
          ),
        ]));

        final result = await interactor.execute();

        expect(result.syncedEvents, isEmpty);
        expect(result.outcome, SyncHealthOutcome.synced);
        verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));

        expect(dupEvents(), hasLength(1));
        expect(dupEvents().single.metadata['tombstoneBlockedCount'], 1);
        expect(dupEvents().single.metadata['exactCount'], 0);
        expect(dupEvents().single.metadata['strongCount'], 0);
        expect(dupEvents().single.metadata['suspectedImportedCount'], 0);
      });

      test('same-window different-type imports both, no dedupe diagnostic',
          () async {
        stubPreconditions();
        stubProcessing();
        stubFetch(successResult([
          aHealthActivity(
            healthPlatformId: 'uuid-run',
            activityType: 'RUNNING',
            startTime: start,
            endTime: end,
          ),
          aHealthActivity(
            healthPlatformId: 'uuid-cycle',
            activityType: 'CYCLING',
            startTime: start,
            endTime: end,
          ),
        ]));

        final result = await interactor.execute();

        expect(result.syncedEvents, hasLength(2));
        expect(dupEvents(), isEmpty);
      });

      test(
        'saves metadata with fingerprint fields, keyed by the canonical id, '
        'and mirrors the factory-generated eventId (T14)',
        () async {
          final activity = aHealthActivity(
            healthPlatformId: 'uuid-meta',
            startTime: start,
            endTime: end,
          );
          stubPreconditions();
          stubProcessing();
          stubFetch(successResult([activity]));

          final result = await interactor.execute();

          expect(result.syncedEvents, hasLength(1));
          expect(
            result.syncedEvents.single.eventId,
            const ImportedWorkoutEventIdFactory().eventIdFor(
              HealthWorkoutFingerprint.fromActivity(activity),
            ),
          );

          final saved = verify(() => mockHealthSyncRepository
                  .saveHealthSyncMetadata(captureAny()))
              .captured
              .single as HealthSyncMetadata;
          expect(saved.healthPlatformId, 'uuid-meta');
          expect(saved.normalizedType, 'RUNNING');
          expect(saved.startTimeMs, start.millisecondsSinceEpoch);
          expect(saved.endTimeMs, end.millisecondsSinceEpoch);
          expect(saved.sourceCategory, 'appleHealthApp');
          verify(() => mockHealthSyncRepository.getSyncedMetadata()).called(1);
        },
      );

      test('constructs with the default const deduplicator when none is '
          'injected', () {
        expect(
          () => SyncHealthActivitiesInteractorImpl(
            healthSyncRepository: mockHealthSyncRepository,
            localStorageRepository: mockLocalStorageRepository,
            preferencesRepository: mockPreferencesRepository,
            saveSportEventInteractor: mockSaveSportEventInteractor,
            sportEventsRepository: mockSportEventsRepository,
            sportKcalCalculationService: mockSportKcalCalculationService,
          ),
          returnsNormally,
        );
      });
    });

    group('permission tolerance (probe × fetch-outcome matrix)', () {
      late InMemoryHealthSyncDiagnosticsSink sink;

      setUp(() {
        sink = InMemoryHealthSyncDiagnosticsSink();
        interactor = SyncHealthActivitiesInteractorImpl(
          healthSyncRepository: mockHealthSyncRepository,
          localStorageRepository: mockLocalStorageRepository,
          preferencesRepository: mockPreferencesRepository,
          saveSportEventInteractor: mockSaveSportEventInteractor,
          sportEventsRepository: mockSportEventsRepository,
          sportKcalCalculationService: mockSportKcalCalculationService,
          diagnostics: sink,
        );
      });

      /// Preconditions up to (but not including) the fetch: sync enabled,
      /// first sync (no throttling), valid user, sports master file present.
      void stubPreconditions({required bool probeHasPermissions}) {
        when(() => mockHealthSyncRepository.isHealthSyncEnabled())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.hasPermissions())
            .thenAnswer((_) async => probeHasPermissions);
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => null);
        when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
        when(() => mockLocalStorageRepository
                .getMasterFile(MasterFilesType.sportsInfo))
            .thenAnswer((_) async => testSportsInfo);
        when(() => mockHealthSyncRepository.setLastSyncTime(any()))
            .thenAnswer((_) async {});
      }

      void stubFetch(HealthFetchResult<List<HealthActivity>> result) {
        when(() => mockHealthSyncRepository.fetchActivitiesResult(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => result);
      }

      void stubProcessing() {
        when(() => mockHealthSyncRepository.getSyncedMetadata())
            .thenAnswer((_) async => <HealthSyncMetadata>[]);
        when(() => mockSaveSportEventInteractor.execute(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockSportEventsRepository.syncToBackend(any()))
            .thenAnswer((_) {});
        when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
            .thenAnswer((_) async {});
      }

      bool toleratedEmitted() => sink.events.any((e) =>
          e.type ==
          HealthSyncDiagnosticType.permissionFalseNegativeTolerated);

      test('probe false + success: imports, advances, tolerated', () async {
        stubPreconditions(probeHasPermissions: false);
        stubFetch(successResult([aHealthActivity()]));
        stubProcessing();

        final result = await interactor.execute();

        expect(result.outcome, SyncHealthOutcome.synced);
        expect(
          result.permissionResolution,
          SyncPermissionResolution.toleratedFalseNegative,
        );
        expect(result.syncedEvents, hasLength(1));
        verify(() => mockSaveSportEventInteractor.execute(any(), any()))
            .called(1);
        verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
            .called(1);
        expect(toleratedEmitted(), isTrue);
      });

      test('probe false + successNoData: advances, tolerated', () async {
        stubPreconditions(probeHasPermissions: false);
        stubFetch(noDataResult());

        final result = await interactor.execute();

        expect(result.outcome, SyncHealthOutcome.syncedNoData);
        expect(
          result.permissionResolution,
          SyncPermissionResolution.toleratedFalseNegative,
        );
        expect(result.syncedEvents, isEmpty);
        verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
            .called(1);
        expect(toleratedEmitted(), isTrue);
      });

      test('probe false + partialSuccess: imports, advances, tolerated',
          () async {
        stubPreconditions(probeHasPermissions: false);
        stubFetch(partialSuccessResult(
          [aHealthActivity()],
          reason: HealthFetchFailureReason.pluginError,
        ));
        stubProcessing();

        final result = await interactor.execute();

        expect(result.outcome, SyncHealthOutcome.syncedPartial);
        expect(
          result.permissionResolution,
          SyncPermissionResolution.toleratedFalseNegative,
        );
        expect(result.syncedEvents, hasLength(1));
        verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
            .called(1);
        expect(toleratedEmitted(), isTrue);
      });

      test('probe false + permissionDenied: no import, no advance, verified',
          () async {
        stubPreconditions(probeHasPermissions: false);
        stubFetch(permissionDeniedResult());

        final result = await interactor.execute();

        expect(result.outcome, SyncHealthOutcome.permissionDenied);
        expect(
          result.permissionResolution,
          SyncPermissionResolution.verifiedDenial,
        );
        expect(result.syncedEvents, isEmpty);
        verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));
        verifyNever(() => mockHealthSyncRepository.setLastSyncTime(any()));
        expect(toleratedEmitted(), isFalse);
      });

      test('probe false + failed: real failure is NOT permission attention',
          () async {
        stubPreconditions(probeHasPermissions: false);
        stubFetch(failedResult());

        final result = await interactor.execute();

        expect(result.outcome, SyncHealthOutcome.fetchFailed);
        expect(
          result.permissionResolution,
          SyncPermissionResolution.none,
        );
        verifyNever(() => mockHealthSyncRepository.setLastSyncTime(any()));
        expect(toleratedEmitted(), isFalse);
      });

      test('probe false + platformUnavailable: not permission attention',
          () async {
        stubPreconditions(probeHasPermissions: false);
        stubFetch(platformUnavailableResult());

        final result = await interactor.execute();

        expect(result.outcome, SyncHealthOutcome.platformUnavailable);
        expect(
          result.permissionResolution,
          SyncPermissionResolution.none,
        );
        verifyNever(() => mockHealthSyncRepository.setLastSyncTime(any()));
        expect(toleratedEmitted(), isFalse);
      });

      test(
          'probe true + permissionDenied: platform-reported denial is '
          'verified regardless of the probe', () async {
        stubPreconditions(probeHasPermissions: true);
        stubFetch(permissionDeniedResult());

        final result = await interactor.execute();

        expect(result.outcome, SyncHealthOutcome.permissionDenied);
        expect(
          result.permissionResolution,
          SyncPermissionResolution.verifiedDenial,
        );
        verifyNever(() => mockHealthSyncRepository.setLastSyncTime(any()));
      });

      test('probe true + success: byte-for-byte T8 behavior, resolution none',
          () async {
        stubPreconditions(probeHasPermissions: true);
        stubFetch(successResult([aHealthActivity()]));
        stubProcessing();

        final result = await interactor.execute();

        expect(result.outcome, SyncHealthOutcome.synced);
        expect(result.permissionResolution, SyncPermissionResolution.none);
        expect(result.syncedEvents, hasLength(1));
        verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
            .called(1);
        expect(toleratedEmitted(), isFalse);
      });

      test('sync disabled: skippedDisabled, never fetches', () async {
        when(() => mockHealthSyncRepository.isHealthSyncEnabled())
            .thenAnswer((_) async => false);

        final result = await interactor.execute();

        expect(result.outcome, SyncHealthOutcome.skippedDisabled);
        expect(result.permissionResolution, SyncPermissionResolution.none);
        verifyNever(() => mockHealthSyncRepository.fetchActivitiesResult(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            ));
      });
    });

    group('imported event ids and the local collision guard', () {
      const idFactory = ImportedWorkoutEventIdFactory();

      void stubHappyPath({
        List<HealthSyncMetadata> existingMetadata = const [],
      }) {
        when(() => mockHealthSyncRepository.isHealthSyncEnabled())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.hasPermissions())
            .thenAnswer((_) async => true);
        when(() => mockHealthSyncRepository.getLastSyncTime())
            .thenAnswer((_) async => null);
        when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
        when(() => mockLocalStorageRepository
                .getMasterFile(MasterFilesType.sportsInfo))
            .thenAnswer((_) async => testSportsInfo);
        when(() => mockHealthSyncRepository.getSyncedMetadata())
            .thenAnswer((_) async => existingMetadata);
        when(() => mockSaveSportEventInteractor.execute(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockSportEventsRepository.syncToBackend(any()))
            .thenAnswer((_) {});
        when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
            .thenAnswer((_) async {});
        when(() => mockHealthSyncRepository.setLastSyncTime(any()))
            .thenAnswer((_) async {});
      }

      void stubFetch(List<HealthActivity> activities) {
        when(() => mockHealthSyncRepository.fetchActivitiesResult(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => successResult(activities));
      }

      SportEventEntity localEventWith(int eventId, {String source = 'manual'}) {
        return SportEventEntity(
          userId: 'user123',
          eventDate: DateTime(2026, 7, 1).millisecondsSinceEpoch,
          sportName: 'Padel',
          info: [],
          eventKcals: 300,
          eventId: eventId,
          source: source,
        );
      }

      test(
        'a new import carries the deterministic factory eventId in the saved '
        'event, the backend payload, and the metadata mapping',
        () async {
          final activity = aHealthActivity(
            healthPlatformId: 'factory_id_activity',
            startTime: DateTime(2026, 7, 1, 8, 0, 0),
            endTime: DateTime(2026, 7, 1, 9, 0, 0),
          );
          final expectedEventId = idFactory.eventIdFor(
            HealthWorkoutFingerprint.fromActivity(activity),
          );
          stubHappyPath();
          stubFetch([activity]);

          final result = await interactor.execute();

          expect(result.outcome, SyncHealthOutcome.synced);
          expect(result.syncedEvents.single.eventId, expectedEventId);
          // No longer raw start-millis: the seconds bucket is the start time,
          // the suffix is the fingerprint hash.
          expect(
            expectedEventId ~/ 1000,
            activity.startTime.millisecondsSinceEpoch ~/ 1000,
          );

          final backendPayload = verify(
            () => mockSportEventsRepository.syncToBackend(captureAny()),
          ).captured.single as SportEventComplete;
          expect(backendPayload.eventId, expectedEventId);

          final savedMetadata = verify(
            () => mockHealthSyncRepository.saveHealthSyncMetadata(captureAny()),
          ).captured.single as HealthSyncMetadata;
          expect(savedMetadata.sportEventId, expectedEventId);
          expect(savedMetadata.healthPlatformId, 'factory_id_activity');
        },
      );

      test(
        'previously synced workouts are deduped by metadata before id '
        'generation — no eventId churn for existing data',
        () async {
          final activity = aHealthActivity(
            healthPlatformId: 'already_synced_platform_id',
          );
          stubHappyPath(existingMetadata: [
            HealthSyncMetadata(
              healthPlatformId: 'already_synced_platform_id',
              sportEventId: 1234567890123,
              syncedAt: DateTime(2026, 6, 30),
              sourceType: 'apple_health',
            ),
          ]);
          stubFetch([activity]);

          final result = await interactor.execute();

          expect(result.syncedEvents, isEmpty);
          expect(result.outcome, SyncHealthOutcome.synced);
          // Deduped before any id work: neither the guard nor any save ran.
          verifyNever(
            () => mockLocalStorageRepository.findSportEventByEventId(any()),
          );
          verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));
          verifyNever(
            () => mockHealthSyncRepository.saveHealthSyncMetadata(any()),
          );
        },
      );

      test(
        'two different workouts with identical startTime import as two '
        'distinct local events with distinct deterministic ids',
        () async {
          final start = DateTime(2026, 7, 1, 8, 0, 0);
          final running = aHealthActivity(
            healthPlatformId: 'same_second_running',
            activityType: 'RUNNING',
            startTime: start,
            endTime: start.add(const Duration(minutes: 60)),
            durationMinutes: 60,
          );
          final cycling = aHealthActivity(
            healthPlatformId: 'same_second_cycling',
            activityType: 'CYCLING',
            startTime: start,
            endTime: start.add(const Duration(minutes: 45)),
            durationMinutes: 45,
          );
          stubHappyPath();
          stubFetch([running, cycling]);

          final result = await interactor.execute();

          expect(result.syncedEvents, hasLength(2));
          final ids = result.syncedEvents.map((e) => e.eventId).toSet();
          expect(ids, hasLength(2)); // distinct despite the identical start
          // Both share the second bucket; the hash suffix disambiguates.
          expect(
            result.syncedEvents.map((e) => e.eventId ~/ 1000).toSet(),
            {start.millisecondsSinceEpoch ~/ 1000},
          );
          verify(() => mockSaveSportEventInteractor.execute(any(), any()))
              .called(2);
        },
      );

      test(
        'an occupied eventId skips the activity with an eventIdCollision '
        'diagnostic, never overwrites the existing local event, and never '
        'pays for kcal resolution (guard runs before the kcal block)',
        () async {
          // No platform calories: if the guard did NOT run before the kcal
          // block, this activity would force a getProfile() + METs
          // enrichment call before being skipped.
          final activity = aHealthActivity(
            healthPlatformId: 'colliding_activity',
            caloriesBurned: null,
          );
          final fingerprint = HealthWorkoutFingerprint.fromActivity(activity);
          final collidingId = idFactory.eventIdFor(fingerprint);
          stubHappyPath();
          stubFetch([activity]);
          when(() => mockLocalStorageRepository
                  .findSportEventByEventId(collidingId))
              .thenAnswer((_) async => localEventWith(collidingId));

          final result = await interactor.execute();

          // The ACTIVITY is skipped; the sync itself still succeeds and the
          // window advances (the platform read was genuine).
          expect(result.syncedEvents, isEmpty);
          expect(result.outcome, SyncHealthOutcome.synced);
          verify(() => mockHealthSyncRepository.setLastSyncTime(any()))
              .called(1);

          // No local save, no backend sync, no metadata write: the occupying
          // manual event is untouched and nothing half-imports.
          verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));
          verifyNever(() => mockSportEventsRepository.syncToBackend(any()));
          verifyNever(
            () => mockHealthSyncRepository.saveHealthSyncMetadata(any()),
          );
          // Collision guard runs before the kcal-resolution block: the
          // profile lookup and METs enrichment are never reached.
          verifyNever(() => mockLocalStorageRepository.getProfile());
          verifyNever(() => mockSportKcalCalculationService.enrichSportEvent(
                any(),
                userWeight: any(named: 'userWeight'),
              ));

          final collisionEvents = diagnostics.events
              .where((e) => e.type == HealthSyncDiagnosticType.eventIdCollision)
              .toList();
          expect(collisionEvents, hasLength(1));
          expect(collisionEvents.single.domain, HealthSyncDomain.workout);
          expect(
            collisionEvents.single.severity,
            HealthSyncDiagnosticSeverity.warning,
          );
          expect(
            collisionEvents.single.metadata,
            {'sourceCategory': fingerprint.sourceCategory.name},
          );
        },
      );

      test(
        'metadata-wiped self-collision: the re-import targets its own old id, '
        'skips, and creates no duplicate',
        () async {
          // The activity was imported before, its metadata was wiped (so
          // dedupe cannot catch it), but its old event is still local. The
          // deterministic id reproduces the SAME id, so the guard converts
          // yesterday's silent self-overwrite into a clean skip.
          final activity = aHealthActivity(
            healthPlatformId: 'metadata_wiped_activity',
          );
          final selfId = idFactory.eventIdFor(
            HealthWorkoutFingerprint.fromActivity(activity),
          );
          stubHappyPath(); // no metadata — the wipe
          stubFetch([activity]);
          when(() => mockLocalStorageRepository.findSportEventByEventId(selfId))
              .thenAnswer(
            (_) async => localEventWith(selfId, source: 'apple_health'),
          );

          final result = await interactor.execute();

          expect(result.syncedEvents, isEmpty);
          expect(result.outcome, SyncHealthOutcome.synced);
          verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));
          expect(
            diagnostics.events
                .where(
                  (e) => e.type == HealthSyncDiagnosticType.eventIdCollision,
                )
                .length,
            1,
          );
        },
      );

      test('a collision on one activity does not block the rest of the batch',
          () async {
        final start1 = DateTime(2026, 7, 1, 8, 0, 0);
        final start2 = DateTime(2026, 7, 1, 10, 0, 0);
        final blocked = aHealthActivity(
          healthPlatformId: 'blocked_activity',
          startTime: start1,
          endTime: start1.add(const Duration(hours: 1)),
        );
        final imported = aHealthActivity(
          healthPlatformId: 'imported_activity',
          startTime: start2,
          endTime: start2.add(const Duration(hours: 1)),
        );
        final blockedId = idFactory.eventIdFor(
          HealthWorkoutFingerprint.fromActivity(blocked),
        );
        stubHappyPath();
        stubFetch([blocked, imported]);
        when(() =>
                mockLocalStorageRepository.findSportEventByEventId(blockedId))
            .thenAnswer((_) async => localEventWith(blockedId));

        final result = await interactor.execute();

        expect(result.syncedEvents, hasLength(1));
        expect(
          result.syncedEvents.single.eventId,
          idFactory.eventIdFor(HealthWorkoutFingerprint.fromActivity(imported)),
        );
        expect(result.outcome, SyncHealthOutcome.synced);
        verify(() => mockSaveSportEventInteractor.execute(any(), any()))
            .called(1);
      });
    });
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

    void stubHappyPath() {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('user123');
      when(() => mockLocalStorageRepository
              .getMasterFile(MasterFilesType.sportsInfo))
          .thenAnswer((_) async => testSportsInfo);
      when(() => mockHealthSyncRepository.getSyncedMetadata())
          .thenAnswer((_) async => <HealthSyncMetadata>[]);
      when(() => mockSaveSportEventInteractor.execute(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockSportEventsRepository.syncToBackend(any()))
          .thenAnswer((_) {});
      when(() => mockHealthSyncRepository.saveHealthSyncMetadata(any()))
          .thenAnswer((_) async {});
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});
    }

    void stubFetch(List<HealthActivity> activities) {
      when(() => mockHealthSyncRepository.fetchActivitiesResult(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => successResult(activities));
    }

    test(
        'a MET-computed import logs no exact weight, kcal, raw platform id, '
        'or exact sync-window timestamps', () async {
      final activity = HealthActivity(
        healthPlatformId: 'uuid-privacy-sentinel-42',
        legacyPlatformId: 'legacy-privacy-sentinel',
        activityType: 'RUNNING',
        startTime: DateTime(2026, 7, 1, 8, 0),
        endTime: DateTime(2026, 7, 1, 9, 0),
        durationMinutes: 60,
        caloriesBurned: null, // forces the METs-computed kcal path
        distance: 5000,
        avgHeartRate: null,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );
      final profile = UserProfileEntity(
        userId: 'user123',
        commonName: 'Test',
        birthDate: 0,
        sex: 0,
        occupationActivityFactor: 1.4,
        objectives: const [],
        physicalCharacteristics:
            PhysicalCharacteristics(height: 175.0, weight: 81.5),
      );
      final enriched = SportEventComplete(
        userId: 'user123',
        eventId: activity.startTime.millisecondsSinceEpoch,
        eventDate: DateTime(2026, 7, 1).millisecondsSinceEpoch,
        sportName: 'Running',
        source: 'apple_health',
        eventKcals: 517,
        info: [],
      );
      stubHappyPath();
      stubFetch([activity]);
      when(() => mockLocalStorageRepository.getProfile())
          .thenAnswer((_) async => profile);
      when(() => mockSportKcalCalculationService.enrichSportEvent(
            any(),
            userWeight: any(named: 'userWeight'),
          )).thenAnswer((_) async => enriched);

      final result = await interactor.execute();
      expect(result.outcome, SyncHealthOutcome.synced);

      final joined = capturedLogs.join('\n');
      expect(joined, isNot(contains('81.5'))); // exact user weight
      expect(joined, isNot(contains('517'))); // computed kcal value
      expect(joined,
          isNot(contains('uuid-privacy-sentinel-42'))); // raw platform id
      expect(joined, isNot(contains('duration='))); // exact duration
      // The sync window must be logged coarsely, never as exact timestamps.
      expect(joined, isNot(matches(RegExp(r'Sync window.*\d{4}-\d{2}-\d{2}'))));
    });

    test('a platform-kcal import logs no exact kcal value', () async {
      final activity = HealthActivity(
        healthPlatformId: 'uuid-platform-kcal-privacy',
        legacyPlatformId: 'legacy-platform-kcal-privacy',
        activityType: 'RUNNING',
        startTime: DateTime(2026, 7, 1, 8, 0),
        endTime: DateTime(2026, 7, 1, 9, 0),
        durationMinutes: 60,
        caloriesBurned: 421, // platform value → platform kcal-source path
        distance: 5000,
        avgHeartRate: null,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );
      stubHappyPath();
      stubFetch([activity]);
      when(() => mockLocalStorageRepository.getProfile())
          .thenAnswer((_) async => null);

      final result = await interactor.execute();
      expect(result.outcome, SyncHealthOutcome.synced);

      final joined = capturedLogs.join('\n');
      expect(joined, isNot(contains('421'))); // exact platform kcal
    });

    test('the eventId collision guard logs no raw event id value', () async {
      final activity = aHealthActivity(
        healthPlatformId: 'collision-privacy-id',
        startTime: DateTime(2026, 7, 1, 8, 0, 0),
        endTime: DateTime(2026, 7, 1, 9, 0, 0),
      );
      final expectedEventId = const ImportedWorkoutEventIdFactory()
          .eventIdFor(HealthWorkoutFingerprint.fromActivity(activity));
      stubHappyPath();
      stubFetch([activity]);
      when(() => mockLocalStorageRepository.getProfile())
          .thenAnswer((_) async => null);
      when(() => mockLocalStorageRepository
              .findSportEventByEventId(expectedEventId))
          .thenAnswer((_) async => SportEventEntity(
                userId: 'user123',
                eventDate: DateTime(2026, 7, 1).millisecondsSinceEpoch,
                sportName: 'Padel',
                info: [],
                eventKcals: 300,
                eventId: expectedEventId,
                source: 'manual',
              ));

      await interactor.execute();

      final joined = capturedLogs.join('\n');
      // The collision must still be logged, but without the raw id value.
      expect(joined, contains('collision guard'));
      expect(joined, isNot(matches(RegExp(r'eventId \d'))));
      expect(joined, isNot(contains('$expectedEventId')));
    });
  });
}
