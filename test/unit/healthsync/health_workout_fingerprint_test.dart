import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_source_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_fingerprint.dart';

import '../../support/healthsync/health_activity_builder.dart';

void main() {
  group('HealthWorkoutFingerprint.fromActivity', () {
    test('normalizes the type and resolves the source category', () {
      final activity = aHealthActivity(
        activityType: ' running ',
        sourceName: 'com.sec.android.app.shealth',
        sourceType: 'health_connect',
      );

      final fp = HealthWorkoutFingerprint.fromActivity(activity);

      expect(fp.normalizedType, 'RUNNING');
      expect(fp.startTime, activity.startTime);
      expect(fp.endTime, activity.endTime);
      expect(fp.durationMinutes, activity.durationMinutes);
      expect(fp.sourceCategory, HealthSourceCategory.samsungHealth);
    });

    test('empty type fingerprints as WORKOUT', () {
      final fp = HealthWorkoutFingerprint.fromActivity(
        aHealthActivity(activityType: ''),
      );
      expect(fp.normalizedType, 'WORKOUT');
    });
  });

  group('HealthWorkoutFingerprint.stableHash', () {
    HealthWorkoutFingerprint fingerprint({
      String normalizedType = 'RUNNING',
      int startMs = 1000000000000,
      int endMs = 1000003600000,
      HealthSourceCategory sourceCategory = HealthSourceCategory.unknown,
    }) => HealthWorkoutFingerprint(
      normalizedType: normalizedType,
      startTime: DateTime.fromMillisecondsSinceEpoch(startMs),
      endTime: DateTime.fromMillisecondsSinceEpoch(endMs),
      durationMinutes: (endMs - startMs) ~/ 60000,
      sourceCategory: sourceCategory,
    );

    test('matches the FNV-1a 32-bit reference vector', () {
      // FNV-1a 32-bit over 'RUNNING|1000000000000|1000003600000'.
      expect(fingerprint().stableHash, 2998339347);
    });

    test('is deterministic across instances', () {
      expect(fingerprint().stableHash, fingerprint().stableHash);
    });

    test('source is deliberately excluded from the hash', () {
      expect(
        fingerprint(sourceCategory: HealthSourceCategory.appleWatch).stableHash,
        fingerprint(
          sourceCategory: HealthSourceCategory.samsungHealth,
        ).stableHash,
      );
    });

    test('type and times change the hash', () {
      expect(
        fingerprint(normalizedType: 'WORKOUT').stableHash,
        isNot(fingerprint().stableHash),
      );
      expect(
        fingerprint(startMs: 1000000060000).stableHash,
        isNot(fingerprint().stableHash),
      );
      expect(
        fingerprint(endMs: 1000003660000).stableHash,
        isNot(fingerprint().stableHash),
      );
    });

    test('stays within the unsigned 32-bit range', () {
      expect(fingerprint().stableHash, inInclusiveRange(0, 0xFFFFFFFF));
    });
  });
}
