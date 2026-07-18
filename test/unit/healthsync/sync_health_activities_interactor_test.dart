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
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sink.dart';

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
      // Activity is already synced
      when(() => mockHealthSyncRepository.isAlreadySynced('already_synced_id'))
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      final result = await interactor.execute();

      expect(result.syncedEvents, isEmpty);
      expect(result.outcome, SyncHealthOutcome.synced);
      verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));
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
      when(() => mockHealthSyncRepository.isAlreadySynced('new_activity_id'))
          .thenAnswer((_) async => false);

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
      when(() => mockHealthSyncRepository.isAlreadySynced('no_calories_id'))
          .thenAnswer((_) async => false);
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
      when(() => mockHealthSyncRepository.isAlreadySynced('has_calories_id'))
          .thenAnswer((_) async => false);
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
      when(() => mockHealthSyncRepository.isAlreadySynced('zero_duration_id'))
          .thenAnswer((_) async => false);
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
      when(() => mockHealthSyncRepository.isAlreadySynced(any()))
          .thenAnswer((_) async => false);

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
        when(() => mockHealthSyncRepository.isAlreadySynced(any()))
            .thenAnswer((_) async => false);
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
          verifyNever(() => mockHealthSyncRepository.isAlreadySynced(any()));
          verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));

          expect(diagnostics.events, hasLength(1));
          final event = diagnostics.events.single;
          expect(event.type, HealthSyncDiagnosticType.fetchFailed);
          expect(event.domain, HealthSyncDomain.workout);
          expect(event.metadata['errorCategory'], 'timeout');
          expect(event.metadata.containsKey('phase'), isFalse);
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

          expect(diagnostics.events, hasLength(1));
          expect(
            diagnostics.events.single.type,
            HealthSyncDiagnosticType.permissionDenied,
          );
          expect(diagnostics.events.single.domain, HealthSyncDomain.workout);
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

          expect(diagnostics.events, hasLength(1));
          expect(
            diagnostics.events.single.type,
            HealthSyncDiagnosticType.platformUnavailable,
          );
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

          expect(diagnostics.events, hasLength(1));
          expect(
            diagnostics.events.single.type,
            HealthSyncDiagnosticType.fetchNoData,
          );
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

          expect(diagnostics.events, hasLength(1));
          final event = diagnostics.events.single;
          expect(event.type, HealthSyncDiagnosticType.fetchSucceeded);
          expect(event.domain, HealthSyncDomain.workout);
          expect(event.metadata['count'], 1);
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

          expect(diagnostics.events, hasLength(2));
          expect(
            diagnostics.events[0].type,
            HealthSyncDiagnosticType.fetchSucceeded,
          );
          expect(diagnostics.events[0].metadata['count'], 1);
          expect(
            diagnostics.events[1].type,
            HealthSyncDiagnosticType.fetchFailed,
          );
          expect(diagnostics.events[1].metadata['errorCategory'], 'plugin');
          expect(diagnostics.events[1].metadata['phase'], 'enrichment');
        },
      );

      test(
        'per-activity processing failure is still isolated and still advances',
        () async {
          stubPreconditions();
          stubProcessing();
          stubFetch(successResult([
            aHealthActivity(healthPlatformId: 'first_fails'),
            aHealthActivity(healthPlatformId: 'second_ok'),
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
        when(() => mockHealthSyncRepository.isAlreadySynced(any()))
            .thenAnswer((_) async => false);
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
  });
}
