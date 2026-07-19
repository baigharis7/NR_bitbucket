import 'package:flutter/foundation.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/domain/interactor/healthsync/sync_health_activities_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/save_sport_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_fetch_result.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_diagnostic_event.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/sync_health_activities_result.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/repository/healthsync/health_sync_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/domain/repository/preferences/preferences_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/sportevents/sport_events_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/health_activity_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sanitizer.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_sync_diagnostics_sink.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_deduplicator.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_fingerprint.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/imported_workout_event_id_factory.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sport_kcal_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_activity_type_mapping.dart';

class SyncHealthActivitiesInteractorImpl implements SyncHealthActivitiesInteractor {
  final HealthSyncRepository healthSyncRepository;
  final LocalStorageRepository localStorageRepository;
  final PreferencesRepository preferencesRepository;
  final SaveSportEventInteractor saveSportEventInteractor;
  final SportEventsRepository sportEventsRepository;
  final SportKcalCalculationService sportKcalCalculationService;

  /// Destination for privacy-safe sync diagnostics. Defaults to a no-op;
  /// app_bootstrap injects the Crashlytics sink in production.
  final HealthSyncDiagnosticsSink diagnostics;

  /// Pure workout dedupe decision service. Const default is the production
  /// instance; injectable for tests.
  final HealthWorkoutDeduplicator deduplicator;

  /// Deterministic collision-safe event ids for imported workouts (T14).
  /// Pure and const-constructible; injected for symmetry with the
  /// deduplicator, defaulting to the real instance.
  final ImportedWorkoutEventIdFactory eventIdFactory;

  /// Minimum time between automatic syncs (5 minutes)
  static const Duration _minSyncInterval = Duration(minutes: 5);

  /// Default lookback period for first sync (7 days)
  static const Duration _defaultLookback = Duration(days: 7);

  static void _log(String message) {
    debugPrint('[HealthSync] $message');
    CrashlyticsService.instance.log(message);
  }

  SyncHealthActivitiesInteractorImpl({
    required this.healthSyncRepository,
    required this.localStorageRepository,
    required this.preferencesRepository,
    required this.saveSportEventInteractor,
    required this.sportEventsRepository,
    required this.sportKcalCalculationService,
    this.diagnostics = const NoopHealthSyncDiagnosticsSink(),
    this.deduplicator = const HealthWorkoutDeduplicator(),
    this.eventIdFactory = const ImportedWorkoutEventIdFactory(),
  });

