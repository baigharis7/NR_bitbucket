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

import '../../mocks/health_sync_mocks.dart';

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

    interactor = SyncHealthActivitiesInteractorImpl(
      healthSyncRepository: mockHealthSyncRepository,
      localStorageRepository: mockLocalStorageRepository,
      preferencesRepository: mockPreferencesRepository,
      saveSportEventInteractor: mockSaveSportEventInteractor,
      sportEventsRepository: mockSportEventsRepository,
      sportKcalCalculationService: mockSportKcalCalculationService,
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
    test('returns empty list when sync is disabled', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => false);

      final result = await interactor.execute();

      expect(result, isEmpty);
      verifyNever(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ));
    });

    test('returns empty list when user has no permissions', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => false);

      final result = await interactor.execute();

      expect(result, isEmpty);
      verifyNever(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ));
    });

    test('returns empty list when synced recently (throttling)', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      // Last sync was 5 minutes ago (within 15 min throttle)
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(minutes: 5)));

      final result = await interactor.execute();

      expect(result, isEmpty);
      verifyNever(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ));
    });

    test('returns empty list when user ID is empty', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.getLastSyncTime())
          .thenAnswer((_) async => null);
      when(() => mockPreferencesRepository.getSub()).thenReturn('');

      final result = await interactor.execute();

      expect(result, isEmpty);
    });

    test('returns empty list when sports info not available', () async {
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

      expect(result, isEmpty);
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
      when(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);
      when(() => mockHealthSyncRepository.fetchSteps(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      await interactor.execute();

      verify(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).called(1);
    });

    test('deduplicates already synced activities', () async {
      final activity = HealthActivity(
        healthPlatformId: 'already_synced_id',
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
      when(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => [activity]);
      when(() => mockHealthSyncRepository.fetchSteps(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);
      // Activity is already synced
      when(() => mockHealthSyncRepository.isAlreadySynced('already_synced_id'))
          .thenAnswer((_) async => true);
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      final result = await interactor.execute();

      expect(result, isEmpty);
      verifyNever(() => mockSaveSportEventInteractor.execute(any(), any()));
    });

    test('processes new activities successfully', () async {
      final activity = HealthActivity(
        healthPlatformId: 'new_activity_id',
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
      when(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => [activity]);
      when(() => mockHealthSyncRepository.fetchSteps(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);
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

      expect(result, hasLength(1));
      expect(result.first.source, 'apple_health');
      expect(result.first.eventKcals, 500); // Preserves health platform calories
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
      when(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async {
        fetchActivitiesCalled = true;
        return [];
      });
      when(() => mockHealthSyncRepository.fetchSteps(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);
      when(() => mockHealthSyncRepository.setLastSyncTime(any()))
          .thenAnswer((_) async {});

      // Passing a specific date bypasses throttle
      await interactor.execute(since: DateTime.now().subtract(const Duration(days: 1)));

      expect(fetchActivitiesCalled, isTrue);
    });

    test('handles errors gracefully and returns empty list', () async {
      when(() => mockHealthSyncRepository.isHealthSyncEnabled())
          .thenThrow(Exception('Test error'));

      final result = await interactor.execute();

      expect(result, isEmpty);
    });

    test('computes kcal locally via METs when platform calories are missing', () async {
      // Synced workout with duration but no platform-supplied calories
      final activity = HealthActivity(
        healthPlatformId: 'no_calories_id',
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
      when(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => [activity]);
      when(() => mockHealthSyncRepository.fetchSteps(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);
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

      expect(result, hasLength(1));
      expect(result.first.eventKcals, 336); // computed kcal flows through
      expect(result.first.info, isNotEmpty);
      expect(result.first.info!.first.kcal, 336); // info kcal stays in sync with eventKcals
      verify(() => mockSportKcalCalculationService.enrichSportEvent(
            any(),
            userWeight: 80.0,
          )).called(1);
    });

    test('does not call kcal service when platform calories are present', () async {
      final activity = HealthActivity(
        healthPlatformId: 'has_calories_id',
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
      when(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => [activity]);
      when(() => mockHealthSyncRepository.fetchSteps(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);
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

      expect(result, hasLength(1));
      expect(result.first.eventKcals, 420);
      expect(result.first.info!.first.kcal, 420); // info kcal mirrors eventKcals
      verifyNever(() => mockSportKcalCalculationService.enrichSportEvent(
            any(),
            userWeight: any(named: 'userWeight'),
          ));
      verifyNever(() => mockLocalStorageRepository.getProfile());
    });

    test('falls back to 0 kcal when both calories and duration are missing', () async {
      final activity = HealthActivity(
        healthPlatformId: 'zero_duration_id',
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
      when(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => [activity]);
      when(() => mockHealthSyncRepository.fetchSteps(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);
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

      expect(result, hasLength(1));
      expect(result.first.eventKcals, 0);
      verifyNever(() => mockSportKcalCalculationService.enrichSportEvent(
            any(),
            userWeight: any(named: 'userWeight'),
          ));
    });

    test('continues processing when individual activity fails', () async {
      final activity1 = HealthActivity(
        healthPlatformId: 'activity_1',
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
      when(() => mockHealthSyncRepository.fetchActivities(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => [activity1, activity2]);
      when(() => mockHealthSyncRepository.fetchSteps(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer((_) async => []);
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
      expect(result, hasLength(1));
      expect(result.first.source, 'apple_health');
      expect(result.first.eventKcals, 200); // Preserves health platform calories
    });
  });
}
