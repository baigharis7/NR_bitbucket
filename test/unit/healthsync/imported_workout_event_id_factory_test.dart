import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_fingerprint.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/imported_workout_event_id_factory.dart';

import '../../support/healthsync/health_activity_builder.dart';

void main() {
  const idFactory = ImportedWorkoutEventIdFactory();

  HealthWorkoutFingerprint fingerprintFor({
    String activityType = 'RUNNING',
    DateTime? startTime,
    DateTime? endTime,
    int durationMinutes = 60,
  }) {
    final start = startTime ?? DateTime(2026, 7, 1, 8, 0, 0);
    return HealthWorkoutFingerprint.fromActivity(
      aHealthActivity(
        activityType: activityType,
        startTime: start,
        endTime: endTime ?? start.add(Duration(minutes: durationMinutes)),
        durationMinutes: durationMinutes,
      ),
    );
  }

  group('ImportedWorkoutEventIdFactory.eventIdFor', () {
    test('is deterministic: the same workout always yields the same id', () {
      final first = fingerprintFor();
      final second = fingerprintFor();

      expect(idFactory.eventIdFor(first), idFactory.eventIdFor(second));
      expect(
        idFactory.eventIdFor(first),
        const ImportedWorkoutEventIdFactory().eventIdFor(first),
      );
    });

    test('keeps 13-digit epoch-millis scale and second-precision ordering', () {
      final start = DateTime(2026, 7, 1, 8, 0, 0);
      final earlier = fingerprintFor(startTime: start);
      final later = fingerprintFor(
        startTime: start.add(const Duration(seconds: 1)),
      );

      final earlierId = idFactory.eventIdFor(earlier);
      final laterId = idFactory.eventIdFor(later);

      // Same magnitude as today's epoch-millis ids (13 digits this era), so
      // imported events keep interleaving with manual DateTime.now() ids in
      // getTodaySportEvents' eventId sort.
      expect(
        earlierId.toString().length,
        start.millisecondsSinceEpoch.toString().length,
      );
      // The seconds bucket is exactly the start time to the second.
      expect(earlierId ~/ 1000, start.millisecondsSinceEpoch ~/ 1000);
      // One second later strictly orders after, whatever the hash suffixes.
      expect(laterId, greaterThan(earlierId));
    });

    test('suffix is stableHash % 1000, inside [0, 999]', () {
      final fingerprint = fingerprintFor();

      final id = idFactory.eventIdFor(fingerprint);

      expect(id % 1000, fingerprint.stableHash % 1000);
      expect(id % 1000, inInclusiveRange(0, 999));
    });

    test(
      'two distinct same-second workouts get distinct ids via the suffix',
      () {
        final start = DateTime(2026, 7, 1, 8, 0, 0);
        final running = fingerprintFor(startTime: start);
        final cycling = fingerprintFor(
          activityType: 'CYCLING',
          startTime: start,
          durationMinutes: 45,
        );

        final runningId = idFactory.eventIdFor(running);
        final cyclingId = idFactory.eventIdFor(cycling);

        expect(runningId ~/ 1000, cyclingId ~/ 1000); // same second bucket
        expect(runningId, isNot(cyclingId));
      },
    );

    test('sub-second start drift lands in the same second bucket', () {
      final base = DateTime(2026, 7, 1, 8, 0, 0);
      final onTheSecond = fingerprintFor(startTime: base);
      final midSecond = fingerprintFor(
        startTime: base.add(const Duration(milliseconds: 400)),
      );

      expect(
        idFactory.eventIdFor(onTheSecond) ~/ 1000,
        idFactory.eventIdFor(midSecond) ~/ 1000,
      );
    });

    test('stays below 2^53 (JS-safe) even for far-future start times', () {
      final farFuture = fingerprintFor(
        startTime: DateTime.utc(2255, 12, 31, 23, 59, 59),
      );

      expect(idFactory.eventIdFor(farFuture), lessThan(9007199254740992));
    });
  });
}
