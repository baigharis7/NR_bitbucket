import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nutrenaissance_flutter/data/api/sleepevents/models/upload_sleep_event.dart';
import 'package:nutrenaissance_flutter/data/api/sleepevents/sleep_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/steps/models/upload_step_event_response.dart';
import 'package:nutrenaissance_flutter/data/api/steps/steps_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/healthsync/health_sync_metadata_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sleepevents/sleep_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/steps/steps_entity.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/interval_union.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

/// Implementation of HealthSyncRepository using the health package.
/// Handles communication with HealthKit (iOS) and Health Connect (Android).
class HealthSyncRepositoryImpl implements HealthSyncRepository {
  final LocalStorageRepository localStorageRepository;
  final PreferencesRepository preferencesRepository;
  final SleepEventsApi sleepEventsApi;
  final StepsApi stepsApi;
  final SyncQueueService syncQueue;

  // Lazy initialization to avoid blocking during app startup
  Health? _healthInstance;
  Health get _health => _healthInstance ??= Health();

  /// Health data types we want to read from the platform.
  /// Uses DISTANCE_DELTA on Android (DISTANCE_WALKING_RUNNING is iOS-only).
  static final List<HealthDataType> _readTypes = [
    HealthDataType.WORKOUT,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_SESSION,
    if (Platform.isIOS) HealthDataType.DISTANCE_WALKING_RUNNING,
    if (Platform.isAndroid) HealthDataType.DISTANCE_DELTA,
  ];

  /// Permissions for the health data types (all read)
  static final List<HealthDataAccess> _permissions =
      _readTypes.map((_) => HealthDataAccess.READ).toList();

  static const _platformChannel = MethodChannel('nutrenaissance/platform');

  HealthSyncRepositoryImpl({
    required this.localStorageRepository,
    required this.preferencesRepository,
    required this.sleepEventsApi,
    required this.stepsApi,
    required this.syncQueue,
  });

  @override
  Future<bool> isHealthSyncAvailable() async {
    try {
      if (!Platform.isIOS && !Platform.isAndroid) {
        return false;
      }

      if (Platform.isAndroid) {
        // Use native HealthConnectClient.getSdkStatus() to check if HC is installed.
        // The health plugin's hasPermissions probe is unreliable — it falls through
        // to Google Fit silently when HC is not installed.
        final result = await _platformChannel.invokeMethod<bool>('isHealthConnectAvailable');
        debugPrint('[HealthSync] isHealthConnectAvailable=$result');
        CrashlyticsService.instance.log('HealthSync: isHealthConnectAvailable=$result');
        return result ?? false;
      }

      // iOS: HealthKit is always available on supported devices
      return true;
    } catch (e, stack) {
      debugPrint('[HealthSync] isHealthSyncAvailable ERROR: $e');
      CrashlyticsService.record(e, stack, context: {'method': 'isHealthSyncAvailable'});
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      debugPrint('[HealthSync] requestAuthorization types=${_readTypes.map((t) => t.name).join(",")}');
      CrashlyticsService.instance.log('HealthSync: requestAuthorization types=${_readTypes.map((t) => t.name).join(",")}');
      final authorized = await _health.requestAuthorization(
        _readTypes,
        permissions: _permissions,
      );
      debugPrint('[HealthSync] requestAuthorization result=$authorized');
      CrashlyticsService.instance.log('HealthSync: requestAuthorization result=$authorized');
      return authorized;
    } catch (e, stack) {
      debugPrint('[HealthSync] requestPermissions ERROR: $e');
      CrashlyticsService.record(e, stack, context: {'method': 'requestPermissions'});
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      final authorized = await _health.hasPermissions(
        _readTypes,
        permissions: _permissions,
      );
      debugPrint('[HealthSync] hasPermissions=$authorized');
      CrashlyticsService.instance.log('HealthSync: hasPermissions=$authorized');
      return authorized ?? false;
    } catch (e, stack) {
      debugPrint('[HealthSync] hasPermissions ERROR: $e');
      CrashlyticsService.record(e, stack, context: {'method': 'hasPermissions'});
      return false;
    }
  }

  @override
  Future<List<HealthActivity>> fetchActivities({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Fetch workout data from health platform
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: startDate,
        endTime: endDate,
      );

      // Also fetch associated data for enrichment
      final energyData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: startDate,
        endTime: endDate,
      );

      final distanceType = Platform.isIOS
          ? HealthDataType.DISTANCE_WALKING_RUNNING
          : HealthDataType.DISTANCE_DELTA;
      final distanceData = await _health.getHealthDataFromTypes(
        types: [distanceType],
        startTime: startDate,
        endTime: endDate,
      );

