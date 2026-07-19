import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_activity.dart';
import 'package:nutrenaissance_flutter/domain/models/healthsync/health_sync_metadata.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_deduplicator.dart';

import '../../support/healthsync/health_activity_builder.dart';

void main() {
  const deduplicator = HealthWorkoutDeduplicator();
  final start = DateTime(2026, 7, 10, 8, 0);
  final end = DateTime(2026, 7, 10, 9, 0);

  HealthSyncMetadata legacyMetadata({required String healthPlatformId}) =>
      HealthSyncMetadata(
        healthPlatformId: healthPlatformId,
        sportEventId: 1,
        syncedAt: DateTime(2026, 7, 9),
        sourceType: 'health_connect',
      );

  HealthSyncMetadata fingerprintMetadata({
    required String healthPlatformId,
    String normalizedType = 'RUNNING',
    required DateTime startTime,
    required DateTime endTime,
  }) => HealthSyncMetadata(
    healthPlatformId: healthPlatformId,
    sportEventId: 1,
    syncedAt: DateTime(2026, 7, 9),
    sourceType: 'health_connect',
    normalizedType: normalizedType,
    startTimeMs: startTime.millisecondsSinceEpoch,
    endTimeMs: endTime.millisecondsSinceEpoch,
    sourceCategory: 'unknown',
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
