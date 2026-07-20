import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_fingerprint.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_type_normalizer.dart';

/// Decision for one incoming activity (locked contract, Wave 3 design
/// 2026-07-18 — T14 consumes the import/importSuspected entries):
enum DedupeDecision {
  /// No identity or fingerprint conflict — import normally.
  import,

  /// Same type with >= 80% time-overlap of the shorter workout, outside the
  /// strong tolerance: PROBABLY distinct, so it imports — the caller emits a
  /// suspected-duplicate diagnostic (never collapse two plausibly-real
  /// workouts; locked decision).
  importSuspected,

  /// The canonical id or the legacy synthesized id is already in the sync
  /// metadata — this exact record (or its pre-upgrade self) was imported.
  skipExactIdentity,

  /// Strong fingerprint match (same normalized type, |Δstart| <= 2 min,
  /// |Δduration| <= max(2 min, 10% of the longer)) against new-style
  /// metadata or an already-accepted batch entry — cross-source/same-source
  /// duplicate of an imported workout. Source equality is irrelevant.
  skipStrongDuplicate,

  /// Contract extended additively 2026-07-20 (cleanup follow-up design): an
  /// exact-identity or strong-fingerprint block that is attributable ONLY to
  /// a tombstoned metadata row ([HealthSyncMetadata.isDeleted]) — the user
  /// deleted this imported workout, so re-import is blocked but labeled
  /// distinctly from a live duplicate. Never widens the suspected tier: a
  /// tombstoned window that only overlaps at the suspected level still
  /// imports as [importSuspected].
  skipDeletedTombstone,
}

/// One incoming activity paired with its fingerprint and dedupe decision.
/// The fingerprint travels with import entries so the caller can persist it
/// (and T14 can derive the event id from it).
class DedupeEntry {
  final HealthActivity activity;
  final HealthWorkoutFingerprint fingerprint;
  final DedupeDecision decision;

  const DedupeEntry({
    required this.activity,
    required this.fingerprint,
    required this.decision,
  });
}

/// Pure workout dedupe decision service — no I/O, const-constructible,
/// injected into the sync interactor with a default const instance.
///
/// Tiers (locked policy, 2026-07-18): exact identity -> strong fingerprint
/// -> suspected overlap -> import. Strong/suspected matching compares only
/// existing metadata records that CARRY fingerprint fields (legacy records
/// have no type; collapsing on times alone could merge two different-type
/// workouts) plus already-accepted entries within the batch (metadata is
/// only written after processing, so two same-workout records arriving in
/// one fetch must be deduped here).
class HealthWorkoutDeduplicator {
  const HealthWorkoutDeduplicator();

  /// Strong tier: max |Δstart| between two records of the same workout.
  static const Duration startTolerance = Duration(minutes: 2);

  /// Strong tier: |Δduration| allowance as a fraction of the LONGER duration.
  static const double durationToleranceFraction = 0.10;

  /// Strong tier: |Δduration| floor so short workouts get a sane allowance.
  static const Duration durationToleranceFloor = Duration(minutes: 2);

  /// Suspected tier: minimum time-overlap fraction of the SHORTER duration.
  static const double suspectedOverlapFraction = 0.8;

