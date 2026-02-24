import 'dart:io';

import 'package:health/health.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nutrenaissance_flutter/data/local/models/healthsync/health_sync_metadata_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

/// Implementation of HealthSyncRepository using the health package.
/// Handles communication with HealthKit (iOS) and Health Connect (Android).
class HealthSyncRepositoryImpl implements HealthSyncRepository {
  final LocalStorageRepository localStorageRepository;
  final PreferencesRepository preferencesRepository;

  // Lazy initialization to avoid blocking during app startup
  HealthFactory? _healthInstance;
  HealthFactory get _health =>
      _healthInstance ??= HealthFactory(useHealthConnectIfAvailable: true);

  /// Health data types we want to read from the platform.
  /// Uses DISTANCE_DELTA on Android (DISTANCE_WALKING_RUNNING is iOS-only).
  static final List<HealthDataType> _readTypes = [
    HealthDataType.WORKOUT,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    if (Platform.isIOS) HealthDataType.DISTANCE_WALKING_RUNNING,
    if (Platform.isAndroid) HealthDataType.DISTANCE_DELTA,
  ];

  /// Permissions for the health data types (all read)
  static final List<HealthDataAccess> _permissions =
      _readTypes.map((_) => HealthDataAccess.READ).toList();

  HealthSyncRepositoryImpl({
    required this.localStorageRepository,
    required this.preferencesRepository,
  });

  @override
  Future<bool> isHealthSyncAvailable() async {
    try {
      if (!Platform.isIOS && !Platform.isAndroid) {
        return false;
      }

      if (Platform.isAndroid) {
        // Probe Health Connect availability by calling hasPermissions.
        // Returns true/false/null if HC is installed; throws PlatformException if not.
        await _health.hasPermissions(
          [HealthDataType.STEPS],
          permissions: [HealthDataAccess.READ],
        );
      }

      // iOS: HealthKit is always available on supported devices
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final authorized = await _health.requestAuthorization(
        _readTypes,
        permissions: _permissions,
      );
      return authorized;
    } catch (e) {
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
      return authorized ?? false;
    } catch (e) {
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
        startDate,
        endDate,
        [HealthDataType.WORKOUT],
      );

      // Also fetch associated data for enrichment
      final energyData = await _health.getHealthDataFromTypes(
        startDate,
        endDate,
        [HealthDataType.ACTIVE_ENERGY_BURNED],
      );

      final distanceType = Platform.isIOS
          ? HealthDataType.DISTANCE_WALKING_RUNNING
          : HealthDataType.DISTANCE_DELTA;
      final distanceData = await _health.getHealthDataFromTypes(
        startDate,
        endDate,
        [distanceType],
      );

      final heartRateData = await _health.getHealthDataFromTypes(
        startDate,
        endDate,
        [HealthDataType.HEART_RATE],
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

  @override
  Future<List<HealthActivity>> fetchSteps({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final healthData = await _health.getHealthDataFromTypes(
        startDate,
        endDate,
        [HealthDataType.STEPS],
      );

      // Group steps by day and create activities
      return _mapStepsToActivities(healthData);
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

      // Get workout type name
      final workoutValue = workout.value;
      String activityType = 'WORKOUT';
      if (workoutValue is WorkoutHealthValue) {
        activityType = workoutValue.workoutActivityType.name;
      }

      // Generate a unique ID from the workout properties
      final workoutId = '${workout.sourceName}_${workout.dateFrom.millisecondsSinceEpoch}_${workout.dateTo.millisecondsSinceEpoch}';

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

  /// Maps step HealthDataPoints to HealthActivity domain models
  /// Groups steps by day
  List<HealthActivity> _mapStepsToActivities(List<HealthDataPoint> stepsData) {
    final activities = <HealthActivity>[];

    // Group steps by day
    final stepsByDay = <String, List<HealthDataPoint>>{};
    for (final step in stepsData) {
      final dayKey = '${step.dateFrom.year}-${step.dateFrom.month}-${step.dateFrom.day}';
      stepsByDay.putIfAbsent(dayKey, () => []).add(step);
    }

    // Create one activity per day
    for (final entry in stepsByDay.entries) {
      final daySteps = entry.value;
      if (daySteps.isEmpty) continue;

      int totalSteps = 0;
      DateTime? earliestStart;
      DateTime? latestEnd;

      for (final step in daySteps) {
        final value = step.value;
        if (value is NumericHealthValue) {
          totalSteps += value.numericValue.round();
        }
        if (earliestStart == null || step.dateFrom.isBefore(earliestStart)) {
          earliestStart = step.dateFrom;
        }
        if (latestEnd == null || step.dateTo.isAfter(latestEnd)) {
          latestEnd = step.dateTo;
        }
      }

      if (earliestStart != null && latestEnd != null && totalSteps > 0) {
        // Generate a unique ID for daily steps
        final stepId = '${daySteps.first.sourceName}_steps_${entry.key}';
        activities.add(HealthActivity(
          healthPlatformId: stepId,
          activityType: 'WALKING',
          startTime: earliestStart,
          endTime: latestEnd,
          durationMinutes: latestEnd.difference(earliestStart).inMinutes,
          caloriesBurned: totalSteps * 0.04, // Rough estimate: 0.04 kcal per step
          distance: totalSteps * 0.762, // Rough estimate: average step length ~0.762m
          avgHeartRate: null,
          sourceName: daySteps.first.sourceName,
          sourceType: Platform.isIOS ? 'apple_health' : 'health_connect',
        ));
      }
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
  Future<void> setHealthSyncEnabled(bool enabled) async {
    await preferencesRepository.saveLastFetchTime(
      PrefsKeys.healthSyncEnabled,
      enabled ? DateTime.fromMillisecondsSinceEpoch(1) : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<bool> isHealthSyncEnabled() async {
    final time = await preferencesRepository.getLastFetchTime(PrefsKeys.healthSyncEnabled);
    return time != null && time.millisecondsSinceEpoch > 0;
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
      // Try to launch Health Connect app directly via its package
      const hcPackage = 'com.google.android.apps.healthdata';
      final launchUri = Uri.parse('https://play.google.com/store/apps/details?id=$hcPackage');

      // Try the market launch URI first (opens the app if installed)
      final marketUri = Uri.parse('market://launch?id=$hcPackage');
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
