import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_fingerprint.dart';

/// Deterministic, collision-resistant event ids for imported workouts.
///
/// Second-precision hybrid scheme (Wave 3 locked decision, 2026-07-18):
/// `startEpochSeconds * 1000 + stableHash % 1000`. Each property is
/// load-bearing:
///
/// - **Deterministic** — the same workout re-imported (reinstall, metadata
///   wipe) reproduces the same id, preserving the backend upsert-by-
///   `{userId, eventId}` idempotency the client already relies on.
/// - **Time-ordered at 13-digit scale** — the seconds bucket keeps
///   `getTodaySportEvents`' eventId sort and interleaving with manual
///   `DateTime.now().millisecondsSinceEpoch` ids working to the second.
/// - **53-bit/JS-safe** — same magnitude as today's epoch-millis ids.
/// - **Collision-resistant** — two distinct same-second workouts differ via
///   the fingerprint-hash suffix; the residual same-second same-suffix case
///   is handled by the interactor's local collision guard (skip + diagnostic,
///   never overwrite).
///
/// Applies to NEW imports only: previously synced workouts are exact-tier
/// deduped by metadata before id generation, so existing data sees no
/// eventId churn.
class ImportedWorkoutEventIdFactory {
  const ImportedWorkoutEventIdFactory();

  /// Derives the deterministic imported-workout event id from [fingerprint].
  /// `stableHash` is non-negative (FNV-1a 32-bit), so the suffix is in
  /// `[0, 999]` and the result is always >= the start-second bucket.
  int eventIdFor(HealthWorkoutFingerprint fingerprint) =>
      (fingerprint.startTime.millisecondsSinceEpoch ~/ 1000) * 1000 +
      fingerprint.stableHash % 1000;
}
