import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

/// Typed outcome of one workout-sync run
/// ([SyncHealthActivitiesInteractor.execute]).
///
/// Lets callers distinguish "the platform read succeeded" (safe to treat the
/// window as synced) from skips and failures, instead of inferring intent
/// from an empty event list. Introduced by T8; T7 added [permissionResolution]
/// and replaced the probe-false abort with a guarded read.
enum SyncHealthOutcome {
  /// Sync toggle is off.
  skippedDisabled,

  /// Less than the minimum interval since the last sync (`since == null`).
  skippedThrottled,

  /// Missing prerequisites: empty userId or sportsInfo master file not loaded.
  skippedPreconditions,

  /// Fetch succeeded with >= 1 activity; window processed and
  /// lastSyncTime advanced.
  synced,

  /// Fetch succeeded with zero activities; lastSyncTime advanced.
  syncedNoData,

  /// Fetch partially succeeded (workouts real, enrichment degraded);
  /// workouts imported and lastSyncTime advanced.
  syncedPartial,

  /// Platform fetch failed; nothing imported, lastSyncTime NOT advanced.
  fetchFailed,

  /// Platform fetch classified as a permission denial; not advanced.
  permissionDenied,

  /// HealthKit / Health Connect unavailable; not advanced.
  platformUnavailable,

  /// Unexpected exception inside execute().
  error,
}

/// How the permission probe's answer was reconciled against the guarded typed
/// read during this sync attempt.
///
/// Health Connect's `hasPermissions()` under-reports after app restarts, and
/// HealthKit cannot report read grants at all (the plugin maps null → false),
/// so a false probe is a hint, never a verdict. The platform's actual answer
/// to the read outranks the probe in both directions.
enum SyncPermissionResolution {
  /// No permission signal: probe and read agreed, or the fetch failed for
  /// non-permission reasons (real failures stay distinct from attention).
  none,

  /// Probe reported false but the guarded read succeeded — a tolerated false
  /// negative. Workouts imported and lastSyncTime advanced normally.
  toleratedFalseNegative,

  /// The platform itself refused the read (classified permissionDenied) —
  /// a real, actionable denial regardless of what the probe said.
  verifiedDenial,
}

/// Immutable result of a workout-sync run.
///
/// Plain immutable class — no `==`/`hashCode` override (the codebase uses
/// neither `equatable` nor `freezed`). Tests assert on individual fields.
class SyncHealthActivitiesResult {
  /// Sport events actually saved during this run (empty on skip/failure).
  final List<SportEventComplete> syncedEvents;

  final SyncHealthOutcome outcome;

  final SyncPermissionResolution permissionResolution;

  const SyncHealthActivitiesResult({
    required this.syncedEvents,
    required this.outcome,
    this.permissionResolution = SyncPermissionResolution.none,
  });

  /// True when the platform read succeeded and the sync window advanced.
  bool get isSuccess =>
      outcome == SyncHealthOutcome.synced ||
      outcome == SyncHealthOutcome.syncedNoData ||
      outcome == SyncHealthOutcome.syncedPartial;
}