  /// Decides every activity in [incoming] against [existing] metadata and
  /// pairwise within the batch. Returns one [DedupeEntry] per activity, in
  /// deterministic (startTime, endTime, normalizedType, healthPlatformId)
  /// order — the first occurrence wins within the batch.
  List<DedupeEntry> deduplicate({
    required List<HealthActivity> incoming,
    required List<HealthSyncMetadata> existing,
  }) {
    // Exact tier: every stored key blocks re-import — canonical uuids AND
    // pre-upgrade legacy synthesized keys live in the same key space.
    // Partitioned by tombstone state (D10/T18) so the caller can label a
    // deleted-workout block distinctly from a live duplicate, without
    // changing which activities get blocked.
    final liveKeys = <String>{
      for (final m in existing)
        if (!m.isDeleted) m.healthPlatformId,
    };
    final tombstonedKeys = <String>{
      for (final m in existing)
        if (m.isDeleted) m.healthPlatformId,
    };

    final liveWindows = <_Window>[
      for (final m in existing)
        if (!m.isDeleted &&
            m.normalizedType != null &&
            m.startTimeMs != null &&
            m.endTimeMs != null)
          _Window(
            normalizedType: m.normalizedType!,
            startMs: m.startTimeMs!,
            endMs: m.endTimeMs!,
          ),
    ];
    final tombstonedWindows = <_Window>[
      for (final m in existing)
        if (m.isDeleted &&
            m.normalizedType != null &&
            m.startTimeMs != null &&
            m.endTimeMs != null)
          _Window(
            normalizedType: m.normalizedType!,
            startMs: m.startTimeMs!,
            endMs: m.endTimeMs!,
          ),
    ];

    final sorted = [...incoming]..sort(_compare);

    final acceptedWindows = <_Window>[];
    final entries = <DedupeEntry>[];
    for (final activity in sorted) {
      final fingerprint = HealthWorkoutFingerprint.fromActivity(activity);
      final window = _Window(
        normalizedType: fingerprint.normalizedType,
        startMs: fingerprint.startTime.millisecondsSinceEpoch,
        endMs: fingerprint.endTime.millisecondsSinceEpoch,
      );

      // Decision precedence (locked, D10/T18): exact(live) -> strong(live or
      // accepted) -> exact(tombstoned) collapses into the same label as
      // strong(tombstoned) below — both are skipDeletedTombstone — but exact
      // identity is still decided before strong, matching the pre-tombstone
      // ordering byte-for-byte when nothing is tombstoned.
      final DedupeDecision decision;
      if (liveKeys.contains(activity.healthPlatformId) ||
          liveKeys.contains(activity.legacyPlatformId)) {
        decision = DedupeDecision.skipExactIdentity;
      } else if (tombstonedKeys.contains(activity.healthPlatformId) ||
          tombstonedKeys.contains(activity.legacyPlatformId)) {
        decision = DedupeDecision.skipDeletedTombstone;
      } else if (liveWindows.any((c) => _isStrongMatch(window, c)) ||
          acceptedWindows.any((c) => _isStrongMatch(window, c))) {
        decision = DedupeDecision.skipStrongDuplicate;
      } else if (tombstonedWindows.any((c) => _isStrongMatch(window, c))) {
        decision = DedupeDecision.skipDeletedTombstone;
      } else if (liveWindows.any((c) => _isSuspectedOverlap(window, c)) ||
          tombstonedWindows.any((c) => _isSuspectedOverlap(window, c)) ||
          acceptedWindows.any((c) => _isSuspectedOverlap(window, c))) {
        decision = DedupeDecision.importSuspected;
      } else {
        decision = DedupeDecision.import;
      }

      if (decision == DedupeDecision.import ||
          decision == DedupeDecision.importSuspected) {
        acceptedWindows.add(window);
      }
      entries.add(
        DedupeEntry(
          activity: activity,
          fingerprint: fingerprint,
          decision: decision,
        ),
      );
    }
    return entries;
  }

  static int _compare(HealthActivity a, HealthActivity b) {
    final byStart = a.startTime.compareTo(b.startTime);
    if (byStart != 0) return byStart;
    final byEnd = a.endTime.compareTo(b.endTime);
    if (byEnd != 0) return byEnd;
    final byType = HealthWorkoutTypeNormalizer.normalize(
      a.activityType,
    ).compareTo(HealthWorkoutTypeNormalizer.normalize(b.activityType));
    if (byType != 0) return byType;
    return a.healthPlatformId.compareTo(b.healthPlatformId);
  }

  static bool _isStrongMatch(_Window a, _Window b) {
    if (a.normalizedType != b.normalizedType) return false;
    if ((a.startMs - b.startMs).abs() > startTolerance.inMilliseconds) {
      return false;
    }
    final longerMs = a.durationMs > b.durationMs ? a.durationMs : b.durationMs;
    final fractionalMs = (longerMs * durationToleranceFraction).round();
    final toleranceMs = fractionalMs > durationToleranceFloor.inMilliseconds
        ? fractionalMs
        : durationToleranceFloor.inMilliseconds;
    return (a.durationMs - b.durationMs).abs() <= toleranceMs;
  }

  static bool _isSuspectedOverlap(_Window a, _Window b) {
    if (a.normalizedType != b.normalizedType) return false;
    final overlapMs =
        (a.endMs < b.endMs ? a.endMs : b.endMs) -
        (a.startMs > b.startMs ? a.startMs : b.startMs);
    if (overlapMs <= 0) return false;
    final shorterMs = a.durationMs < b.durationMs ? a.durationMs : b.durationMs;
    if (shorterMs <= 0) return false;
    return overlapMs >= shorterMs * suspectedOverlapFraction;
  }
}

/// Internal comparable time/type window. Durations come from the window
/// bounds (ms), not the stored minutes int — no rounding artifacts in the
/// tolerance math.
class _Window {
  final String normalizedType;
  final int startMs;
  final int endMs;

  const _Window({
    required this.normalizedType,
    required this.startMs,
    required this.endMs,
  });

  int get durationMs => endMs - startMs;
}