  @override
  Future<SyncHealthActivitiesResult> execute({DateTime? since}) async {
    final syncedEvents = <SportEventComplete>[];
    SyncHealthActivitiesResult resultWith(
      SyncHealthOutcome outcome, {
      SyncPermissionResolution permissionResolution =
          SyncPermissionResolution.none,
    }) =>
        SyncHealthActivitiesResult(
          syncedEvents: syncedEvents,
          outcome: outcome,
          permissionResolution: permissionResolution,
        );

    try {
      // Check if sync is enabled
      final isEnabled = await healthSyncRepository.isHealthSyncEnabled();
      if (!isEnabled) {
        _log('Sync aborted: sync not enabled');
        return resultWith(SyncHealthOutcome.skippedDisabled);
      }

      // Permission probes under-report: Health Connect's hasPermissions() is
      // unreliable after app restarts, and HealthKit cannot report read
      // grants at all (the plugin maps null → false). A false probe therefore
      // proceeds to the guarded typed read below — the platform's actual
      // answer (data, or a classified permissionDenied) outranks the probe.
      final hasPermissions = await healthSyncRepository.hasPermissions();
      final probeReportedFalse = !hasPermissions;
      if (probeReportedFalse) {
        _log('Permission probe reported false — proceeding with guarded read');
      }

      // Check throttling - don't sync if we synced recently
      final lastSyncTime = await healthSyncRepository.getLastSyncTime();
      if (since == null && lastSyncTime != null) {
        final timeSinceLastSync = DateTime.now().difference(lastSyncTime);
        if (timeSinceLastSync < _minSyncInterval) {
          _log('Sync throttled: last sync ${timeSinceLastSync.inMinutes}m ago');
          return resultWith(SyncHealthOutcome.skippedThrottled);
        }
      }

      // Determine sync start time
      final DateTime startDate;
      if (since != null) {
        startDate = since;
      } else if (lastSyncTime != null) {
        startDate = lastSyncTime;
      } else {
        // First sync - go back 7 days
        startDate = DateTime.now().subtract(_defaultLookback);
      }
      final endDate = DateTime.now();
      _log('Sync window: $startDate → $endDate');

      // Get user ID
      final userId = preferencesRepository.getSub();
      if (userId.isEmpty) {
        _log('Sync aborted: empty userId');
        return resultWith(SyncHealthOutcome.skippedPreconditions);
      }

      // Get sports master file for mapping
      final sportsInfo = await localStorageRepository.getMasterFile(
        MasterFilesType.sportsInfo,
      ) as SportsInfoEntity?;
      if (sportsInfo == null) {
        _log('Sync aborted: sportsInfo master file not loaded');
        return resultWith(SyncHealthOutcome.skippedPreconditions);
      }

      // Fetch activities from health platform via the typed result path. We
      // deliberately do NOT synthesize an activity from passive STEPS data:
      // that produced a bogus "Walking" entry per day with duration spanning
      // the whole waking period (first step → last step). The step counter
      // widget gets its data from fetchTodayStepCount, and real walking
      // workouts come through HealthDataType.WORKOUT here.
      final fetchResult = await healthSyncRepository.fetchActivitiesResult(
        startDate: startDate,
        endDate: endDate,
      );

      final permissionResolution = _resolvePermission(
        probeReportedFalse: probeReportedFalse,
        fetchStatus: fetchResult.status,
      );
      if (permissionResolution ==
          SyncPermissionResolution.toleratedFalseNegative) {
        diagnostics.add(
          HealthSyncDiagnostics.permissionFalseNegativeTolerated(
            domain: HealthSyncDomain.workout,
          ),
        );
      }

      switch (fetchResult.status) {
        case HealthFetchStatus.failed:
          _log('Sync aborted: fetch failed (${fetchResult.failureReason?.name})');
          diagnostics.add(HealthSyncDiagnostics.fetchFailed(
            domain: HealthSyncDomain.workout,
            category: _categoryFor(fetchResult.failureReason),
          ));
          return resultWith(
            SyncHealthOutcome.fetchFailed,
            permissionResolution: permissionResolution,
          );
        case HealthFetchStatus.permissionDenied:
          _log('Sync aborted: fetch reported permission denied');
          diagnostics.add(HealthSyncDiagnostics.permissionDenied(
            domain: HealthSyncDomain.workout,
          ));
          return resultWith(
            SyncHealthOutcome.permissionDenied,
            permissionResolution: permissionResolution,
          );
        case HealthFetchStatus.platformUnavailable:
          _log('Sync aborted: health platform unavailable');
          diagnostics.add(HealthSyncDiagnostics.platformUnavailable(
            domain: HealthSyncDomain.workout,
          ));
          return resultWith(
            SyncHealthOutcome.platformUnavailable,
            permissionResolution: permissionResolution,
          );
        case HealthFetchStatus.successNoData:
          _log('Fetched 0 activities from health platform');
          diagnostics.add(HealthSyncDiagnostics.fetchNoData(
            domain: HealthSyncDomain.workout,
          ));
          // The platform read genuinely succeeded — the window is clean.
          await healthSyncRepository.setLastSyncTime(DateTime.now());
          _log('Sync complete: no activities in window');
          return resultWith(
            SyncHealthOutcome.syncedNoData,
            permissionResolution: permissionResolution,
          );
        case HealthFetchStatus.success:
        case HealthFetchStatus.partialSuccess:
          break; // Import below.
      }

      final activities = fetchResult.data ?? const <HealthActivity>[];
      _log('Fetched ${activities.length} activities from health platform');
      diagnostics.add(HealthSyncDiagnostics.fetchSucceeded(
        domain: HealthSyncDomain.workout,
        count: activities.length,
      ));
      final isPartial = fetchResult.status == HealthFetchStatus.partialSuccess;
      if (isPartial) {
        // Enrichment degraded but the workouts are real (locked decision:
        // import + advance — dedupe keys on healthPlatformId, so re-scanning
        // the window could never repair enrichment anyway). Emit an honest
        // failure event alongside the success, tagged with the phase.
        diagnostics.add(HealthSyncDiagnostics.fetchFailed(
          domain: HealthSyncDomain.workout,
          category: _categoryFor(fetchResult.failureReason),
          phase: 'enrichment',
        ));
      }

      // Load the sync metadata ONCE and let the pure deduplicator decide per
      // activity: import, import-but-suspected, or skip (exact/strong tier).
      final existingMetadata = await healthSyncRepository.getSyncedMetadata();
      final dedupeEntries = deduplicator.deduplicate(
        incoming: activities,
        existing: existingMetadata,
      );
      final toImport = dedupeEntries
          .where((e) =>
              e.decision == DedupeDecision.import ||
              e.decision == DedupeDecision.importSuspected)
          .toList();
      final exactCount = dedupeEntries
          .where((e) => e.decision == DedupeDecision.skipExactIdentity)
          .length;
      final strongCount = dedupeEntries
          .where((e) => e.decision == DedupeDecision.skipStrongDuplicate)
          .length;
      final suspectedImportedCount = dedupeEntries
          .where((e) => e.decision == DedupeDecision.importSuspected)
          .length;
      if (exactCount + strongCount + suspectedImportedCount > 0) {
        // ONE aggregated event per run — counts only, never IDs or names.
        diagnostics.add(HealthSyncDiagnostics.duplicateDiscarded(
          domain: HealthSyncDomain.workout,
          exactCount: exactCount,
          strongCount: strongCount,
          suspectedImportedCount: suspectedImportedCount,
        ));
      }
      _log('After dedup: ${toImport.length} new activities (${activities.length - toImport.length} already synced)');

      // Process each new activity (per-activity isolation unchanged)
      for (final entry in toImport) {
        final activity = entry.activity;
        try {
          final sportEvent = await _processActivity(
            activity,
            userId,
            sportsInfo,
            fingerprint: entry.fingerprint,
          );
          if (sportEvent != null) {
            _log('Synced: ${activity.activityType} (${activity.healthPlatformId}) → ${sportEvent.sportName}');
            syncedEvents.add(sportEvent);
          } else {
            _log('Skipped: ${activity.activityType} — not imported');
          }
        } catch (e) {
          _log('Error processing ${activity.activityType}: $e');
          continue;
        }
      }

      // Update last sync time
      await healthSyncRepository.setLastSyncTime(DateTime.now());
      _log('Sync complete: ${syncedEvents.length} activities saved');

      return resultWith(
        isPartial ? SyncHealthOutcome.syncedPartial : SyncHealthOutcome.synced,
        permissionResolution: permissionResolution,
      );
    } catch (e, stack) {
      _log('Sync failed with error: $e');
      CrashlyticsService.record(e, stack, context: {'event': 'SyncHealthActivities'});
      return resultWith(SyncHealthOutcome.error);
    }
  }

