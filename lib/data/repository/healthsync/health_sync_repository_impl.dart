import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:nutrenaissance_flutter/data/api/sleepevents/models/upload_sleep_event.dart';
import 'package:nutrenaissance_flutter/data/api/sleepevents/sleep_events_api.dart';
import 'package:nutrenaissance_flutter/data/api/steps/models/upload_step_event_response.dart';
import 'package:nutrenaissance_flutter/data/api/steps/steps_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/healthsync/health_sync_metadata_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/sleepevents/sleep_event_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/steps/steps_entity.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_fetch_result.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_platform_client.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_platform_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sleep_aggregator.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_priority.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_step_aggregator.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sanitizer.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sink.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_record_attribution.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';

/// Implementation of HealthSyncRepository using the health package.
/// Handles communication with HealthKit (iOS) and Health Connect (Android).
class HealthSyncRepositoryImpl implements HealthSyncRepository {
  final LocalStorageRepository localStorageRepository;
  final PreferencesRepository preferencesRepository;
  final SleepEventsApi sleepEventsApi;
  final StepsApi stepsApi;
  final SyncQueueService syncQueue;
  final HealthPlatformClient healthPlatformClient;
  final HealthPlatformService healthPlatformService;
  final HealthSyncDiagnosticsSink diagnostics;
  final HealthStepAggregator stepAggregator;
  final HealthSleepAggregator sleepAggregator;

  HealthSyncRepositoryImpl({
    required this.localStorageRepository,
    required this.preferencesRepository,
    required this.sleepEventsApi,
    required this.stepsApi,
    required this.syncQueue,
    required this.healthPlatformClient,
    required this.healthPlatformService,
    this.diagnostics = const NoopHealthSyncDiagnosticsSink(),
    this.stepAggregator = const HealthStepAggregator(),
    this.sleepAggregator = const HealthSleepAggregator(),
  });

  /// Permissions list derived from the service's read types (one READ each).
  List<HealthDataAccess> get _permissions =>
      healthPlatformService.readTypes
          .map((_) => HealthDataAccess.READ)
          .toList();

