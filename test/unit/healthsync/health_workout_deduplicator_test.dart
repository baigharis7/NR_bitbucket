import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_deduplicator.dart';

import '../../support/healthsync/health_activity_builder.dart';

void main() {
  const deduplicator = HealthWorkoutDeduplicator();
  final start = DateTime(2026, 7, 10, 8, 0);
  final end = DateTime(2026, 7, 10, 9, 0);

  HealthSyncMetadata legacyMetadata({
    required String healthPlatformId,
    DateTime? deletedAt,
  }) => HealthSyncMetadata(
    healthPlatformId: healthPlatformId,
    sportEventId: 1,
    syncedAt: DateTime(2026, 7, 9),
    sourceType: 'health_connect',
    deletedAt: deletedAt,
  );

  HealthSyncMetadata fingerprintMetadata({
    required String healthPlatformId,
    String normalizedType = 'RUNNING',
    required DateTime startTime,
    required DateTime endTime,
    DateTime? deletedAt,
  }) => HealthSyncMetadata(
    healthPlatformId: healthPlatformId,
    sportEventId: 1,
    syncedAt: DateTime(2026, 7, 9),
    sourceType: 'health_connect',
    normalizedType: normalizedType,
    startTimeMs: startTime.millisecondsSinceEpoch,
    endTimeMs: endTime.millisecondsSinceEpoch,
    sourceCategory: 'unknown',
    deletedAt: deletedAt,
  );

  List<DedupeEntry> run(
    List<HealthActivity> incoming, {
    List<HealthSyncMetadata> existing = const [],
  }) => deduplicator.deduplicate(incoming: incoming, existing: existing);

  group('exact tier', () {
    test('canonical uuid already in metadata skips', () {
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-1',
            startTime: start,
            endTime: end,
          ),
        ],
        existing: [legacyMetadata(healthPlatformId: 'uuid-1')],
      );
      expect(entries.single.decision, DedupeDecision.skipExactIdentity);
    });

    test('legacy synthesized key still blocks a uuid-identified record '
        '(upgrade compatibility)', () {
      final legacyKey =
          'Apple Health_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'new-uuid',
            startTime: start,
            endTime: end,
          ),
        ],
        existing: [legacyMetadata(healthPlatformId: legacyKey)],
      );
      expect(entries.single.decision, DedupeDecision.skipExactIdentity);
    });
  });

  group('strong tier', () {
    test('small drift against new-style metadata skips, source-agnostic', () {
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-2',
            startTime: start.add(const Duration(minutes: 1)),
            endTime: end.add(const Duration(seconds: 90)),
            sourceName: 'com.sec.android.app.shealth',
            sourceType: 'health_connect',
          ),
        ],
        existing: [
          fingerprintMetadata(
            healthPlatformId: 'uuid-1',
            startTime: start,
            endTime: end,
          ),
        ],
      );
      expect(entries.single.decision, DedupeDecision.skipStrongDuplicate);
    });

    test('legacy metadata without fingerprint fields never strong-matches', () {
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-3',
            legacyPlatformId: 'other-key',
            startTime: start,
            endTime: end,
          ),
        ],
        existing: [legacyMetadata(healthPlatformId: 'unrelated-key')],
      );
      expect(entries.single.decision, DedupeDecision.import);
    });

    test('within one batch the first (sorted) record wins', () {
      final second = aHealthActivity(
        healthPlatformId: 'uuid-late',
        startTime: start.add(const Duration(minutes: 1)),
        endTime: end.add(const Duration(minutes: 1)),
        sourceName: 'com.garmin.android.apps.connectmobile',
        sourceType: 'health_connect',
      );
      final first = aHealthActivity(
        healthPlatformId: 'uuid-early',
        startTime: start,
        endTime: end,
      );

      // Input order deliberately reversed: the sort must decide, not arrival.
      final entries = run([second, first]);

      expect(entries, hasLength(2));
      expect(entries[0].activity.healthPlatformId, 'uuid-early');
      expect(entries[0].decision, DedupeDecision.import);
      expect(entries[1].activity.healthPlatformId, 'uuid-late');
      expect(entries[1].decision, DedupeDecision.skipStrongDuplicate);
    });

    test('duration tolerance scales with the longer workout', () {
      // 100 min vs 109 min, aligned starts: Δ9 min ≤ 10% of 109 → strong.
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-b',
            startTime: start,
            endTime: start.add(const Duration(minutes: 109)),
          ),
        ],
        existing: [
          fingerprintMetadata(
            healthPlatformId: 'uuid-a',
            startTime: start,
            endTime: start.add(const Duration(minutes: 100)),
          ),
        ],
      );
      expect(entries.single.decision, DedupeDecision.skipStrongDuplicate);
    });

    test('duration outside tolerance is not strong (falls to suspected)', () {
      // 100 min vs 115 min aligned: Δ15 min > max(2, 11.5) — but the overlap
      // is 100% of the shorter → importSuspected, not a skip.
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-b',
            startTime: start,
            endTime: start.add(const Duration(minutes: 115)),
          ),
        ],
        existing: [
          fingerprintMetadata(
            healthPlatformId: 'uuid-a',
            startTime: start,
            endTime: start.add(const Duration(minutes: 100)),
          ),
        ],
      );
      expect(entries.single.decision, DedupeDecision.importSuspected);
    });
  });

  group('suspected tier', () {
    test('same type, >=80% overlap, outside start tolerance imports as '
        'suspected', () {
      // 08:05–09:03 vs 08:00–09:00: Δstart 5 min > 2 min, overlap 55 min ≥
      // 80% of the 58-min shorter workout.
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-b',
            startTime: start.add(const Duration(minutes: 5)),
            endTime: end.add(const Duration(minutes: 3)),
          ),
        ],
        existing: [
          fingerprintMetadata(
            healthPlatformId: 'uuid-a',
            startTime: start,
            endTime: end,
          ),
        ],
      );
      expect(entries.single.decision, DedupeDecision.importSuspected);
    });

    test('same type with low overlap imports cleanly', () {
      // 08:45–09:45 vs 08:00–09:00: overlap 15 min < 80% of 60 min.
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-b',
            startTime: start.add(const Duration(minutes: 45)),
            endTime: end.add(const Duration(minutes: 45)),
          ),
        ],
        existing: [
          fingerprintMetadata(
            healthPlatformId: 'uuid-a',
            startTime: start,
            endTime: end,
          ),
        ],
      );
      expect(entries.single.decision, DedupeDecision.import);
    });
  });

  group('separate real workouts', () {
    test('two distinct workouts both import', () {
      final entries = run([
        aHealthActivity(
          healthPlatformId: 'uuid-1',
          startTime: start,
          endTime: end,
        ),
        aHealthActivity(
          healthPlatformId: 'uuid-2',
          startTime: start.add(const Duration(hours: 3)),
          endTime: end.add(const Duration(hours: 3)),
        ),
      ]);
      expect(
        entries.map((e) => e.decision),
        everyElement(DedupeDecision.import),
      );
    });

    test('same window, different type imports both (conservative)', () {
      final entries = run([
        aHealthActivity(
          healthPlatformId: 'uuid-run',
          activityType: 'RUNNING',
          startTime: start,
          endTime: end,
        ),
        aHealthActivity(
          healthPlatformId: 'uuid-cycle',
          activityType: 'CYCLING',
          startTime: start,
          endTime: end,
        ),
      ]);
      expect(
        entries.map((e) => e.decision),
        everyElement(DedupeDecision.import),
      );
    });

    test('near-synonym types stay distinct: both import', () {
      final entries = run([
        aHealthActivity(
          healthPlatformId: 'uuid-run',
          activityType: 'RUNNING',
          startTime: start,
          endTime: end,
        ),
        aHealthActivity(
          healthPlatformId: 'uuid-tread',
          activityType: 'RUNNING_TREADMILL',
          startTime: start,
          endTime: end,
        ),
      ]);
      expect(
        entries.map((e) => e.decision),
        everyElement(DedupeDecision.import),
      );
    });
  });

  group('tombstone tier (D10/T18 — tombstoned metadata blocks re-import '
      'distinctly)', () {
    final tombstonedAt = DateTime(2026, 7, 15);

    test('exact match against a tombstoned canonical id blocks as '
        'skipDeletedTombstone, not skipExactIdentity', () {
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-1',
            startTime: start,
            endTime: end,
          ),
        ],
        existing: [
          legacyMetadata(healthPlatformId: 'uuid-1', deletedAt: tombstonedAt),
        ],
      );
      expect(entries.single.decision, DedupeDecision.skipDeletedTombstone);
    });

    test('tombstoned legacy row blocks by legacyPlatformId exact key, but a '
        'same-window record with a different id/source is NOT blocked by it '
        '(legacy rows can\'t strong-match — unchanged limitation)', () {
      final legacyKey =
          'Apple Health_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'new-uuid',
            startTime: start,
            endTime: end,
          ),
          aHealthActivity(
            healthPlatformId: 'other-uuid',
            legacyPlatformId: 'unrelated-legacy-key',
            startTime: start,
            endTime: end,
            sourceName: 'com.garmin.android.apps.connectmobile',
            sourceType: 'health_connect',
          ),
        ],
        existing: [
          legacyMetadata(healthPlatformId: legacyKey, deletedAt: tombstonedAt),
        ],
      );
      expect(entries[0].activity.healthPlatformId, 'new-uuid');
      expect(entries[0].decision, DedupeDecision.skipDeletedTombstone);
      expect(entries[1].activity.healthPlatformId, 'other-uuid');
      expect(entries[1].decision, DedupeDecision.import);
    });

    test('strong match against a tombstoned fingerprint window blocks as '
        'skipDeletedTombstone (strategy example 7)', () {
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-2',
            startTime: start.add(const Duration(minutes: 1)),
            endTime: end.add(const Duration(seconds: 90)),
            sourceName: 'com.sec.android.app.shealth',
            sourceType: 'health_connect',
          ),
        ],
        existing: [
          fingerprintMetadata(
            healthPlatformId: 'uuid-1',
            startTime: start,
            endTime: end,
            deletedAt: tombstonedAt,
          ),
        ],
      );
      expect(entries.single.decision, DedupeDecision.skipDeletedTombstone);
    });

    test('suspected overlap against a tombstoned window still imports as '
        'suspected — tombstone must not widen blocking', () {
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-b',
            startTime: start.add(const Duration(minutes: 5)),
            endTime: end.add(const Duration(minutes: 3)),
          ),
        ],
        existing: [
          fingerprintMetadata(
            healthPlatformId: 'uuid-a',
            startTime: start,
            endTime: end,
            deletedAt: tombstonedAt,
          ),
        ],
      );
      expect(entries.single.decision, DedupeDecision.importSuspected);
    });

    test('live (non-tombstoned) exact and strong matches behave exactly as '
        'before', () {
      final exactEntries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-1',
            startTime: start,
            endTime: end,
          ),
        ],
        existing: [legacyMetadata(healthPlatformId: 'uuid-1', deletedAt: null)],
      );
      expect(exactEntries.single.decision, DedupeDecision.skipExactIdentity);

      final strongEntries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-2',
            startTime: start.add(const Duration(minutes: 1)),
            endTime: end.add(const Duration(seconds: 90)),
            sourceName: 'com.sec.android.app.shealth',
            sourceType: 'health_connect',
          ),
        ],
        existing: [
          fingerprintMetadata(
            healthPlatformId: 'uuid-1',
            startTime: start,
            endTime: end,
            deletedAt: null,
          ),
        ],
      );
      expect(strongEntries.single.decision, DedupeDecision.skipStrongDuplicate);
    });

    test('precedence: exact match on a tombstoned key wins over a strong '
        'match on a live window (exact tier decided first; blocked either '
        'way)', () {
      final entries = run(
        [
          aHealthActivity(
            healthPlatformId: 'uuid-tomb',
            startTime: start,
            endTime: end,
          ),
        ],
        existing: [
          legacyMetadata(healthPlatformId: 'uuid-tomb', deletedAt: tombstonedAt),
          fingerprintMetadata(
            healthPlatformId: 'uuid-live',
            startTime: start,
            endTime: end,
          ),
        ],
      );
      expect(entries.single.decision, DedupeDecision.skipDeletedTombstone);
    });

    test('zero-tombstone regression: a representative mixed batch produces '
        'bit-identical decisions to the pre-tombstone behavior', () {
      // W1: exact dup via legacy key.
      final w1Start = DateTime(2026, 7, 10, 8, 0);
      final w1End = DateTime(2026, 7, 10, 9, 0);
      // W2: strong dup (cross-source drift within tolerance) vs live metadata.
      final w2ExistingStart = DateTime(2026, 7, 10, 10, 0);
      final w2ExistingEnd = DateTime(2026, 7, 10, 11, 0);
      final w2IncomingStart = w2ExistingStart.add(const Duration(minutes: 1));
      final w2IncomingEnd = w2ExistingEnd.add(const Duration(seconds: 90));
      // W3: suspected overlap vs live metadata (outside strong tolerance).
      final w3ExistingStart = DateTime(2026, 7, 10, 12, 0);
      final w3ExistingEnd = DateTime(2026, 7, 10, 13, 0);
      final w3IncomingStart = w3ExistingStart.add(const Duration(minutes: 5));
      final w3IncomingEnd = w3ExistingEnd.add(const Duration(minutes: 3));
      // W4: fresh import, no conflicts anywhere.
      final w4Start = DateTime(2026, 7, 10, 14, 0);
      final w4End = DateTime(2026, 7, 10, 15, 0);
      // W5: batch-internal dup — two incoming records, same workout, only
      // the first (sorted) one is accepted.
      final w5Start = DateTime(2026, 7, 10, 16, 0);
      final w5End = DateTime(2026, 7, 10, 17, 0);

      final w1Incoming = aHealthActivity(
        healthPlatformId: 'w1-fresh-uuid',
        startTime: w1Start,
        endTime: w1End,
      );
      final legacyKey =
          'Apple Health_${w1Start.millisecondsSinceEpoch}_${w1End.millisecondsSinceEpoch}';

      final w2Incoming = aHealthActivity(
        healthPlatformId: 'w2-cross-source',
        startTime: w2IncomingStart,
        endTime: w2IncomingEnd,
        sourceName: 'com.sec.android.app.shealth',
        sourceType: 'health_connect',
      );

      final w3Incoming = aHealthActivity(
        healthPlatformId: 'w3-suspected',
        startTime: w3IncomingStart,
        endTime: w3IncomingEnd,
      );

      final w4Incoming = aHealthActivity(
        healthPlatformId: 'w4-fresh',
        startTime: w4Start,
        endTime: w4End,
      );

      final w5First = aHealthActivity(
        healthPlatformId: 'w5-early',
        startTime: w5Start,
        endTime: w5End,
      );
      final w5Second = aHealthActivity(
        healthPlatformId: 'w5-late',
        startTime: w5Start,
        endTime: w5End,
        sourceName: 'com.garmin.android.apps.connectmobile',
        sourceType: 'health_connect',
      );

      final entries = run(
        [
          w1Incoming,
          w2Incoming,
          w3Incoming,
          w4Incoming,
          w5First,
          w5Second,
        ],
        existing: [
          legacyMetadata(healthPlatformId: legacyKey),
          fingerprintMetadata(
            healthPlatformId: 'w2-existing',
            startTime: w2ExistingStart,
            endTime: w2ExistingEnd,
          ),
          fingerprintMetadata(
            healthPlatformId: 'w3-existing',
            startTime: w3ExistingStart,
            endTime: w3ExistingEnd,
          ),
        ],
      );

      expect(
        entries.map((e) => e.activity.healthPlatformId).toList(),
        [
          'w1-fresh-uuid',
          'w2-cross-source',
          'w3-suspected',
          'w4-fresh',
          'w5-early',
          'w5-late',
        ],
      );
      expect(
        entries.map((e) => e.decision).toList(),
        [
          DedupeDecision.skipExactIdentity,
          DedupeDecision.skipStrongDuplicate,
          DedupeDecision.importSuspected,
          DedupeDecision.import,
          DedupeDecision.import,
          DedupeDecision.skipStrongDuplicate,
        ],
      );
    });
  });

  group('output contract', () {
    test('returns one entry per incoming activity with its fingerprint', () {
      final entries = run([
        aHealthActivity(
          healthPlatformId: 'uuid-1',
          activityType: ' running ',
          startTime: start,
          endTime: end,
        ),
      ]);
      expect(entries.single.fingerprint.normalizedType, 'RUNNING');
      expect(entries.single.fingerprint.startTime, start);
      expect(entries.single.fingerprint.endTime, end);
    });

    test('entries come back in deterministic sorted order', () {
      final later = aHealthActivity(
        healthPlatformId: 'uuid-a',
        startTime: start.add(const Duration(hours: 2)),
        endTime: end.add(const Duration(hours: 2)),
      );
      final earlier = aHealthActivity(
        healthPlatformId: 'uuid-b',
        startTime: start,
        endTime: end,
      );
      expect(
        run([later, earlier]).map((e) => e.activity.healthPlatformId).toList(),
        ['uuid-b', 'uuid-a'],
      );
    });
  });
}
