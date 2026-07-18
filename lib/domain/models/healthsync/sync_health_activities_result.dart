import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';

/// Typed outcome of one workout-sync run
/// ([SyncHealthActivitiesInteractor.execute]).
///
/// Lets callers distinguish "the platform read succeeded" (safe to treat the
/// window as synced) from skips and failures, instead of inferring intent
/// from an empty event list. Introduced by T8; T7 extends the result with a
/// `permissionResolution` field and removes [skippedNoPermissions].
enum SyncHealthOutcome {
  /// Sync toggle is off.
  skippedDisabled,

  /// Less than the minimum interval since the last sync (`since == null`).
  skippedThrottled,

  /// The hasPermissions probe reported false. T8 keeps this abort;
  /// T7 replaces the branch with a guarded read and removes this value.
  skippedNoPermissions,

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

/// Immutable result of a workout-sync run.
///
/// Plain immutable class — no `==`/`hashCode` override (the codebase uses
/// neither `equatable` nor `freezed`). Tests assert on individual fields.
class SyncHealthActivitiesResult {
  /// Sport events actually saved during this run (empty on skip/failure).
  final List<SportEventComplete> syncedEvents;

  final SyncHealthOutcome outcome;

  const SyncHealthActivitiesResult({
    required this.syncedEvents,
    required this.outcome,
  });

  /// True when the platform read succeeded and the sync window advanced.
  bool get isSuccess =>
      outcome == SyncHealthOutcome.synced ||
      outcome == SyncHealthOutcome.syncedNoData ||
      outcome == SyncHealthOutcome.syncedPartial;
}
