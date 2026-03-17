import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class HealthMetricDetailSheet extends StatelessWidget {
  final HealthImpactMetric metric;

  const HealthMetricDetailSheet({super.key, required this.metric});

  static void show(BuildContext context, HealthImpactMetric metric) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => HealthMetricDetailSheet(metric: metric),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _getMetricInfo(metric.type);
    final color = metric.isNeutral
        ? AppColors.battleshipGrey
        : metric.isPositive
            ? AppColors.mountainMeadow
            : AppColors.errorRed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                metric.isNeutral
                    ? Icons.remove_circle_outline
                    : metric.isPositive
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.label,
                      style: AppTextStyles.merriWeather.copyWith(
                        fontSize: Dimens.fontSize20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${metric.percentage.round()}% ${metric.sublabel.toLowerCase()}',
                      style: AppTextStyles.radioCanadaBig.copyWith(
                        fontSize: Dimens.fontSizeNormal,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            info.indicator,
            style: AppTextStyles.dmSans.copyWith(
              fontSize: Dimens.fontSizeSmall,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 20),
          _RangeTile(
            color: AppColors.errorRed,
            label: 'Low',
            range: info.lowRange,
            description: info.lowDescription,
            percentage: info.lowPercentage,
          ),
          const SizedBox(height: 8),
          _RangeTile(
            color: Colors.orange,
            label: 'Mid',
            range: info.midRange,
            description: info.midDescription,
            percentage: info.midPercentage,
          ),
          const SizedBox(height: 8),
          _RangeTile(
            color: AppColors.mountainMeadow,
            label: 'Optimal',
            range: info.optimalRange,
            description: info.optimalDescription,
            percentage: info.optimalPercentage,
          ),
        ],
      ),
    );
  }
}

class _RangeTile extends StatelessWidget {
  final Color color;
  final String label;
  final String range;
  final String description;
  final String percentage;

  const _RangeTile({
    required this.color,
    required this.label,
    required this.range,
    required this.description,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.radioCanadaBig.copyWith(
                        fontSize: Dimens.fontSize13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      range,
                      style: AppTextStyles.dmSans.copyWith(
                        fontSize: Dimens.fontSize11,
                        color: Colors.white60,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      percentage,
                      style: AppTextStyles.radioCanadaBig.copyWith(
                        fontSize: Dimens.fontSize13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.dmSans.copyWith(
                    fontSize: Dimens.fontSizeXSmall,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricInfo {
  final String indicator;
  final String lowRange;
  final String lowDescription;
  final String lowPercentage;
  final String midRange;
  final String midDescription;
  final String midPercentage;
  final String optimalRange;
  final String optimalDescription;
  final String optimalPercentage;

  const _MetricInfo({
    required this.indicator,
    required this.lowRange,
    required this.lowDescription,
    required this.lowPercentage,
    required this.midRange,
    required this.midDescription,
    required this.midPercentage,
    required this.optimalRange,
    required this.optimalDescription,
    required this.optimalPercentage,
  });
}

_MetricInfo _getMetricInfo(HealthMetricType type) {
  switch (type) {
    case HealthMetricType.cardiovascularHealth:
      return const _MetricInfo(
        indicator: 'Resting HR (beats/min)',
        lowRange: '< 5,000 steps',
        lowDescription: 'Heart is overworked',
        lowPercentage: '0%',
        midRange: '5,000–10,000 steps',
        midDescription: 'Moderate improvement',
        midPercentage: '↑ 13%',
        optimalRange: '≥ 10,000 steps',
        optimalDescription: 'Athlete-level efficiency',
        optimalPercentage: '↑ 25%',
      );
    case HealthMetricType.physicalEndurance:
      return const _MetricInfo(
        indicator: 'VO₂ max (ml/kg/min) — Aerobic Capacity',
        lowRange: '< 5,000 steps',
        lowDescription: 'I tire out fast',
        lowPercentage: '0%',
        midRange: '5,000–10,000 steps',
        midDescription: 'Moderate improvement',
        midPercentage: '↑ 15%',
        optimalRange: '≥ 10,000 steps',
        optimalDescription: 'Endurance all day long',
        optimalPercentage: '↑ 30%',
      );
    case HealthMetricType.concentrationFocus:
      return const _MetricInfo(
        indicator: 'Cognitive Function / Working Memory',
        lowRange: '< 6 hours',
        lowDescription: 'Brain fog, can\'t focus',
        lowPercentage: '↓ 25%',
        midRange: '6–7 hours',
        midDescription: 'I function but not at 100%',
        midPercentage: '↓ 15%',
        optimalRange: '≥ 7 hours',
        optimalDescription: 'Clear mind, laser focus',
        optimalPercentage: '100%',
      );
    case HealthMetricType.muscleRegeneration:
      return const _MetricInfo(
        indicator: 'Tissue Repair (%) / Growth Hormone (GH)',
        lowRange: '< 6 hours',
        lowDescription: 'I never recover, always sore',
        lowPercentage: '↓ 35%',
        midRange: '6–7 hours',
        midDescription: 'I recover but slowly',
        midPercentage: '↓ 15%',
        optimalRange: '≥ 7 hours',
        optimalDescription: 'I wake up fresh and new',
        optimalPercentage: '100%',
      );
    case HealthMetricType.goodbyeCramps:
      return const _MetricInfo(
        indicator: 'Frequency of Muscle Cramps',
        lowRange: '< 6 glasses',
        lowDescription: 'Frequent cramps',
        lowPercentage: '0%',
        midRange: '6–9 glasses',
        midDescription: 'Occasional cramp',
        midPercentage: '↓ 40%',
        optimalRange: '≥ 10 glasses',
        optimalDescription: 'No cramps',
        optimalPercentage: '↓ 65%',
      );
    case HealthMetricType.collagenElasticity:
      return const _MetricInfo(
        indicator: 'Skin Hydration (%) / Collagen Fragmentation',
        lowRange: '< 6 glasses',
        lowDescription: 'Dry and dull skin',
        lowPercentage: '0%',
        midRange: '6–9 glasses',
        midDescription: 'Visible improvement',
        midPercentage: '↑ 17%',
        optimalRange: '≥ 10 glasses',
        optimalDescription: 'Radiant skin',
        optimalPercentage: '↑ 32%',
      );
    case HealthMetricType.kidneyHealth:
      return const _MetricInfo(
        indicator: 'Urinary Volume (L/day) / Stone Risk',
        lowRange: '< 6 glasses',
        lowDescription: 'Kidneys under strain',
        lowPercentage: '0%',
        midRange: '6–9 glasses',
        midDescription: 'Moderate protection',
        midPercentage: '↑ 30%',
        optimalRange: '≥ 10 glasses',
        optimalDescription: 'Optimal detox',
        optimalPercentage: '↑ 65%',
      );
  }
}
