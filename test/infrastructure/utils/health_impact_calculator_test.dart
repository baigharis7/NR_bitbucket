import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations_en.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_impact_calculator.dart';

void main() {
  final l10n = AppLocalizationsEn();

  // ── Steps ────────────────────────────────────────────────────────

  group('calculateStepsMetrics', () {
    test('0 steps returns 0% for both metrics (neutral)', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(0, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[0].isNeutral, true);
      expect(metrics[1].percentage, 0);
      expect(metrics[1].isNeutral, true);
    });

    test('500 steps: cardio clamped to 0 (log gives negative), endurance > 0', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(500, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, greaterThan(0));
    });

    test('1000 steps: cardio = 0, endurance ~5.3', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(1000, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, closeTo(5.3, 0.2));
      expect(metrics[0].isNeutral, true);
    });

    test('2000 steps: cardio ~7.5, endurance ~9.0', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(2000, l10n);
      expect(metrics[0].percentage, closeTo(7.53, 0.1));
      expect(metrics[1].percentage, closeTo(8.97, 0.2));
      expect(metrics[0].isNeutral, false);
    });

    test('5000 steps: cardio ~17.5, endurance ~17.8', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(5000, l10n);
      expect(metrics[0].percentage, closeTo(17.47, 0.1));
      expect(metrics[1].percentage, closeTo(17.85, 0.2));
    });

    test('10000 steps gives capped cardio=25, endurance=30', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(10000, l10n);
      expect(metrics[0].percentage, closeTo(25, 0.01));
      expect(metrics[1].percentage, closeTo(30, 0.01));
    });

    test('above 10000: caps at optimal values', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(15000, l10n);
      expect(metrics[0].percentage, 25);
      expect(metrics[1].percentage, 30);
    });

    test('metric types are correct', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(5000, l10n);
      expect(metrics[0].type, HealthMetricType.cardiovascularHealth);
      expect(metrics[1].type, HealthMetricType.physicalEndurance);
    });

    test('metrics are always positive direction', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(5000, l10n);
      expect(metrics[0].isPositive, true);
      expect(metrics[1].isPositive, true);
    });

    test('values increase monotonically', () {
      final steps = [0, 1000, 2000, 4000, 6000, 8000, 10000];
      double prevCardio = -1;
      double prevEndurance = -1;
      for (final s in steps) {
        final m = HealthImpactCalculator.calculateStepsMetrics(s, l10n);
        expect(m[0].percentage, greaterThanOrEqualTo(prevCardio));
        expect(m[1].percentage, greaterThanOrEqualTo(prevEndurance));
        prevCardio = m[0].percentage;
        prevEndurance = m[1].percentage;
      }
    });
  });

  // ── Sleep ────────────────────────────────────────────────────────

  group('calculateSleepMetrics', () {
    test('0 hours returns max deficit (clamped)', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(0, l10n);
      expect(metrics[0].percentage, 100); // concentration capped at 100
      expect(metrics[1].percentage, 35);  // muscle capped at 35
      expect(metrics[0].isPositive, false);
      expect(metrics[1].isPositive, false);
    });

    test('4 hours: high deficit', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(4, l10n);
      expect(metrics[0].percentage, 100); // still clamped at 100
      expect(metrics[1].percentage, closeTo(35, 0.1)); // clamped at 35
      expect(metrics[0].isPositive, false);
    });

    test('5 hours: concentration ~58.8, muscle ~20.2', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(5, l10n);
      expect(metrics[0].percentage, closeTo(58.76, 1.0));
      expect(metrics[1].percentage, closeTo(20.19, 1.0));
      expect(metrics[0].isPositive, false);
    });

    test('6 hours: concentration ~20.9, muscle ~6.7', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(6, l10n);
      expect(metrics[0].percentage, closeTo(20.92, 1.0));
      expect(metrics[1].percentage, closeTo(6.72, 1.0));
      expect(metrics[0].isPositive, false);
    });

    test('7 hours: concentration ~5.5, muscle ~2.2', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, l10n);
      expect(metrics[0].percentage, closeTo(5.54, 1.0));
      expect(metrics[1].percentage, closeTo(2.24, 1.0));
      expect(metrics[0].isPositive, false);
      expect(metrics[1].isPositive, false);
    });

    test('7.5 hours: concentration optimal (0%), muscle still has deficit', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7.5, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[0].isPositive, true);
      expect(metrics[1].percentage, greaterThan(0));
      expect(metrics[1].isPositive, false);
    });

    test('8 hours: both optimal (0%)', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(8, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[0].isPositive, true);
      expect(metrics[1].percentage, 0);
      expect(metrics[1].isPositive, true);
    });

    test('9 hours: still optimal', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(9, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[0].isPositive, true);
      expect(metrics[1].percentage, 0);
      expect(metrics[1].isPositive, true);
    });

    test('deficit decreases monotonically as hours increase', () {
      final hours = [0.0, 3.0, 5.0, 6.0, 7.0, 7.5, 8.0];
      double prevConc = 200;
      double prevMus = 200;
      for (final h in hours) {
        final m = HealthImpactCalculator.calculateSleepMetrics(h, l10n);
        expect(m[0].percentage, lessThanOrEqualTo(prevConc));
        expect(m[1].percentage, lessThanOrEqualTo(prevMus));
        prevConc = m[0].percentage;
        prevMus = m[1].percentage;
      }
    });

    // Sex-based offset tests
    test('female: 7 hours has significant deficit (needs +1h more)', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, l10n, SexType.female);
      // Female at 7h = male at 6h
      expect(metrics[0].percentage, closeTo(20.92, 1.0));
      expect(metrics[0].isPositive, false);
    });

    test('female: 8 hours has some deficit', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(8, l10n, SexType.female);
      // Female at 8h = male at 7h
      expect(metrics[0].percentage, closeTo(5.54, 1.0));
      expect(metrics[0].isPositive, false);
    });

    test('female: 8.5 hours: concentration optimal, muscle still has deficit', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(8.5, l10n, SexType.female);
      // Female at 8.5h = male at 7.5h
      expect(metrics[0].percentage, 0);
      expect(metrics[0].isPositive, true);
      expect(metrics[1].isPositive, false);
    });

    test('female: 9 hours is fully optimal', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(9, l10n, SexType.female);
      // Female at 9h = male at 8h
      expect(metrics[0].percentage, 0);
      expect(metrics[0].isPositive, true);
      expect(metrics[1].percentage, 0);
      expect(metrics[1].isPositive, true);
    });

    test('male: same as default (no offset)', () {
      final def = HealthImpactCalculator.calculateSleepMetrics(7, l10n);
      final male = HealthImpactCalculator.calculateSleepMetrics(7, l10n, SexType.male);
      expect(male[0].percentage, def[0].percentage);
      expect(male[1].percentage, def[1].percentage);
    });

    test('null sex: same as default (no offset)', () {
      final def = HealthImpactCalculator.calculateSleepMetrics(7, l10n);
      final nul = HealthImpactCalculator.calculateSleepMetrics(7, l10n, null);
      expect(nul[0].percentage, def[0].percentage);
      expect(nul[1].percentage, def[1].percentage);
    });

    test('metric types are correct', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, l10n);
      expect(metrics[0].type, HealthMetricType.concentrationFocus);
      expect(metrics[1].type, HealthMetricType.muscleRegeneration);
    });
  });

  // ── Hydration ────────────────────────────────────────────────────

  group('calculateHydrationMetrics', () {
    test('0 glasses returns 0% for all (neutral)', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(0, l10n);
      expect(metrics.length, 3);
      for (final m in metrics) {
        expect(m.percentage, 0);
        expect(m.isNeutral, true);
      }
    });

    test('low range: 3 glasses — cramps/collagen 0%, kidney 0%', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(3, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
      expect(metrics[2].percentage, 0);
    });

    test('4 glasses: cramps/collagen still 0%, kidney ~27.5', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(4, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
      expect(metrics[2].percentage, closeTo(27.5, 1.0));
    });

    test('5 glasses: cramps/collagen still 0%, kidney ~43.4', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(5, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[0].isNeutral, true);
      expect(metrics[2].percentage, closeTo(43.4, 1.0));
    });

    test('mid start: 6 glasses — cramps=40, collagen=17, kidney ~52.5', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(6, l10n);
      expect(metrics[0].percentage, 40);
      expect(metrics[1].percentage, 17);
      expect(metrics[2].percentage, closeTo(52.5, 1.0));
      expect(metrics[0].isNeutral, false);
    });

    test('mid range: 8 glasses — cramps=40, collagen=17, kidney ~60.8', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(8, l10n);
      expect(metrics[0].percentage, 40);
      expect(metrics[1].percentage, 17);
      expect(metrics[2].percentage, closeTo(60.8, 1.0));
    });

    test('9 glasses: cramps=40, collagen=17', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(9, l10n);
      expect(metrics[0].percentage, 40);
      expect(metrics[1].percentage, 17);
    });

    test('optimal: 10 glasses — cramps=65, collagen=32, kidney ~63.6', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(10, l10n);
      expect(metrics[0].percentage, 65);
      expect(metrics[1].percentage, 32);
      expect(metrics[2].percentage, closeTo(63.6, 1.0));
    });

    test('above optimal: 15 glasses — cramps/collagen capped, kidney approaches 65', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(15, l10n);
      expect(metrics[0].percentage, 65);
      expect(metrics[1].percentage, 32);
      expect(metrics[2].percentage, closeTo(64.9, 0.5));
      expect(metrics[2].percentage, lessThanOrEqualTo(65));
    });

    test('kidney increases monotonically', () {
      final glasses = [0, 3, 4, 5, 6, 7, 8, 9, 10, 15];
      double prevKidney = -1;
      for (final g in glasses) {
        final m = HealthImpactCalculator.calculateHydrationMetrics(g, l10n);
        expect(m[2].percentage, greaterThanOrEqualTo(prevKidney));
        prevKidney = m[2].percentage;
      }
    });

    test('metric types are correct', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(6, l10n);
      expect(metrics[0].type, HealthMetricType.goodbyeCramps);
      expect(metrics[1].type, HealthMetricType.collagenElasticity);
      expect(metrics[2].type, HealthMetricType.kidneyHealth);
    });

    test('all metrics are positive direction', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(6, l10n);
      for (final m in metrics) {
        expect(m.isPositive, true);
      }
    });
  });
}
