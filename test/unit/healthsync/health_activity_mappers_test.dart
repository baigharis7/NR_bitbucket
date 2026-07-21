import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/health_activity_mappers.dart';

void main() {
  late SportsInfoEntity testSportsInfo;
  late HealthActivity testActivity;

  setUp(() {
    testSportsInfo = SportsInfoEntity(
      id: 1,
      v: 1,
      data: [
        SportInfoEntity(id: 1, en: 'Running', es: 'Correr', mets: 8),
        SportInfoEntity(id: 2, en: 'Walking', es: 'Caminar', mets: 3),
      ],
    );

    testActivity = HealthActivity(
      healthPlatformId: 'test_platform_id_123',
      legacyPlatformId: 'legacy_test_platform_id_123',
      activityType: 'RUNNING',
      startTime: DateTime(2024, 1, 15, 10, 0),
      endTime: DateTime(2024, 1, 15, 11, 0),
      durationMinutes: 60,
      caloriesBurned: 500,
      distance: 10000, // 10 km in meters
      avgHeartRate: 150,
      sourceName: 'Apple Health',
      sourceType: 'apple_health',
    );
  });

  group('mapHealthActivityToSportEventSimple', () {
    test('creates SportEventSimple with correct basic properties', () {
      final result = mapHealthActivityToSportEventSimple(
        activity: testActivity,
        userId: 'user123',
        sportId: 1,
        sportsInfo: testSportsInfo,
      );

      final expectedMidnight = DateTime(2024, 1, 15).millisecondsSinceEpoch;
      expect(result.userId, 'user123');
      expect(result.eventDate, expectedMidnight);
      expect(result.sportName, 'Running');
      expect(result.source, 'apple_health');
    });

    test('creates SportEventSimple with correct sport info', () {
      final result = mapHealthActivityToSportEventSimple(
        activity: testActivity,
        userId: 'user123',
        sportId: 1,
        sportsInfo: testSportsInfo,
      );

      expect(result.info, isNotEmpty);
      expect(result.info!.length, 1);

      final info = result.info!.first;
      expect(info.id, 1);
      expect(info.name_en, 'Running');
      expect(info.name_es, 'Correr');
      expect(info.minutes, 60);
      expect(info.distance, 10000);
      expect(info.avgHeartRate, 150);
    });

    test('infers high intensity from high heart rate', () {
      final highIntensityActivity = HealthActivity(
        healthPlatformId: 'test_id',
        legacyPlatformId: 'legacy_test_id',
        activityType: 'RUNNING',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        durationMinutes: 60,
        caloriesBurned: 500,
        distance: 10000,
        avgHeartRate: 170, // High heart rate
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      final result = mapHealthActivityToSportEventSimple(
        activity: highIntensityActivity,
        userId: 'user123',
        sportId: 1,
        sportsInfo: testSportsInfo,
      );

      expect(result.info!.first.intensity, 2); // High intensity
    });

    test('infers low intensity from low heart rate', () {
      final lowIntensityActivity = HealthActivity(
        healthPlatformId: 'test_id',
        legacyPlatformId: 'legacy_test_id',
        activityType: 'WALKING',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        durationMinutes: 60,
        caloriesBurned: 200,
        distance: 5000,
        avgHeartRate: 80, // Low heart rate
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      final result = mapHealthActivityToSportEventSimple(
        activity: lowIntensityActivity,
        userId: 'user123',
        sportId: 2,
        sportsInfo: testSportsInfo,
      );

      expect(result.info!.first.intensity, 0); // Low intensity
    });

    test('uses activity type as fallback when sport not found', () {
      final unknownSportActivity = HealthActivity(
        healthPlatformId: 'test_id',
        legacyPlatformId: 'legacy_test_id',
        activityType: 'UNKNOWN_SPORT',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        durationMinutes: 60,
        caloriesBurned: 300,
        distance: null,
        avgHeartRate: null,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      final result = mapHealthActivityToSportEventSimple(
        activity: unknownSportActivity,
        userId: 'user123',
        sportId: 999, // Non-existent sport ID
        sportsInfo: testSportsInfo,
      );

      expect(result.sportName, 'UNKNOWN_SPORT');
    });
  });

  group('mapHealthActivityToSportEventComplete', () {
    test('creates SportEventComplete with correct properties', () {
      final result = mapHealthActivityToSportEventComplete(
        activity: testActivity,
        userId: 'user123',
        eventId: 42,
        sportId: 1,
        sportsInfo: testSportsInfo,
        eventKcals: 500,
      );

      final expectedMidnight = DateTime(2024, 1, 15).millisecondsSinceEpoch;
      expect(result.userId, 'user123');
      expect(result.eventId, 42);
      expect(result.eventDate, expectedMidnight);
      expect(result.sportName, 'Running');
      expect(result.source, 'apple_health');
      expect(result.eventKcals, 500);
    });

    test('creates SportEventComplete with correct sport event info', () {
      final result = mapHealthActivityToSportEventComplete(
        activity: testActivity,
        userId: 'user123',
        eventId: 42,
        sportId: 1,
        sportsInfo: testSportsInfo,
        eventKcals: 500,
      );

      expect(result.info, isNotEmpty);
      expect(result.info!.length, 1);

      final info = result.info!.first;
      expect(info.id, 1);
      expect(info.name_en, 'Running');
      expect(info.name_es, 'Correr');
      expect(info.minutes, 60);
      expect(info.distance, 10000);
      expect(info.avgHeartRate, 150);
      expect(info.kcal, 500);
      expect(info.timeStart, testActivity.startTime.millisecondsSinceEpoch);
    });

    test('handles null distance and heart rate', () {
      final activityWithNulls = HealthActivity(
        healthPlatformId: 'test_id',
        legacyPlatformId: 'legacy_test_id',
        activityType: 'RUNNING',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        durationMinutes: 60,
        caloriesBurned: 500,
        distance: null,
        avgHeartRate: null,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      final result = mapHealthActivityToSportEventComplete(
        activity: activityWithNulls,
        userId: 'user123',
        eventId: 42,
        sportId: 1,
        sportsInfo: testSportsInfo,
        eventKcals: 500,
      );

      final info = result.info!.first;
      expect(info.distance, null);
      expect(info.avgHeartRate, null);
    });

    test('info[0].kcal mirrors eventKcals param even when activity calories are null', () {
      // Simulates a synced workout with no platform-supplied calories where the
      // caller has computed a fallback eventKcals via SportKcalCalculationService.
      final activityNoCalories = HealthActivity(
        healthPlatformId: 'no_cal_id',
        legacyPlatformId: 'legacy_no_cal_id',
        activityType: 'RUNNING',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 10, 30),
        durationMinutes: 30,
        caloriesBurned: null,
        distance: 5000,
        avgHeartRate: null,
        sourceName: 'Apple Health',
        sourceType: 'apple_health',
      );

      final result = mapHealthActivityToSportEventComplete(
        activity: activityNoCalories,
        userId: 'user123',
        eventId: 99,
        sportId: 1,
        sportsInfo: testSportsInfo,
        eventKcals: 280, // computed fallback
      );

      expect(result.eventKcals, 280);
      expect(result.info!.first.kcal, 280); // inner kcal stays in sync with outer
    });

    test('info[0].kcal differs from activity.caloriesBurned when caller overrides', () {
      // Even when the activity has its own caloriesBurned, the mapper should
      // honour the eventKcals parameter for both fields (single source of truth).
      final result = mapHealthActivityToSportEventComplete(
        activity: testActivity, // caloriesBurned: 500
        userId: 'user123',
        eventId: 42,
        sportId: 1,
        sportsInfo: testSportsInfo,
        eventKcals: 555, // caller passes a different value
      );

      expect(result.eventKcals, 555);
      expect(result.info!.first.kcal, 555);
    });
  });

  group('HealthSyncMetadata mapping', () {
    test('mapToHealthSyncMetadataEntity converts correctly', () {
      final metadata = HealthSyncMetadata(
        healthPlatformId: 'platform_123',
        sportEventId: 42,
        syncedAt: DateTime(2024, 1, 15, 12, 30),
        sourceType: 'apple_health',
      );

      final entity = mapToHealthSyncMetadataEntity(metadata);

      expect(entity.healthPlatformId, 'platform_123');
      expect(entity.sportEventId, 42);
      expect(entity.syncedAt, DateTime(2024, 1, 15, 12, 30).millisecondsSinceEpoch);
      expect(entity.sourceType, 'apple_health');
    });

    test('mapToHealthSyncMetadata converts entity back correctly', () {
      final metadata = HealthSyncMetadata(
        healthPlatformId: 'platform_456',
        sportEventId: 99,
        syncedAt: DateTime(2024, 2, 20, 15, 45),
        sourceType: 'health_connect',
      );

      final entity = mapToHealthSyncMetadataEntity(metadata);
      final result = mapToHealthSyncMetadata(entity);

      expect(result.healthPlatformId, 'platform_456');
      expect(result.sportEventId, 99);
      expect(result.syncedAt, DateTime(2024, 2, 20, 15, 45));
      expect(result.sourceType, 'health_connect');
    });

    test('round-trip preserves all data', () {
      final original = HealthSyncMetadata(
        healthPlatformId: 'round_trip_test',
        sportEventId: 123,
        syncedAt: DateTime(2024, 3, 10, 8, 0, 30),
        sourceType: 'apple_health',
      );

      final entity = mapToHealthSyncMetadataEntity(original);
      final result = mapToHealthSyncMetadata(entity);

      expect(result.healthPlatformId, original.healthPlatformId);
      expect(result.sportEventId, original.sportEventId);
      // Note: milliseconds precision is preserved
      expect(
        result.syncedAt.millisecondsSinceEpoch,
        original.syncedAt.millisecondsSinceEpoch,
      );
      expect(result.sourceType, original.sourceType);
    });

    test('round-trips the fingerprint fields', () {
      final original = HealthSyncMetadata(
        healthPlatformId: 'uuid_abc',
        sportEventId: 7,
        syncedAt: DateTime(2026, 7, 18, 9, 30),
        sourceType: 'health_connect',
        normalizedType: 'RUNNING',
        startTimeMs: 1000000000000,
        endTimeMs: 1000003600000,
        sourceCategory: 'samsungHealth',
      );

      final entity = mapToHealthSyncMetadataEntity(original);
      expect(entity.normalizedType, 'RUNNING');
      expect(entity.startTimeMs, 1000000000000);
      expect(entity.endTimeMs, 1000003600000);
      expect(entity.sourceCategory, 'samsungHealth');

      final result = mapToHealthSyncMetadata(entity);
      expect(result.normalizedType, 'RUNNING');
      expect(result.startTimeMs, 1000000000000);
      expect(result.endTimeMs, 1000003600000);
      expect(result.sourceCategory, 'samsungHealth');
    });

    test('legacy records without fingerprint fields round-trip as nulls', () {
      final legacy = HealthSyncMetadata(
        healthPlatformId: 'legacy_key',
        sportEventId: 8,
        syncedAt: DateTime(2026, 7, 18, 9, 30),
        sourceType: 'apple_health',
      );

      final entity = mapToHealthSyncMetadataEntity(legacy);
      expect(entity.normalizedType, isNull);
      expect(entity.startTimeMs, isNull);
      expect(entity.endTimeMs, isNull);
      expect(entity.sourceCategory, isNull);
      expect(entity.deletedAtMs, isNull);

      final result = mapToHealthSyncMetadata(entity);
      expect(result.normalizedType, isNull);
      expect(result.sourceCategory, isNull);
      expect(result.deletedAt, isNull);
      expect(result.isDeleted, isFalse);
    });

    test('round-trips a tombstoned deletedAt instant', () {
      final original = HealthSyncMetadata(
        healthPlatformId: 'tombstoned_key',
        sportEventId: 55,
        syncedAt: DateTime(2026, 7, 18, 9, 30),
        sourceType: 'apple_health',
        deletedAt: DateTime(2026, 7, 19, 14, 0, 5),
      );

      final entity = mapToHealthSyncMetadataEntity(original);
      expect(
        entity.deletedAtMs,
        DateTime(2026, 7, 19, 14, 0, 5).millisecondsSinceEpoch,
      );

      final result = mapToHealthSyncMetadata(entity);
      expect(result.deletedAt, DateTime(2026, 7, 19, 14, 0, 5));
      expect(result.isDeleted, isTrue);
    });
  });
}