  @override
  Future<bool> isHealthSyncAvailable() async {
    try {
      return await healthPlatformService.isHealthSyncAvailable();
    } catch (e, stack) {
      debugPrint('[HealthSync] isHealthSyncAvailable ERROR: $e');
      CrashlyticsService.record(e, stack,
          context: {'method': 'isHealthSyncAvailable'});
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      // Includes optionalReadTypes (best-effort, e.g. TOTAL_CALORIES_BURNED)
      // so authorization is requested up front; hasPermissions() gating
      // below is intentionally NOT widened to match.
      final types = [
        ...healthPlatformService.readTypes,
        ...healthPlatformService.optionalReadTypes,
      ];
      debugPrint(
          '[HealthSync] requestAuthorization types=${types.map((t) => t.name).join(",")}');
      CrashlyticsService.instance.log(
          'HealthSync: requestAuthorization types=${types.map((t) => t.name).join(",")}');
      final authorized = await healthPlatformClient.requestAuthorization(
        types,
        permissions: types.map((_) => HealthDataAccess.READ).toList(),
      );
      debugPrint('[HealthSync] requestAuthorization result=$authorized');
      CrashlyticsService.instance
          .log('HealthSync: requestAuthorization result=$authorized');
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
      final authorized = await healthPlatformClient.hasPermissions(
        healthPlatformService.readTypes,
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
    final result = await fetchActivitiesResult(
      startDate: startDate,
      endDate: endDate,
    );
    return result.data ?? <HealthActivity>[];
  }

  @override
  Future<HealthFetchResult<List<HealthActivity>>> fetchActivitiesResult({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Primary read: WORKOUT. A throw here is classified into a typed
      // failure status — without workouts there is nothing to import.
      final healthData = await healthPlatformClient.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: startDate,
        endTime: endDate,
      );

      // Enrichment reads are individually guarded: a failing read contributes
      // an empty list and only degrades the result to partialSuccess when
      // workouts were actually fetched. The FIRST failure's reason/message
      // win; message carries only the runtime type name, never raw text.
      HealthFetchFailureReason? enrichmentReason;
      String? enrichmentMessage;
      Future<List<HealthDataPoint>> guardedRead(HealthDataType type) async {
        try {
          return await healthPlatformClient.getHealthDataFromTypes(
            types: [type],
            startTime: startDate,
            endTime: endDate,
          );
        } catch (e) {
          if (enrichmentReason == null) {
            enrichmentReason = _reasonFor(e);
            enrichmentMessage = e.runtimeType.toString();
          }
          return const <HealthDataPoint>[];
        }
      }

      final energyData = await guardedRead(HealthDataType.ACTIVE_ENERGY_BURNED);
      final distanceData = await guardedRead(healthPlatformService.distanceType);
      final heartRateData = await guardedRead(HealthDataType.HEART_RATE);

      // Optional reads (e.g. Android TOTAL_CALORIES_BURNED): best-effort,
      // individually guarded like the enrichment reads above, but a failure
      // here NEVER sets enrichmentReason/enrichmentMessage — the result must
      // never degrade to partialSuccess because of an optional read.
      final totalCaloriesData = <HealthDataPoint>[];
      for (final type in healthPlatformService.optionalReadTypes) {
        try {
          final points = await healthPlatformClient.getHealthDataFromTypes(
            types: [type],
            startTime: startDate,
            endTime: endDate,
          );
          totalCaloriesData.addAll(points);
        } catch (e) {
          diagnostics.add(HealthSyncDiagnostics.fetchFailed(
            domain: HealthSyncDomain.workout,
            category: HealthSyncDiagnostics.classify(e),
            phase: 'enrichment-optional',
          ));
        }
      }

      // Convert to HealthActivity list
      final activities = _mapWorkoutsToActivities(
        healthData,
        energyData,
        distanceData,
        heartRateData,
        totalCaloriesData,
      );

      if (activities.isEmpty) {
        // Zero workouts: a clean empty window regardless of enrichment
        // failures — there is nothing enrichment could have degraded.
        return HealthFetchResult.successNoData(activities);
      }
      if (enrichmentReason != null) {
        return HealthFetchResult.partialSuccess(
          activities,
          reason: enrichmentReason,
          message: enrichmentMessage,
        );
      }
      return HealthFetchResult.success(activities);
    } catch (e) {
      return _primaryFailure(e);
    }
  }

  /// Maps a thrown primary-read (or mapping) error to a typed failure result
  /// using the same signature-based classifier as diagnostics
  /// ([HealthSyncDiagnostics.classify]) — one classifier in the codebase.
  /// The message carries only the runtime type name (parity with the
  /// previous behavior), never the raw error text.
  HealthFetchResult<List<HealthActivity>> _primaryFailure(Object e) {
    final message = e.runtimeType.toString();
    switch (HealthSyncDiagnostics.classify(e)) {
      case HealthSyncErrorCategory.permission:
        return HealthFetchResult.permissionDenied(message: message);
      case HealthSyncErrorCategory.platformUnavailable:
        return HealthFetchResult.platformUnavailable(message: message);
      case HealthSyncErrorCategory.timeout:
        return HealthFetchResult.failed(
          reason: HealthFetchFailureReason.timeout,
          message: message,
        );
      case HealthSyncErrorCategory.network:
      case HealthSyncErrorCategory.plugin:
        return HealthFetchResult.failed(
          reason: HealthFetchFailureReason.pluginError,
          message: message,
        );
      case HealthSyncErrorCategory.unknown:
        return HealthFetchResult.failed(
          reason: HealthFetchFailureReason.unknown,
          message: message,
        );
    }
  }

  /// Enrichment-failure reason for [HealthFetchResult.partialSuccess].
  HealthFetchFailureReason _reasonFor(Object e) {
    switch (HealthSyncDiagnostics.classify(e)) {
      case HealthSyncErrorCategory.permission:
        return HealthFetchFailureReason.permission;
      case HealthSyncErrorCategory.platformUnavailable:
        return HealthFetchFailureReason.platformUnavailable;
      case HealthSyncErrorCategory.timeout:
        return HealthFetchFailureReason.timeout;
      case HealthSyncErrorCategory.network:
      case HealthSyncErrorCategory.plugin:
        return HealthFetchFailureReason.pluginError;
      case HealthSyncErrorCategory.unknown:
        return HealthFetchFailureReason.unknown;
    }
  }

  /// Maps workout HealthDataPoints to HealthActivity domain models
  List<HealthActivity> _mapWorkoutsToActivities(
    List<HealthDataPoint> workouts,
    List<HealthDataPoint> energyData,
    List<HealthDataPoint> distanceData,
    List<HealthDataPoint> heartRateData,
    List<HealthDataPoint> totalCaloriesData,
  ) {
    final workoutPoints =
        workouts.where((w) => w.type == HealthDataType.WORKOUT).toList();
    final windows = [
      for (final w in workoutPoints)
        WorkoutAttributionWindow(
          start: w.dateFrom,
          end: w.dateTo,
          sourceName: w.sourceName,
        ),
    ];

    // T20: each enrichment record is attributed to at most ONE workout
    // (exclusive best-fit) instead of being summed into every overlapping
    // window. Parity with the previous per-window loops holds for a workout
    // whose overlapping enrichment records overlap no other workout window;
    // a record bridging multiple workout windows is now attributed to its
    // single best fit instead of being double-counted.
    final energySums = List<double?>.filled(windows.length, null);
    for (final energy in energyData) {
      final value = energy.value;
      if (value is! NumericHealthValue) continue;
      final i = HealthWorkoutRecordAttribution.attributeIndex(
        recordStart: energy.dateFrom,
        recordEnd: energy.dateTo,
        recordSourceName: energy.sourceName,
        windows: windows,
      );
      if (i == null) continue;
      energySums[i] = (energySums[i] ?? 0) + value.numericValue;
    }

    final distanceSums = List<double?>.filled(windows.length, null);
    for (final dist in distanceData) {
      final value = dist.value;
      if (value is! NumericHealthValue) continue;
      final i = HealthWorkoutRecordAttribution.attributeIndex(
        recordStart: dist.dateFrom,
        recordEnd: dist.dateTo,
        recordSourceName: dist.sourceName,
        windows: windows,
      );
      if (i == null) continue;
      distanceSums[i] = (distanceSums[i] ?? 0) + value.numericValue;
    }

    // T21: attributed total-calories tier — same shape as the energy/distance
    // loops above. Applied downstream only when kcal is still null after the
    // built-in totals fallback (tier 3, behind attributed active-energy and
    // the built-in totals).
    final totalCaloriesSums = List<double?>.filled(windows.length, null);
    for (final totalCalories in totalCaloriesData) {
      final value = totalCalories.value;
      if (value is! NumericHealthValue) continue;
      final i = HealthWorkoutRecordAttribution.attributeIndex(
        recordStart: totalCalories.dateFrom,
        recordEnd: totalCalories.dateTo,
        recordSourceName: totalCalories.sourceName,
        windows: windows,
      );
      if (i == null) continue;
      totalCaloriesSums[i] = (totalCaloriesSums[i] ?? 0) + value.numericValue;
    }

    final heartRatesByWindow =
        List.generate(windows.length, (_) => <double>[], growable: false);
    for (final hr in heartRateData) {
      final value = hr.value;
      if (value is! NumericHealthValue) continue;
      final i = HealthWorkoutRecordAttribution.attributeIndex(
        recordStart: hr.dateFrom,
        recordEnd: hr.dateTo,
        recordSourceName: hr.sourceName,
        windows: windows,
      );
      if (i == null) continue;
      heartRatesByWindow[i].add(value.numericValue.toDouble());
    }

    final activities = <HealthActivity>[];
    for (var i = 0; i < workoutPoints.length; i++) {
      final workout = workoutPoints[i];
      final startTime = workout.dateFrom;
      final endTime = workout.dateTo;
      final durationMinutes = endTime.difference(startTime).inMinutes;

      double? caloriesBurned = energySums[i];
      double? distance = distanceSums[i];

      int? avgHeartRate;
      final heartRates = heartRatesByWindow[i];
      if (heartRates.isNotEmpty) {
        avgHeartRate =
            (heartRates.reduce((a, b) => a + b) / heartRates.length).round();
      }

      // Built-in totals fallback. On iOS these are genuine per-session
      // HKWorkout totals; on Android the plugin fabricates them by
      // window-summing records over the session window, so they are only
      // safe when this workout overlaps no other fetched workout (T20).
      final workoutValue = workout.value;
      String activityType = 'WORKOUT';
      if (workoutValue is WorkoutHealthValue) {
        activityType = workoutValue.workoutActivityType.name;
        final builtInTotalsTrusted =
            healthPlatformService.workoutTotalsAreSessionScoped ||
                !_overlapsAnotherWorkout(windows, i);
        if (caloriesBurned == null &&
            workoutValue.totalEnergyBurned != null &&
            builtInTotalsTrusted) {
          caloriesBurned = workoutValue.totalEnergyBurned!.toDouble();
        }
        if (distance == null &&
            workoutValue.totalDistance != null &&
            builtInTotalsTrusted) {
          distance = workoutValue.totalDistance!.toDouble();
        }
      }
      // T21: attributed platform total-calories, only if still null after
      // attributed active-energy (above) and the built-in totals fallback.
      caloriesBurned ??= totalCaloriesSums[i];

      // Canonical identity: the platform record UUID (Health Connect
      // metadata.id / HealthKit HKObject.uuid) when present. The legacy
      // synthesized id is ALWAYS computed too — it keys metadata written
      // before the uuid upgrade, so existing users don't re-import.
      final legacyId = '${workout.sourceName}_${workout.dateFrom.millisecondsSinceEpoch}_${workout.dateTo.millisecondsSinceEpoch}';
      final workoutId = workout.uuid.isNotEmpty ? workout.uuid : legacyId;

      debugPrint('[HealthSync] Workout mapped: $activityType');

      activities.add(HealthActivity(
        healthPlatformId: workoutId,
        legacyPlatformId: legacyId,
        activityType: activityType,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: durationMinutes > 0 ? durationMinutes : 1,
        caloriesBurned: caloriesBurned,
        distance: distance,
        avgHeartRate: avgHeartRate,
        sourceName: workout.sourceName,
        sourceType: healthPlatformService.importedSourceType,
      ));
    }

    return activities;
  }

  /// Whether workout [index] overlaps any OTHER fetched workout window.
  bool _overlapsAnotherWorkout(List<WorkoutAttributionWindow> windows, int index) {
    final w = windows[index];
    for (var i = 0; i < windows.length; i++) {
      if (i == index) continue;
      if (_isOverlapping(windows[i].start, windows[i].end, w.start, w.end)) {
        return true;
      }
    }
    return false;
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
      normalizedType: metadata.normalizedType,
      startTimeMs: metadata.startTimeMs,
      endTimeMs: metadata.endTimeMs,
      sourceCategory: metadata.sourceCategory,
      deletedAtMs: metadata.deletedAt?.millisecondsSinceEpoch,
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
      normalizedType: e.normalizedType,
      startTimeMs: e.startTimeMs,
      endTimeMs: e.endTimeMs,
      sourceCategory: e.sourceCategory,
      deletedAt: e.deletedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(e.deletedAtMs!),
    )).toList();
  }

  @override
  Future<bool> isAlreadySynced(String healthPlatformId) async {
    return await localStorageRepository.isHealthActivitySynced(healthPlatformId);
  }

  @override
  Future<void> tombstoneSyncMetadataBySportEventId(int sportEventId) async {
    await localStorageRepository.tombstoneHealthSyncMetadataBySportEventId(sportEventId);
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
    await healthPlatformService.installHealthConnect();
  }

  @override
  Future<void> openHealthConnect() async {
    await healthPlatformService.openHealthConnect();
  }

  /// Midnight millis for a date — used as eventDate and eventId (one record per day).
  static int _midnightMillis(DateTime date) =>
      DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;

  /// Resolves the current user ID, or `null` when no usable identity exists
  /// (no stored profile, or a profile whose userId is null/empty). Callers
  /// must treat `null` as "do not upload".
  Future<String?> _getUserIdOrNull() async {
    final profile = await localStorageRepository.getProfile();
    final userId = profile?.userId;
    if (userId == null || userId.isEmpty) return null;
    return userId;
  }

  /// Central identity gate for sleep/step uploads — the ONLY path to the
  /// upload APIs and, transitively, to the sync queue (each `catchError →
  /// syncQueue.enqueue` fallback lives inside its [upload] closure, so a
  /// payload with a missing user ID can never reach the API or the queue).
  ///
  /// When [userId] is null: emits an `identityMissing` diagnostic (severity
  /// warning, no metadata; platform tagging is T15's) and returns without
  /// invoking [upload]. When non-null: runs [upload] unchanged.
  void _uploadIfIdentified({
    required String? userId,
    required HealthSyncDomain domain,
    required void Function(String userId) upload,
  }) {
    if (userId == null) {
      debugPrint(
          '[HealthSync] ${domain.name} upload skipped: missing user ID');
      diagnostics.add(HealthSyncDiagnostics.identityMissing(domain: domain));
      return;
    }
    upload(userId);
  }

  // ── Sleep ──────────────────────────────────────────────────────────────

  @override
  Future<void> saveSleepEvent({
    required DateTime date,
    required double sleepHours,
  }) async {
    final midnight = _midnightMillis(date);
    final userId = await _getUserIdOrNull();
    final sleepMinutes = (sleepHours * 60).round();

    // Always save to Hive, even without an identity: the record is
    // day-bucketed (eventId == midnight), so the periodic cycle re-saves the
    // same record with the repaired identity once the profile is back — the
    // dashboard stays fresh and nothing is orphaned.
    final entity = SleepEventEntity(
      userId: userId ?? '',
      eventDate: midnight,
      eventId: midnight,
      sleepMinutes: sleepMinutes,
    );
    await localStorageRepository.saveSleepEvent(entity);

    _uploadIfIdentified(
      userId: userId,
      domain: HealthSyncDomain.sleep,
      upload: (userId) {
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
      },
    );
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
    final userId = await _getUserIdOrNull();

    // Always save to Hive (reuses existing StepsEntity, which carries no
    // userId — identity only matters for the upload).
    final entity = StepsEntity(
      eventId: midnight,
      initialSteps: 0,
      actualSteps: stepCount,
    );
    await localStorageRepository.saveSteps(entity);

    _uploadIfIdentified(
      userId: userId,
      domain: HealthSyncDomain.steps,
      upload: (userId) {
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
      },
    );
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

      final sleepData = await healthPlatformClient.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_SESSION],
        startTime: startTime,
        endTime: endTime,
      );

      if (sleepData.isEmpty) return 0.0;

      // Multiple connected apps (Samsung Health, Google Fit, smartwatch) can
      // each log the same night, and a source may also leave a stale
      // "scheduled sleep" goal window unclosed. Trust a single
      // highest-priority source rather than summing across sources, and
      // union that source's own sessions rather than naively summing them.
      final sessions = <SleepSession>[
        for (final p in sleepData)
          SleepSession(
            start: p.dateFrom,
            end: p.dateTo,
            sourceCategory: HealthSourceResolver.resolve(
              sourceName: p.sourceName,
              sourceType: _sourceTypeOf(p.sourcePlatform),
            ),
          ),
      ];
      final result = sleepAggregator.aggregate(sessions: sessions);
      // Only emit when a source was actually selected — mirrors
      // fetchTodayStepCount's guard.
      if (result.selectedCategory != null) {
        diagnostics.add(HealthSyncDiagnostics.sourceSelected(
          domain: HealthSyncDomain.sleep,
          sourceCount: result.sourceCount,
          discardedCount: result.discardedCount,
          selectedCategory: coarseSourceCategory(result.selectedCategory!),
        ));
      }

      debugPrint('[HealthSync] fetchTodaySleepHours: ${sleepData.length} sessions');
      return result.hours;
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
      // Half-open day window [midnight, next-midnight): closes the 1-second
      // gap before midnight; calendar-day arithmetic keeps it DST-safe.
      final endTime = DateTime(date.year, date.month, date.day + 1);

      final stepsData = await healthPlatformClient.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startTime,
        endTime: endTime,
      );
      final platformTotal = await healthPlatformClient.getTotalStepsInInterval(
        startTime: startTime,
        endTime: endTime,
      );

      final records = <StepRecord>[
        for (final p in stepsData)
          if (p.value is NumericHealthValue)
            StepRecord(
              steps: (p.value as NumericHealthValue).numericValue.round(),
              start: p.dateFrom,
              end: p.dateTo,
              sourceCategory: HealthSourceResolver.resolve(
                sourceName: p.sourceName,
                sourceType: _sourceTypeOf(p.sourcePlatform),
              ),
            ),
      ];
      final result = stepAggregator.aggregate(
        platformAggregateTotal: platformTotal,
        records: records,
      );
      // Only emit when a source was actually selected — an empty read (no
      // records, no platform aggregate) has nothing to report.
      if (result.selectedCategory != null) {
        diagnostics.add(HealthSyncDiagnostics.sourceSelected(
          domain: HealthSyncDomain.steps,
          sourceCount: result.perSourceTotals.length,
          discardedCount: result.discardedCount,
          selectedCategory: coarseSourceCategory(result.selectedCategory!),
        ));
      }

      debugPrint('[HealthSync] fetchTodayStepCount completed');
      return result.total;
    } catch (e) {
      // Return null on error — same rationale as fetchTodaySleepHours.
      debugPrint('[HealthSync] fetchTodayStepCount ERROR: $e');
      return null;
    }
  }

  /// Maps the `health` package's [HealthPlatformType] to the app-level
  /// source-type tag ([HealthSourceResolver]'s `sourceType`). LOCKED — T11
  /// reuses this helper verbatim. The switch is exhaustive over the two
  /// current enum values with no default, so a future [HealthPlatformType]
  /// addition is a compile error here — deliberate, to force an explicit
  /// mapping decision rather than a silent 'health_connect' default.
  String _sourceTypeOf(HealthPlatformType p) {
    switch (p) {
      case HealthPlatformType.appleHealth:
        return 'apple_health';
      case HealthPlatformType.googleHealthConnect:
        return 'health_connect';
    }
  }
}
