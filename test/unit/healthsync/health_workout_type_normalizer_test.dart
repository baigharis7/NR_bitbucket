import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/healthsync/health_workout_type_normalizer.dart';

void main() {
  group('HealthWorkoutTypeNormalizer.normalize', () {
    test('trims and uppercases', () {
      expect(HealthWorkoutTypeNormalizer.normalize('  running '), 'RUNNING');
      expect(HealthWorkoutTypeNormalizer.normalize('Running'), 'RUNNING');
    });

    test('passes an already-normalized type through unchanged', () {
      expect(
        HealthWorkoutTypeNormalizer.normalize('RUNNING_TREADMILL'),
        'RUNNING_TREADMILL',
      );
    });

    test('empty and whitespace-only input normalizes to WORKOUT', () {
      expect(HealthWorkoutTypeNormalizer.normalize(''), 'WORKOUT');
      expect(HealthWorkoutTypeNormalizer.normalize('   '), 'WORKOUT');
    });

    test('near-synonym variants stay distinct (conservative)', () {
      expect(
        HealthWorkoutTypeNormalizer.normalize('RUNNING'),
        isNot(HealthWorkoutTypeNormalizer.normalize('RUNNING_TREADMILL')),
      );
    });
  });
}