      final heartRateData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startDate,
        endTime: endDate,
      );

      // Convert to HealthActivity list
      return _mapWorkoutsToActivities(
        healthData,
        energyData,
        distanceData,
        heartRateData,
      );
    } catch (e) {
      return [];
    }
  }

  /// Maps workout HealthDataPoints to HealthActivity domain models
  List<HealthActivity> _mapWorkoutsToActivities(
    List<HealthDataPoint> workouts,
    List<HealthDataPoint> energyData,
    List<HealthDataPoint> distanceData,
    List<HealthDataPoint> heartRateData,
  ) {
    final activities = <HealthActivity>[];

    for (final workout in workouts) {
      if (workout.type != HealthDataType.WORKOUT) continue;

      final startTime = workout.dateFrom;
      final endTime = workout.dateTo;
      final durationMinutes = endTime.difference(startTime).inMinutes;

      // Find associated energy burned during this workout window
      double? caloriesBurned;
      for (final energy in energyData) {
        if (_isOverlapping(energy.dateFrom, energy.dateTo, startTime, endTime)) {
          final value = energy.value;
          if (value is NumericHealthValue) {
            caloriesBurned = (caloriesBurned ?? 0) + value.numericValue;
          }
        }
      }

      // Find associated distance during this workout window
      double? distance;
      for (final dist in distanceData) {
        if (_isOverlapping(dist.dateFrom, dist.dateTo, startTime, endTime)) {
          final value = dist.value;
          if (value is NumericHealthValue) {
            distance = (distance ?? 0) + value.numericValue;
          }
        }
      }

      // Calculate average heart rate during this workout window
      int? avgHeartRate;
      final heartRates = <double>[];
      for (final hr in heartRateData) {
        if (_isOverlapping(hr.dateFrom, hr.dateTo, startTime, endTime)) {
          final value = hr.value;
          if (value is NumericHealthValue) {
            heartRates.add(value.numericValue.toDouble());
          }
        }
      }
      if (heartRates.isNotEmpty) {
        avgHeartRate = (heartRates.reduce((a, b) => a + b) / heartRates.length).round();
      }

      // Get workout type name and built-in energy/distance from the workout record itself
      final workoutValue = workout.value;
      String activityType = 'WORKOUT';
      if (workoutValue is WorkoutHealthValue) {
        activityType = workoutValue.workoutActivityType.name;

        // Use workout's built-in energy if separate energy data wasn't found
        if (caloriesBurned == null && workoutValue.totalEnergyBurned != null) {
          caloriesBurned = workoutValue.totalEnergyBurned!.toDouble();
        }

        // Use workout's built-in distance if separate distance data wasn't found
        if (distance == null && workoutValue.totalDistance != null) {
          distance = workoutValue.totalDistance!.toDouble();
        }
      }

      // Generate a unique ID from the workout properties
      final workoutId = '${workout.sourceName}_${workout.dateFrom.millisecondsSinceEpoch}_${workout.dateTo.millisecondsSinceEpoch}';

      debugPrint('[HealthSync] Workout: $activityType, kcal=$caloriesBurned, dist=$distance, hr=$avgHeartRate, dur=${durationMinutes}m');

      activities.add(HealthActivity(
        healthPlatformId: workoutId,
        activityType: activityType,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: durationMinutes > 0 ? durationMinutes : 1,
        caloriesBurned: caloriesBurned,
        distance: distance,
        avgHeartRate: avgHeartRate,
        sourceName: workout.sourceName,
        sourceType: Platform.isIOS ? 'apple_health' : 'health_connect',
      ));
    }

    return activities;
  }

  /// Check if two time ranges overlap
  bool _isOverlapping(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  @override
  Future<void> saveHealthSyncMetadata(HealthSyncMetadata metadata) async {
    final entity = HealthSyncMetadataEntity(
      healthPlatformId: metadata.healthPlatformId,
      sportEventId: metadata.sportEventId,
      syncedAt: metadata.syncedAt.millisecondsSinceEpoch,
      sourceType: metadata.sourceType,
    );
    await localStorageRepository.saveHealthSyncMetadata(entity);
  }

  @override
  Future<List<HealthSyncMetadata>> getSyncedMetadata() async {
    final entities = await localStorageRepository.getHealthSyncMetadata();
    return entities.map((e) => HealthSyncMetadata(
      healthPlatformId: e.healthPlatformId,
      sportEventId: e.sportEventId,
      syncedAt: DateTime.fromMillisecondsSinceEpoch(e.syncedAt),
      sourceType: e.sourceType,
    )).toList();
  }

  @override
  Future<bool> isAlreadySynced(String healthPlatformId) async {
    return await localStorageRepository.isHealthActivitySynced(healthPlatformId);
  }

  @override
  Future<void> deleteSyncMetadataBySportEventId(int sportEventId) async {
    await localStorageRepository.deleteHealthSyncMetadataBySportEventId(sportEventId);
  }

  @override
  Future<void> setHealthSyncEnabled(bool enabled) async {
    await preferencesRepository.setBoolPref(PrefsKeys.healthSyncEnabledV2, enabled);
    CrashlyticsService.instance.log('HealthSync pref write: enabled=$enabled');
    debugPrint('[HealthSync] pref write: enabled=$enabled');
  }

  @override
  Future<bool> isHealthSyncEnabled() async {
    // V2 stores the toggle as a proper bool so we can distinguish "never set"
    // from "explicitly false". Read this first.
    final v2 = await preferencesRepository.getBoolPrefOrNull(PrefsKeys.healthSyncEnabledV2);
    if (v2 != null) {
      CrashlyticsService.instance.log('HealthSync pref read: v2=$v2');
      return v2;
    }

    // Legacy migration: builds prior to V2 stored the toggle by abusing
    // saveLastFetchTime — epoch=1 meant ON, epoch=0 meant OFF. Honor that
    // value once, then migrate to V2 so subsequent reads take the fast path.
    final legacy = await preferencesRepository.getLastFetchTime(PrefsKeys.healthSyncEnabled);
    final legacyEnabled = legacy != null && legacy.millisecondsSinceEpoch > 0;
    if (legacy != null) {
      CrashlyticsService.instance.log('HealthSync pref read: legacy=$legacyEnabled, migrating to v2');
      await preferencesRepository.setBoolPref(PrefsKeys.healthSyncEnabledV2, legacyEnabled);
    } else {
      CrashlyticsService.instance.log('HealthSync pref read: unset, defaulting false');
    }
    return legacyEnabled;
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return await preferencesRepository.getLastFetchTime(PrefsKeys.lastHealthSyncTime);
  }

  @override
  Future<void> setLastSyncTime(DateTime time) async {
    await preferencesRepository.saveLastFetchTime(PrefsKeys.lastHealthSyncTime, time);
  }

  @override
  Future<void> installHealthConnect() async {
    if (Platform.isAndroid) {
      // Health Connect Play Store URL
      const playStoreUrl = 'market://details?id=com.google.android.apps.healthdata';
      const webUrl = 'https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata';

      final uri = Uri.parse(playStoreUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback to web URL if Play Store app not available
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Future<void> openHealthConnect() async {
    if (Platform.isAndroid) {
      // Use native intent to open the Health Connect app directly
      final opened = await _platformChannel.invokeMethod<bool>('openHealthConnect');
      if (opened != true) {
        // Fallback: open Play Store listing
        const hcPackage = 'com.google.android.apps.healthdata';
        final marketUri = Uri.parse('market://details?id=$hcPackage');
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri);
        } else {
          await launchUrl(
            Uri.parse('https://play.google.com/store/apps/details?id=$hcPackage'),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    }
  }

  /// Midnight millis for a date — used as eventDate and eventId (one record per day).
  static int _midnightMillis(DateTime date) =>
      DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;

  Future<String> _getUserId() async {
    final profile = await localStorageRepository.getProfile();
    return profile?.userId ?? '';
  }

  // ── Sleep ──────────────────────────────────────────────────────────────

  @override
  Future<void> saveSleepEvent({
    required DateTime date,
    required double sleepHours,
  }) async {
    final midnight = _midnightMillis(date);
    final userId = await _getUserId();
    final sleepMinutes = (sleepHours * 60).round();

    // Save to Hive
    final entity = SleepEventEntity(
      userId: userId,
      eventDate: midnight,
      eventId: midnight,
      sleepMinutes: sleepMinutes,
    );
    await localStorageRepository.saveSleepEvent(entity);

    // Fire-and-forget to DynamoDB
    final uploadModel = UploadSleepEvent(
      userId: userId,
      eventId: midnight,
      eventDate: midnight,
      sleepMinutes: sleepMinutes,
    );
    sleepEventsApi.uploadSleepEvent(uploadModel).catchError((error) {
      syncQueue.enqueue('/sleep-event', uploadModel);
      return <String, dynamic>{};
    });
  }

  @override
  Future<double?> getSavedSleepHours(DateTime date) async {
    final entity = await localStorageRepository.getSleepEventByDate(_midnightMillis(date));
    if (entity == null) return null;
    return entity.sleepMinutes / 60.0;
  }

  // ── Steps ──────────────────────────────────────────────────────────────

  @override
  Future<void> saveStepEvent({
    required DateTime date,
    required int stepCount,
  }) async {
    final midnight = _midnightMillis(date);
    final userId = await _getUserId();

    // Save to Hive (reuses existing StepsEntity)
    final entity = StepsEntity(
      eventId: midnight,
      initialSteps: 0,
      actualSteps: stepCount,
    );
    await localStorageRepository.saveSteps(entity);

    // Fire-and-forget to DynamoDB (reuses existing /steps-count endpoint)
    final uploadModel = UploadStepEventResponse(
      userId: userId,
      eventId: midnight,
      initialSteps: 0,
      actualSteps: stepCount,
    );
    stepsApi.uploadSteps(uploadModel).catchError((error) {
      syncQueue.enqueue('/steps-count', uploadModel);
      return <String, dynamic>{};
    });
  }

  @override
  Future<int?> getSavedStepCount(DateTime date) async {
    final step = await localStorageRepository.getTodayStep();
    // getTodayStep returns a StepsEntity keyed by midnight timestamp
    final midnight = _midnightMillis(date);
    if (step.eventId != midnight) {
      // No step data for the requested date — check all step events
      final allSteps = await localStorageRepository.getTodaySteps();
      for (final s in allSteps) {
        if (s is StepsEntity && s.eventId == midnight) {
          return s.actualSteps;
        }
      }
      return null;
    }
    return step.actualSteps;
  }

  @override
  Future<double?> fetchTodaySleepHours(DateTime date) async {
    try {
      // Look for sleep sessions from 6PM the previous day to noon the following day
      final startTime = DateTime(date.year, date.month, date.day).subtract(const Duration(hours: 6));
      final endTime = DateTime(date.year, date.month, date.day, 12);

      final sleepData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_SESSION],
        startTime: startTime,
        endTime: endTime,
      );

      if (sleepData.isEmpty) return 0.0;

      // Log every session with source so we can diagnose bogus entries on
      // testers' devices (e.g. Samsung Health "scheduled sleep" goal windows
      // showing up as 8h SLEEP_SESSION records when actual sleep was 6h45m).
      for (final point in sleepData) {
        final mins = point.dateTo.difference(point.dateFrom).inMinutes;
        CrashlyticsService.instance.log(
          'HealthSync sleep session: source=${point.sourceName} '
          'from=${point.dateFrom.toIso8601String()} '
          'to=${point.dateTo.toIso8601String()} mins=$mins',
        );
      }

      // Multiple connected apps (Samsung Health, Google Fit, smartwatch) can
      // each log the same night, producing overlapping SLEEP_SESSION records.
      // Naively summing them double-counts. Union the intervals first, then
      // sum non-overlapping durations.
      final totalMinutes = sumNonOverlappingMinutes(
        sleepData.map((p) => TimeInterval(p.dateFrom, p.dateTo)),
      );
      final totalHours = totalMinutes / 60.0;

      debugPrint('[HealthSync] fetchTodaySleepHours: ${sleepData.length} sessions, '
          'merged total=$totalHours hours');
      CrashlyticsService.instance.log(
        'HealthSync sleep merged: ${sleepData.length} sessions → $totalHours hours',
      );
      return totalHours;
    } catch (e) {
      // Return null on error so callers can distinguish a real fetch failure
      // from "user has 0 sleep recorded so far today" and preserve any
      // previously saved value instead of clobbering it with 0.
      debugPrint('[HealthSync] fetchTodaySleepHours ERROR: $e');
      return null;
    }
  }


  @override
  Future<int?> fetchTodayStepCount(DateTime date) async {
    try {
      final startTime = DateTime(date.year, date.month, date.day);
      final endTime = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final stepsData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startTime,
        endTime: endTime,
      );

      int totalSteps = 0;
      for (final point in stepsData) {
        final value = point.value;
        if (value is NumericHealthValue) {
          totalSteps += value.numericValue.round();
        }
      }

      debugPrint('[HealthSync] fetchTodayStepCount: $totalSteps steps');
      return totalSteps;
    } catch (e) {
      // Return null on error — same rationale as fetchTodaySleepHours.
      debugPrint('[HealthSync] fetchTodayStepCount ERROR: $e');
      return null;
    }
  }
}
