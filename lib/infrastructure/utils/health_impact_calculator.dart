import 'dart:math';

import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

class HealthImpactCalculator {
  HealthImpactCalculator._();

  // ── Steps ──────────────────────────────────────────────────────────
  // Cardiovascular (resting HR): 25 × ln(x/1000) / ln(10), capped [0, 25]
  // VO₂ max (endurance):         30 × (x/10000)^0.75,      capped [0, 30]
  // Ranges: <2k, 2-4k, 4-6k, 6-8k, 8-10k, ≥10k

  static List<HealthImpactMetric> calculateStepsMetrics(int steps, AppLocalizations l10n) {
    final double cardio;
    final double endurance;

    if (steps <= 0) {
      cardio = 0;
      endurance = 0;
    } else {
      cardio = (25 * log(steps / 1000) / ln10).clamp(0.0, 25.0);
      endurance = (30 * pow(steps / 10000, 0.75)).toDouble().clamp(0.0, 30.0);
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
  // Concentration deficit: 100 × e^(-0.9 × (h-4.5)) - 5, clamped [0, 100]
  // Muscle deficit:         35 × e^(-1.1 × (h-4.5)),      clamped [0, 35]
  // Females apply +1h offset (need ~1h more for same benefit).
  // Deficit < 0.5 treated as optimal (0%).

  static List<HealthImpactMetric> calculateSleepMetrics(
    double hours,
    AppLocalizations l10n, [
    SexType? sex,
  ]) {
    final offset = sex == SexType.female ? 1.0 : 0.0;
    final h = hours - offset;

    // Hard cutoffs match spec boundaries: concentration 0% at ≥7.5h, muscle 0% at ≥8h
    final double concDeficit;
    final double muscDeficit;
    if (h >= 7.5) {
      concDeficit = 0;
    } else {
      concDeficit = (100 * exp(-0.9 * (h - 4.5)) - 5).clamp(0.0, 100.0);
    }
    if (h >= 8) {
      muscDeficit = 0;
    } else {
      muscDeficit = (35 * exp(-1.1 * (h - 4.5))).clamp(0.0, 35.0);
    }

    final bool concOptimal = concDeficit == 0;
    final bool muscOptimal = muscDeficit == 0;

    return [
      HealthImpactMetric(
        type: HealthMetricType.concentrationFocus,
        label: l10n.metric_concentration_focus,
        sublabel: l10n.metric_sublabel_working_memory,
        percentage: concOptimal ? 0 : concDeficit,
        isPositive: concOptimal,
        isNeutral: false,
      ),
      HealthImpactMetric(
        type: HealthMetricType.muscleRegeneration,
        label: l10n.metric_muscle_regeneration,
        sublabel: l10n.metric_sublabel_tissue_repair,
        percentage: muscOptimal ? 0 : muscDeficit,
        isPositive: muscOptimal,
        isNeutral: false,
      ),
    ];
  }

  // ── Hydration ──────────────────────────────────────────────────────
  // Cramps & Collagen: unchanged 3-tier (no graduality per spec).
  // Kidney: 65 × (1 - e^(-0.55 × (x-3))), clamped [0, 65]
  // Ranges kidney: <4, 4-5, 6-7, 8-9, ≥10 glasses

  static List<HealthImpactMetric> calculateHydrationMetrics(int glasses, AppLocalizations l10n) {
    final double cramps;
    final double collagen;
    if (glasses >= 10) {
      cramps = 65;
      collagen = 32;
    } else if (glasses >= 6) {
      cramps = 40;
      collagen = 17;
    } else {
      cramps = 0;
      collagen = 0;
    }

    final double kidney;
    if (glasses <= 3) {
      kidney = 0;
    } else {
      kidney = (65 * (1 - exp(-0.55 * (glasses - 3)))).clamp(0.0, 65.0);
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
}
