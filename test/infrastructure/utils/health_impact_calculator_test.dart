import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_impact_calculator.dart';

void main() {
  // ── Steps ────────────────────────────────────────────────────────

  group('calculateStepsMetrics', () {
    test('0 steps returns 0% for both metrics (neutral)', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(0);
      expect(metrics[0].percentage, 0);
      expect(metrics[0].isNeutral, true);
      expect(metrics[1].percentage, 0);
      expect(metrics[1].isNeutral, true);
    });

    test('low range boundary: 4999 steps interpolates just under mid values', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(4999);
      // 4999/5000 * 13 ≈ 12.997
      expect(metrics[0].percentage, closeTo(12.997, 0.01));
      // 4999/5000 * 15 ≈ 14.997
      expect(metrics[1].percentage, closeTo(14.997, 0.01));
    });

    test('mid range start: 5000 steps gives exact mid values', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(5000);
      expect(metrics[0].percentage, closeTo(13, 0.01));
      expect(metrics[1].percentage, closeTo(15, 0.01));
    });

    test('mid range midpoint: 7500 steps interpolates halfway', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(7500);
      // cardio: 13 + (2500/5000) * (25-13) = 13 + 6 = 19
      expect(metrics[0].percentage, closeTo(19, 0.01));
      // endurance: 15 + (2500/5000) * (30-15) = 15 + 7.5 = 22.5
      expect(metrics[1].percentage, closeTo(22.5, 0.01));
    });

    test('mid range boundary: 9999 steps interpolates just under optimal', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(9999);
      expect(metrics[0].percentage, closeTo(25, 0.1));
      expect(metrics[1].percentage, closeTo(30, 0.1));
    });

    test('optimal: 10000 steps gives exact optimal values', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(10000);
      expect(metrics[0].percentage, 25);
      expect(metrics[1].percentage, 30);
    });

    test('above optimal: 15000 steps caps at optimal values', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(15000);
      expect(metrics[0].percentage, 25);
      expect(metrics[1].percentage, 30);
    });

    test('low range midpoint: 2500 steps interpolates halfway to mid', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(2500);
      // cardio: 2500/5000 * 13 = 6.5
      expect(metrics[0].percentage, closeTo(6.5, 0.01));
      // endurance: 2500/5000 * 15 = 7.5
      expect(metrics[1].percentage, closeTo(7.5, 0.01));
    });

    test('metric types are correct', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(5000);
      expect(metrics[0].type, HealthMetricType.cardiovascularHealth);
      expect(metrics[1].type, HealthMetricType.physicalEndurance);
    });

    test('metrics are always positive direction', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(5000);
      expect(metrics[0].isPositive, true);
      expect(metrics[1].isPositive, true);
    });
  });

  // ── Sleep ────────────────────────────────────────────────────────

  group('calculateSleepMetrics', () {
    test('0 hours returns max decline', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(0);
      expect(metrics[0].percentage, 25); // concentration
      expect(metrics[1].percentage, 35); // muscle
      expect(metrics[0].isPositive, false);
      expect(metrics[1].isPositive, false);
    });

    test('low range: 3 hours interpolates halfway between max and mid decline', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(3);
      // concentration: 25 - (3/6) * (25-15) = 25 - 5 = 20
      expect(metrics[0].percentage, closeTo(20, 0.01));
      // muscle: 35 - (3/6) * (35-15) = 35 - 10 = 25
      expect(metrics[1].percentage, closeTo(25, 0.01));
    });

    test('low boundary: 5.9 hours near mid decline', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(5.9);
      // concentration: 25 - (5.9/6) * 10 ≈ 25 - 9.833 ≈ 15.167
      expect(metrics[0].percentage, closeTo(15.167, 0.01));
    });

    test('mid start: 6 hours gives exact mid decline', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(6);
      // concentration: 15 * (7-6) = 15
      expect(metrics[0].percentage, closeTo(15, 0.01));
      // muscle: 15 * (7-6) = 15
      expect(metrics[1].percentage, closeTo(15, 0.01));
    });

    test('mid range: 6.5 hours interpolates halfway to optimal', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(6.5);
      // concentration: 15 * (7-6.5) = 15 * 0.5 = 7.5
      expect(metrics[0].percentage, closeTo(7.5, 0.01));
      // muscle: 15 * (7-6.5) = 7.5
      expect(metrics[1].percentage, closeTo(7.5, 0.01));
    });

    test('optimal: 7 hours gives 0% decline', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
      expect(metrics[0].isPositive, true);
      expect(metrics[1].isPositive, true);
    });

    test('above optimal: 8 hours still 0% decline', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(8);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
    });

    test('works the same for male sex', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, SexType.male);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
    });

    test('works the same for female sex', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, SexType.female);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
    });

    test('works with null sex', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, null);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
    });

    test('metric types are correct', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7);
      expect(metrics[0].type, HealthMetricType.concentrationFocus);
      expect(metrics[1].type, HealthMetricType.muscleRegeneration);
    });
  });

  // ── Hydration ────────────────────────────────────────────────────

  group('calculateHydrationMetrics', () {
    test('0 glasses returns 0% for all (neutral)', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(0);
      expect(metrics.length, 3);
      for (final m in metrics) {
        expect(m.percentage, 0);
        expect(m.isNeutral, true);
      }
    });

    test('low range: 3 glasses interpolates halfway to mid', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(3);
      // cramps: (3/6) * 40 = 20
      expect(metrics[0].percentage, closeTo(20, 0.01));
      // collagen: (3/6) * 17 = 8.5
      expect(metrics[1].percentage, closeTo(8.5, 0.01));
      // kidney: (3/6) * 30 = 15
      expect(metrics[2].percentage, closeTo(15, 0.01));
    });

    test('low boundary: 5 glasses near mid values', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(5);
      // cramps: (5/6) * 40 ≈ 33.33
      expect(metrics[0].percentage, closeTo(33.33, 0.01));
    });

    test('mid start: 6 glasses gives exact mid values', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(6);
      expect(metrics[0].percentage, closeTo(40, 0.01));
      expect(metrics[1].percentage, closeTo(17, 0.01));
      expect(metrics[2].percentage, closeTo(30, 0.01));
    });

    test('mid range: 8 glasses interpolates within mid range', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(8);
      // cramps: 40 + (2/4) * (65-40) = 40 + 12.5 = 52.5
      expect(metrics[0].percentage, closeTo(52.5, 0.01));
      // collagen: 17 + (2/4) * (32-17) = 17 + 7.5 = 24.5
      expect(metrics[1].percentage, closeTo(24.5, 0.01));
      // kidney: 30 + (2/4) * (65-30) = 30 + 17.5 = 47.5
      expect(metrics[2].percentage, closeTo(47.5, 0.01));
    });

    test('optimal: 10 glasses gives exact optimal values', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(10);
      expect(metrics[0].percentage, 65);
      expect(metrics[1].percentage, 32);
      expect(metrics[2].percentage, 65);
    });

    test('above optimal: 15 glasses caps at optimal', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(15);
      expect(metrics[0].percentage, 65);
      expect(metrics[1].percentage, 32);
      expect(metrics[2].percentage, 65);
    });

    test('metric types are correct', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(6);
      expect(metrics[0].type, HealthMetricType.goodbyeCramps);
      expect(metrics[1].type, HealthMetricType.collagenElasticity);
      expect(metrics[2].type, HealthMetricType.kidneyHealth);
    });

    test('all metrics are positive direction', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(6);
      for (final m in metrics) {
        expect(m.isPositive, true);
      }
    });
  });
}
