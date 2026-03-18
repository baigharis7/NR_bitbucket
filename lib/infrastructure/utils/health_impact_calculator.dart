import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class HealthImpactCalculator {
  HealthImpactCalculator._();

  // ── Steps ──────────────────────────────────────────────────────────
  // Ranges: Low <5000, Mid 5000-9999, Optimal ≥10000
  // Cardiovascular Health: Low 0→13%, Mid 13→25%, Optimal 25%
  // Physical Endurance:    Low 0→15%, Mid 15→30%, Optimal 30%

  static List<HealthImpactMetric> calculateStepsMetrics(int steps, AppLocalizations l10n) {
    final double cardio;
    final double endurance;

    if (steps >= 10000) {
      cardio = 25;
      endurance = 30;
    } else if (steps >= 5000) {
      cardio = 13;
      endurance = 15;
    } else {
      cardio = 0;
      endurance = 0;
    }

    return [
      HealthImpactMetric(
        type: HealthMetricType.cardiovascularHealth,
        label: l10n.metric_cardiovascular_health,
        sublabel: l10n.metric_sublabel_resting_hr,
        percentage: cardio,
        isPositive: true,
        isNeutral: cardio == 0,
      ),
      HealthImpactMetric(
        type: HealthMetricType.physicalEndurance,
        label: l10n.metric_physical_endurance,
        sublabel: l10n.metric_sublabel_aerobic_capacity,
        percentage: endurance,
        isPositive: true,
        isNeutral: endurance == 0,
      ),
    ];
  }

  // ── Sleep ──────────────────────────────────────────────────────────
  // Ranges: Low <6h, Mid 6-7h, Optimal ≥7h
  // Concentration & Focus: Low ↓25%, Mid ↓15%, Optimal 100%
  // Muscle Regeneration:   Low ↓35%, Mid ↓15%, Optimal 100%

  static List<HealthImpactMetric> calculateSleepMetrics(
    double hours,
    AppLocalizations l10n, [
    SexType? sex,
  ]) {
    final optimalThreshold = sex == SexType.female ? 9.0 : 7.0;
    final double concentration;
    final double muscle;

    if (hours >= optimalThreshold) {
      concentration = 100;
      muscle = 100;
    } else if (hours >= 6) {
      concentration = 15;
      muscle = 15;
    } else {
      concentration = 25;
      muscle = 35;
    }

    return [
      HealthImpactMetric(
        type: HealthMetricType.concentrationFocus,
        label: l10n.metric_concentration_focus,
        sublabel: l10n.metric_sublabel_working_memory,
        percentage: concentration,
        isPositive: hours >= optimalThreshold,
        isNeutral: false,
      ),
      HealthImpactMetric(
        type: HealthMetricType.muscleRegeneration,
        label: l10n.metric_muscle_regeneration,
        sublabel: l10n.metric_sublabel_tissue_repair,
        percentage: muscle,
        isPositive: hours >= optimalThreshold,
        isNeutral: false,
      ),
    ];
  }

  // ── Hydration ──────────────────────────────────────────────────────
  // Ranges: Low <6 glasses, Mid 6-9 glasses, Optimal ≥10 glasses
  // Goodbye Cramps:       Low 0→40%, Mid 40→65%, Optimal 65%
  // Collagen & Elasticity: Low 0→17%, Mid 17→32%, Optimal 32%
  // Kidney Health:         Low 0→30%, Mid 30→65%, Optimal 65%

  static List<HealthImpactMetric> calculateHydrationMetrics(int glasses, AppLocalizations l10n) {
    final double cramps;
    final double collagen;
    final double kidney;

    if (glasses >= 10) {
      cramps = 65;
      collagen = 32;
      kidney = 65;
    } else if (glasses >= 6) {
      cramps = 40;
      collagen = 17;
      kidney = 30;
    } else {
      cramps = 0;
      collagen = 0;
      kidney = 0;
    }

    return [
      HealthImpactMetric(
        type: HealthMetricType.goodbyeCramps,
        label: l10n.metric_cramps,
        sublabel: l10n.metric_sublabel_muscle_cramps,
        percentage: cramps,
        isPositive: true,
        isNeutral: cramps == 0,
      ),
      HealthImpactMetric(
        type: HealthMetricType.collagenElasticity,
        label: l10n.metric_skin_care,
        sublabel: l10n.metric_sublabel_skin_hydration,
        percentage: collagen,
        isPositive: true,
        isNeutral: collagen == 0,
      ),
      HealthImpactMetric(
        type: HealthMetricType.kidneyHealth,
        label: l10n.metric_kidneys,
        sublabel: l10n.metric_sublabel_stone_risk,
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
