import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';

import 'health_data_point_builder.dart';
import 'health_source_fixtures.dart';

void main() {
  final from = DateTime(2026, 7, 1, 8, 0);
  final to = DateTime(2026, 7, 1, 9, 0);

  group('workoutPoint', () {
    test('defaults to a RUNNING workout from the default source', () {
      final p = workoutPoint(from: from, to: to);
      expect(p.type, HealthDataType.WORKOUT);
      final v = p.value as WorkoutHealthValue;
      expect(v.workoutActivityType, HealthWorkoutActivityType.RUNNING);
      expect(v.totalEnergyBurned, isNull);
      expect(v.totalDistance, isNull);
      expect(p.dateFrom, from);
      expect(p.dateTo, to);
      expect(p.unit, HealthDataUnit.NO_UNIT);
      expect(p.sourceName, 'TestSource');
      expect(p.sourcePlatform, HealthPlatformType.appleHealth);
    });

    test(
      'coerces num energy/distance to int and honours a source override',
      () {
        final p = workoutPoint(
          from: from,
          to: to,
          activity: HealthWorkoutActivityType.WALKING,
          totalEnergyBurned: 120.7,
          totalDistance: 2000.9,
          source: appleWatch,
        );
        final v = p.value as WorkoutHealthValue;
        expect(v.workoutActivityType, HealthWorkoutActivityType.WALKING);
        expect(v.totalEnergyBurned, 120);
        expect(v.totalDistance, 2000);
        expect(p.sourceName, 'Apple Watch');
        expect(p.sourcePlatform, HealthPlatformType.appleHealth);
        expect(p.sourceId, 'apple-watch');
        expect(p.sourceDeviceId, 'apple-watch-device');
      },
    );
  });

  group('numericPoint', () {
    test('wraps a NumericHealthValue of the given type and value', () {
      final p = numericPoint(
        type: HealthDataType.STEPS,
        value: 1500,
        from: from,
        to: to,
      );
      expect(p.type, HealthDataType.STEPS);
      expect((p.value as NumericHealthValue).numericValue, 1500);
      expect(p.dateFrom, from);
      expect(p.dateTo, to);
    });
  });

  group('sleepPoint', () {
    test('is a zero-valued SLEEP_SESSION over the window', () {
      final p = sleepPoint(from: from, to: to, source: healthConnect);
      expect(p.type, HealthDataType.SLEEP_SESSION);
      expect((p.value as NumericHealthValue).numericValue, 0);
      expect(p.sourceName, 'Health Connect');
      expect(p.sourcePlatform, HealthPlatformType.googleHealthConnect);
    });
  });

  group('healthDataPoint', () {
    test('stamps the default source fields coherently', () {
      final p = healthDataPoint(
        type: HealthDataType.HEART_RATE,
        value: NumericHealthValue(numericValue: 60),
        from: from,
        to: to,
      );
      expect(p.sourceName, 'TestSource');
      expect(p.sourceId, 'source-id');
      expect(p.sourceDeviceId, 'device');
      expect(p.sourcePlatform, HealthPlatformType.appleHealth);
    });
  });
}
