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

    test('low range: 2500 steps gives fixed 0%', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(2500, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
    });

    test('low boundary: 4999 steps still 0%', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(4999, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
      expect(metrics[0].isNeutral, true);
    });

    test('mid start: 5000 steps gives mid values', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(5000, l10n);
      expect(metrics[0].percentage, 13);
      expect(metrics[1].percentage, 15);
      expect(metrics[0].isNeutral, false);
    });

    test('mid range: 7500 steps gives same fixed mid values', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(7500, l10n);
      expect(metrics[0].percentage, 13);
      expect(metrics[1].percentage, 15);
    });

    test('mid boundary: 9999 steps still mid values', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(9999, l10n);
      expect(metrics[0].percentage, 13);
      expect(metrics[1].percentage, 15);
    });

    test('optimal: 10000 steps gives optimal values', () {
      final metrics = HealthImpactCalculator.calculateStepsMetrics(10000, l10n);
      expect(metrics[0].percentage, 25);
      expect(metrics[1].percentage, 30);
    });

    test('above optimal: 15000 steps caps at optimal values', () {
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
  });

  // ── Sleep ────────────────────────────────────────────────────────

  group('calculateSleepMetrics', () {
    test('0 hours returns low decline', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(0, l10n);
      expect(metrics[0].percentage, 25); // concentration
      expect(metrics[1].percentage, 35); // muscle
      expect(metrics[0].isPositive, false);
      expect(metrics[1].isPositive, false);
    });

    test('low range: 3 hours gives same fixed low values', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(3, l10n);
      expect(metrics[0].percentage, 25);
      expect(metrics[1].percentage, 35);
    });

    test('low boundary: 5.9 hours still low range', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(5.9, l10n);
      expect(metrics[0].percentage, 25);
      expect(metrics[1].percentage, 35);
      expect(metrics[0].isPositive, false);
    });

    test('mid start: 6 hours gives mid decline', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(6, l10n);
      expect(metrics[0].percentage, 15);
      expect(metrics[1].percentage, 15);
      expect(metrics[0].isPositive, false);
    });

    test('mid range: 6.5 hours gives same fixed mid values', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(6.5, l10n);
      expect(metrics[0].percentage, 15);
      expect(metrics[1].percentage, 15);
    });

    test('optimal: 7 hours gives 100% positive (male/default)', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, l10n);
      expect(metrics[0].percentage, 100);
      expect(metrics[1].percentage, 100);
      expect(metrics[0].isPositive, true);
      expect(metrics[1].isPositive, true);
    });

    test('above optimal: 8 hours still 100% positive', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(8, l10n);
      expect(metrics[0].percentage, 100);
      expect(metrics[1].percentage, 100);
    });

    test('male: 7 hours is optimal', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, l10n, SexType.male);
      expect(metrics[0].percentage, 100);
      expect(metrics[1].percentage, 100);
      expect(metrics[0].isPositive, true);
    });

    test('female: 7 hours is mid range (needs 9+)', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, l10n, SexType.female);
      expect(metrics[0].percentage, 15);
      expect(metrics[1].percentage, 15);
      expect(metrics[0].isPositive, false);
    });

    test('female: 8 hours still mid range', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(8, l10n, SexType.female);
      expect(metrics[0].percentage, 15);
      expect(metrics[1].percentage, 15);
    });

    test('female: 9 hours is optimal', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(9, l10n, SexType.female);
      expect(metrics[0].percentage, 100);
      expect(metrics[1].percentage, 100);
      expect(metrics[0].isPositive, true);
    });

    test('null sex: 7 hours is optimal (defaults to male threshold)', () {
      final metrics = HealthImpactCalculator.calculateSleepMetrics(7, l10n, null);
      expect(metrics[0].percentage, 100);
      expect(metrics[1].percentage, 100);
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

    test('low range: 3 glasses gives fixed 0%', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(3, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[1].percentage, 0);
      expect(metrics[2].percentage, 0);
    });

    test('low boundary: 5 glasses still 0%', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(5, l10n);
      expect(metrics[0].percentage, 0);
      expect(metrics[0].isNeutral, true);
    });

    test('mid start: 6 glasses gives mid values', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(6, l10n);
      expect(metrics[0].percentage, 40);
      expect(metrics[1].percentage, 17);
      expect(metrics[2].percentage, 30);
      expect(metrics[0].isNeutral, false);
    });

    test('mid range: 8 glasses gives same fixed mid values', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(8, l10n);
      expect(metrics[0].percentage, 40);
      expect(metrics[1].percentage, 17);
      expect(metrics[2].percentage, 30);
    });

    test('mid boundary: 9 glasses still mid values', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(9, l10n);
      expect(metrics[0].percentage, 40);
      expect(metrics[1].percentage, 17);
      expect(metrics[2].percentage, 30);
    });

    test('optimal: 10 glasses gives optimal values', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(10, l10n);
      expect(metrics[0].percentage, 65);
      expect(metrics[1].percentage, 32);
      expect(metrics[2].percentage, 65);
    });

    test('above optimal: 15 glasses caps at optimal', () {
      final metrics = HealthImpactCalculator.calculateHydrationMetrics(15, l10n);
      expect(metrics[0].percentage, 65);
      expect(metrics[1].percentage, 32);
      expect(metrics[2].percentage, 65);
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