  /// Maps a typed fetch failure reason to the sanitized diagnostics category.
  /// The interactor holds only the [HealthFetchResult] (never the exception
  /// object), so it hands the already-classified category to the fetchFailed
  /// builder instead of re-classifying.
  static HealthSyncErrorCategory _categoryFor(HealthFetchFailureReason? reason) {
    switch (reason) {
      case HealthFetchFailureReason.permission:
        return HealthSyncErrorCategory.permission;
      case HealthFetchFailureReason.platformUnavailable:
        return HealthSyncErrorCategory.platformUnavailable;
      case HealthFetchFailureReason.timeout:
        return HealthSyncErrorCategory.timeout;
      case HealthFetchFailureReason.pluginError:
        return HealthSyncErrorCategory.plugin;
      case HealthFetchFailureReason.malformedData:
      case HealthFetchFailureReason.unknown:
      case null:
        return HealthSyncErrorCategory.unknown;
    }
  }

  /// Process a single health activity: build sport event with health platform
  /// calories when available, otherwise compute via METs locally; save
  /// locally, sync to backend.
  Future<SportEventComplete?> _processActivity(
    HealthActivity activity,
    String userId,
    SportsInfoEntity sportsInfo, {
    required HealthWorkoutFingerprint fingerprint,
  }) async {
    // Find matching sport ID
    int? sportId = HealthActivityTypeMapping.mapToSportId(
      activity.activityType,
      sportsInfo,
    );
    sportId ??= HealthActivityTypeMapping.findFallbackSportId(sportsInfo);
    if (sportId == null) return null;

    // Local collision guard (T14): saveSportEvent silently overwrites by
    // eventId, so an occupied id must SKIP — never replace an existing local
    // event. Post-dedupe, a hit is either the residual same-second
    // hash-suffix collision between two genuinely different workouts
    // (~1/1000) or a stale local event whose metadata was lost; skipping is
    // the non-destructive choice in both cases. No local save, no backend
    // sync, no metadata write. The generated id depends only on the
    // fingerprint, so this guard runs before the kcal-resolution block below
    // — a colliding activity is skipped without paying for a profile lookup
    // or METs enrichment.
    final eventId = eventIdFactory.eventIdFor(fingerprint);
    final existingEvent = await localStorageRepository.findSportEventByEventId(
      eventId,
    );
    if (existingEvent != null) {
      _log('Skipped: eventId $eventId already occupied locally '
          'for ${activity.activityType} — collision guard');
      diagnostics.add(HealthSyncDiagnostics.eventIdCollision(
        domain: HealthSyncDomain.workout,
        sourceCategory: fingerprint.sourceCategory.name,
      ));
      return null;
    }

    // Resolve effective kcal: prefer health-platform value, otherwise compute
    // locally via the same MET formula used by the manual entry path
    // (sport-event-amplify Lambda port).
    int effectiveKcal;
    if (activity.caloriesBurned != null) {
      effectiveKcal = activity.caloriesBurned!.round();
      _log('kcal source: platform ($effectiveKcal kcal) for ${activity.activityType}');
    } else if (activity.durationMinutes > 0) {
      final simple = mapHealthActivityToSportEventSimple(
        activity: activity,
        userId: userId,
        sportId: sportId,
        sportsInfo: sportsInfo,
      );
      final profile = await localStorageRepository.getProfile();
      final userWeight = profile?.physicalCharacteristics?.weight ?? 70.0;
      final enriched = await sportKcalCalculationService.enrichSportEvent(
        simple,
        userWeight: userWeight,
      );
      effectiveKcal = enriched.eventKcals ?? 0;
      _log('kcal source: METs-computed ($effectiveKcal kcal, weight=${userWeight}kg, '
          'duration=${activity.durationMinutes}m) for ${activity.activityType}');
    } else {
      effectiveKcal = 0;
      _log('kcal source: zero (no platform value, no duration) for ${activity.activityType}');
    }

    // Build SportEventComplete with the resolved kcal
    final sportEvent = mapHealthActivityToSportEventComplete(
      activity: activity,
      userId: userId,
      eventId: eventId,
      sportId: sportId,
      sportsInfo: sportsInfo,
      eventKcals: effectiveKcal,
    );

    // Save locally
    await saveSportEventInteractor.execute(sportEvent, false);

    // Sync to DynamoDB (fire-and-forget, same as manual entry)
    sportEventsRepository.syncToBackend(sportEvent);

    // Save sync metadata for deduplication — keyed by the canonical platform
    // id, now also carrying the fingerprint fields for the strong tier.
    final metadata = HealthSyncMetadata(
      healthPlatformId: activity.healthPlatformId,
      sportEventId: sportEvent.eventId,
      syncedAt: DateTime.now(),
      sourceType: activity.sourceType,
      normalizedType: fingerprint.normalizedType,
      startTimeMs: fingerprint.startTime.millisecondsSinceEpoch,
      endTimeMs: fingerprint.endTime.millisecondsSinceEpoch,
      sourceCategory: fingerprint.sourceCategory.name,
    );
    await healthSyncRepository.saveHealthSyncMetadata(metadata);

    return sportEvent;
  }
}

/// Pure permission-resolution policy: reconciles the hasPermissions() probe
/// against the guarded read's actual [HealthFetchStatus].
///
/// - The platform refusing the read ([HealthFetchStatus.permissionDenied]) is
///   a verified denial regardless of the probe — the platform's own answer
///   outranks the probe in both directions.
/// - A false probe followed by a successful read (success / successNoData /
///   partialSuccess) is a tolerated false negative.
/// - Everything else (real failures, platform unavailable, probe true +
///   successful read) carries no permission signal.
SyncPermissionResolution _resolvePermission({
  required bool probeReportedFalse,
  required HealthFetchStatus fetchStatus,
}) {
  if (fetchStatus == HealthFetchStatus.permissionDenied) {
    return SyncPermissionResolution.verifiedDenial;
  }
  const successStatuses = {
    HealthFetchStatus.success,
    HealthFetchStatus.successNoData,
    HealthFetchStatus.partialSuccess,
  };
  if (probeReportedFalse && successStatuses.contains(fetchStatus)) {
    return SyncPermissionResolution.toleratedFalseNegative;
  }
  return SyncPermissionResolution.none;
}
