import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';

class HealthImpactCalculator {
  HealthImpactCalculator._();

  // ── Steps ──────────────────────────────────────────────────────────
  // Ranges: Low <5000, Mid 5000-9999, Optimal ≥10000
  // Cardiovascular Health: Low 0→13%, Mid 13→25%, Optimal 25%
  // Physical Endurance:    Low 0→15%, Mid 15→30%, Optimal 30%

  static List<HealthImpactMetric> calculateStepsMetrics(int steps) {
    final cardio = _interpolate(
      value: steps.toDouble(),
      lowUpper: 5000,
      midUpper: 10000,
      midValue: 13,
      optimalValue: 25,
    );
    final endurance = _interpolate(
      value: steps.toDouble(),
      lowUpper: 5000,
      midUpper: 10000,
      midValue: 15,
      optimalValue: 30,
    );

    return [
      HealthImpactMetric(
        type: HealthMetricType.cardiovascularHealth,
        label: 'Cardiovascular H.',
        sublabel: 'IMPROVEMENT',
        percentage: cardio,
        isPositive: true,
        isNeutral: cardio == 0,
      ),
      HealthImpactMetric(
        type: HealthMetricType.physicalEndurance,
        label: 'Physical Endurance',
        sublabel: 'IMPROVEMENT',
        percentage: endurance,
        isPositive: true,
        isNeutral: endurance == 0,
      ),
    ];
  }

  // ── Sleep ──────────────────────────────────────────────────────────
  // Ranges: Low <6h, Mid 6-7h, Optimal ≥7h
  // Concentration & Focus: Low 25→15% decline, Mid 15→0%, Optimal 0%
  // Muscle Regeneration:   Low 35→15% decline, Mid 15→0%, Optimal 0%

  static List<HealthImpactMetric> calculateSleepMetrics(
    double hours, [
    SexType? sex,
  ]) {
    final concentration = _interpolateSleepDecline(
      hours: hours,
      lowDecline: 25,
      midDecline: 15,
    );
    final muscle = _interpolateSleepDecline(
      hours: hours,
      lowDecline: 35,
      midDecline: 15,
    );

    return [
      HealthImpactMetric(
        type: HealthMetricType.concentrationFocus,
        label: 'Mental Clarity',
        sublabel: 'COGNITION',
        percentage: concentration,
        isPositive: concentration == 0,
        isNeutral: false,
      ),
      HealthImpactMetric(
        type: HealthMetricType.muscleRegeneration,
        label: 'Muscle Recovery',
        sublabel: 'REGENERATION',
        percentage: muscle,
        isPositive: muscle == 0,
        isNeutral: false,
      ),
    ];
  }

  // ── Hydration ──────────────────────────────────────────────────────
  // Ranges: Low <6 glasses, Mid 6-9 glasses, Optimal ≥10 glasses
  // Goodbye Cramps:       Low 0→40%, Mid 40→65%, Optimal 65%
  // Collagen & Elasticity: Low 0→17%, Mid 17→32%, Optimal 32%
  // Kidney Health:         Low 0→30%, Mid 30→65%, Optimal 65%

  static List<HealthImpactMetric> calculateHydrationMetrics(int glasses) {
    final cramps = _interpolate(
      value: glasses.toDouble(),
      lowUpper: 6,
      midUpper: 10,
      midValue: 40,
      optimalValue: 65,
    );
    final collagen = _interpolate(
      value: glasses.toDouble(),
      lowUpper: 6,
      midUpper: 10,
      midValue: 17,
      optimalValue: 32,
    );
    final kidney = _interpolate(
      value: glasses.toDouble(),
      lowUpper: 6,
      midUpper: 10,
      midValue: 30,
      optimalValue: 65,
    );

    return [
      HealthImpactMetric(
        type: HealthMetricType.goodbyeCramps,
        label: 'Goodbye Cramps',
        sublabel: 'LESS RISK OF CRAMPS',
        percentage: cramps,
        isPositive: true,
        isNeutral: cramps == 0,
      ),
      HealthImpactMetric(
        type: HealthMetricType.collagenElasticity,
        label: 'Skin Care',
        sublabel: 'SKIN IMPROVEMENT',
        percentage: collagen,
        isPositive: true,
        isNeutral: collagen == 0,
      ),
      HealthImpactMetric(
        type: HealthMetricType.kidneyHealth,
        label: 'Kidney Health',
        sublabel: 'DETOX',
        percentage: kidney,
        isPositive: true,
        isNeutral: kidney == 0,
      ),
    ];
  }

  // ── Helpers ────────────────────────────────────────────────────────

  /// Linear interpolation for positive metrics (steps, hydration).
  /// Low range [0, lowUpper): interpolate 0 → midValue
  /// Mid range [lowUpper, midUpper): interpolate midValue → optimalValue
  /// Optimal [midUpper, ∞): optimalValue
  static double _interpolate({
    required double value,
    required double lowUpper,
    required double midUpper,
    required double midValue,
    required double optimalValue,
  }) {
    if (value <= 0) return 0;
    if (value >= midUpper) return optimalValue;
    if (value < lowUpper) {
      return (value / lowUpper) * midValue;
    }
    // Mid range
    final progress = (value - lowUpper) / (midUpper - lowUpper);
    return midValue + progress * (optimalValue - midValue);
  }

  /// Linear interpolation for sleep decline metrics.
  /// Low [0, 6h): interpolate lowDecline → midDecline
  /// Mid [6h, 7h): interpolate midDecline → 0
  /// Optimal [7h, ∞): 0 (no decline)
  static double _interpolateSleepDecline({
    required double hours,
    required double lowDecline,
    required double midDecline,
  }) {
    if (hours >= 7) return 0;
    if (hours <= 0) return lowDecline;
    if (hours < 6) {
      // Interpolate from lowDecline at 0h to midDecline at 6h
      return lowDecline - (hours / 6) * (lowDecline - midDecline);
    }
    // Mid range: 6-7h, interpolate midDecline → 0
    return midDecline * (7 - hours);
  }
}
