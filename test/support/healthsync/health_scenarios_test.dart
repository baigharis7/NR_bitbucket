import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';

import 'health_scenarios.dart';

void main() {
  group('duplicateWorkoutAcrossSources', () {
    test('yields 2 workouts, distinct sources, <2min drift', () {
      final from = DateTime(2026, 7, 1, 8, 0);
      final to = DateTime(2026, 7, 1, 9, 0);
      final points = duplicateWorkoutAcrossSources(from: from, to: to);
      expect(points, hasLength(2));
      expect(points.every((p) => p.type == HealthDataType.WORKOUT), isTrue);
      expect(points[0].sourceName, isNot(points[1].sourceName));
      final drift = points[1].dateFrom.difference(points[0].dateFrom).abs();
      expect(drift.inMinutes, lessThan(2));
      expect(points[1].dateFrom.isAfter(points[0].dateFrom), isTrue);
    });
  });

  group('distinctWorkoutsSameStart', () {
    test('yields 2 workouts sharing a start but differing in type/end', () {
      final start = DateTime(2026, 7, 1, 8, 0);
      final points = distinctWorkoutsSameStart(start: start);
      expect(points, hasLength(2));
      expect(points[0].dateFrom, points[1].dateFrom);
      expect(points[0].dateTo, isNot(points[1].dateTo));
      final a0 = (points[0].value as WorkoutHealthValue).workoutActivityType;
      final a1 = (points[1].value as WorkoutHealthValue).workoutActivityType;
      expect(a0, isNot(a1));
    });
  });

  group('overlappingStepRecords', () {
    test('yields 2 overlapping STEPS records from distinct sources', () {
      final from = DateTime(2026, 7, 1, 8, 0);
      final to = DateTime(2026, 7, 1, 10, 0);
      final points = overlappingStepRecords(from: from, to: to);
      expect(points, hasLength(2));
      expect(points.every((p) => p.type == HealthDataType.STEPS), isTrue);
      expect(points[1].dateFrom.isBefore(points[0].dateTo), isTrue);
      expect(points[0].sourceName, isNot(points[1].sourceName));
    });
  });

  group('overlappingSleepSessions', () {
    test('yields 2 overlapping SLEEP_SESSION records', () {
      final from = DateTime(2026, 6, 30, 23, 0);
      final to = DateTime(2026, 7, 1, 6, 0);
      final points = overlappingSleepSessions(from: from, to: to);
      expect(points, hasLength(2));
      expect(
        points.every((p) => p.type == HealthDataType.SLEEP_SESSION),
        isTrue,
      );
      expect(points[1].dateFrom.isBefore(points[0].dateTo), isTrue);
    });
  });

  group('crossMidnightSleepSession', () {
    test('yields 1 SLEEP_SESSION that spans two calendar days', () {
      final points = crossMidnightSleepSession(
        bedTime: DateTime(2026, 6, 30, 23, 0),
        wakeTime: DateTime(2026, 7, 1, 6, 0),
      );
      expect(points, hasLength(1));
      final p = points.single;
      expect(p.type, HealthDataType.SLEEP_SESSION);
      expect(p.dateFrom.day, isNot(p.dateTo.day));
      expect(p.dateTo.isAfter(p.dateFrom), isTrue);
    });
  });

  group('plannedSleepWindowPlusActual', () {
    test('yields planned + actual SLEEP_SESSIONs from distinct sources', () {
      final points = plannedSleepWindowPlusActual(
        plannedFrom: DateTime(2026, 6, 30, 22, 0),
        plannedTo: DateTime(2026, 7, 1, 6, 0),
        actualFrom: DateTime(2026, 6, 30, 23, 15),
        actualTo: DateTime(2026, 7, 1, 5, 30),
      );
      expect(points, hasLength(2));
      expect(
        points.every((p) => p.type == HealthDataType.SLEEP_SESSION),
        isTrue,
      );
      expect(points[0].sourceName, isNot(points[1].sourceName));
      expect(points[0].dateFrom, isNot(points[1].dateFrom));
    });
  });
}
