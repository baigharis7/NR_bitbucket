import 'package:flutter_test/flutter_test.dart';

import 'health_activity_builder.dart';

void main() {
  group('aHealthActivity / HealthActivityBuilder', () {
    test('produces the canonical Apple Health running activity by default', () {
      final a = aHealthActivity();
      expect(a.healthPlatformId, 'test-activity-id');
      expect(a.activityType, 'RUNNING');
      expect(a.durationMinutes, 60);
      expect(a.caloriesBurned, 500);
      expect(a.distance, 10000);
      expect(a.avgHeartRate, 150);
      expect(a.sourceName, 'Apple Health');
      expect(a.sourceType, 'apple_health');
    });

    test('derives legacyPlatformId from source and times by default', () {
      final a = aHealthActivity();
      expect(
        a.legacyPlatformId,
        'Apple Health_${a.startTime.millisecondsSinceEpoch}_${a.endTime.millisecondsSinceEpoch}',
      );
    });

    test('honours an explicit legacyPlatformId override', () {
      final a = aHealthActivity(legacyPlatformId: 'legacy-x');
      expect(a.legacyPlatformId, 'legacy-x');
    });

    test('overrides scalar fields and allows explicit nulls', () {
      final a = aHealthActivity(
        healthPlatformId: 'x',
        activityType: 'WALKING',
        durationMinutes: 30,
        caloriesBurned: null,
        avgHeartRate: null,
      );
      expect(a.healthPlatformId, 'x');
      expect(a.activityType, 'WALKING');
      expect(a.durationMinutes, 30);
      expect(a.caloriesBurned, isNull);
      expect(a.avgHeartRate, isNull);
      // Untouched fields keep their defaults.
      expect(a.distance, 10000);
      expect(a.sourceType, 'apple_health');
    });

    test('copyWith on the builder yields an independent override', () {
      final base = HealthActivityBuilder();
      final walking = base
          .copyWith(activityType: 'WALKING', caloriesBurned: 200.0)
          .build();
      expect(base.build().activityType, 'RUNNING');
      expect(walking.activityType, 'WALKING');
      expect(walking.caloriesBurned, 200);
    });
  });
}
