import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/health_impact_metric.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class HealthImpactMetricsRow extends StatelessWidget {
  final List<HealthImpactMetric> metrics;
  final void Function(HealthImpactMetric metric)? onMetricTap;

  const HealthImpactMetricsRow({
    super.key,
    required this.metrics,
    this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (int i = 0; i < metrics.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.white24,
              ),
            Expanded(
              child: HealthImpactMarkerWidget(
                metric: metrics[i],
                onTap: onMetricTap != null
                    ? () => onMetricTap!(metrics[i])
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HealthImpactMarkerWidget extends StatelessWidget {
  final HealthImpactMetric metric;
  final VoidCallback? onTap;

  const HealthImpactMarkerWidget({
    super.key,
    required this.metric,
    this.onTap,
  });

  static const _arrowColor = Colors.white;

  /// Returns the arrow direction and color based on metric type and current tier.
  /// Color: green = optimal, orange = mid, red = low, grey = neutral/zero.
  static ({IconData icon, Color color}) _getArrowInfo(HealthImpactMetric m) {
    // Determine tier color
    final tierColor = _getTierColor(m);

    switch (m.type) {
      // Steps, Collagen, Kidney: 0% = grey dash, otherwise up arrow
      case HealthMetricType.cardiovascularHealth:
      case HealthMetricType.physicalEndurance:
      case HealthMetricType.collagenElasticity:
      case HealthMetricType.kidneyHealth:
        if (m.isNeutral || m.percentage == 0) {
          return (icon: Icons.remove, color: AppColors.battleshipGrey);
        }
        return (icon: Icons.arrow_upward, color: tierColor);

      // Sleep: optimal = green up, otherwise down arrow
      case HealthMetricType.concentrationFocus:
      case HealthMetricType.muscleRegeneration:
        if (m.isPositive) {
          return (icon: Icons.arrow_upward, color: AppColors.mountainMeadow);
        }
        return (icon: Icons.arrow_downward, color: tierColor);

      // Cramps: 0% = grey dash, otherwise down arrow (reduction metric)
      case HealthMetricType.goodbyeCramps:
        if (m.isNeutral || m.percentage == 0) {
          return (icon: Icons.remove, color: AppColors.battleshipGrey);
        }
        return (icon: Icons.arrow_downward, color: tierColor);
    }
  }

  /// Returns the tier color: green for optimal, orange for mid, red for low.
  static Color _getTierColor(HealthImpactMetric m) {
    switch (m.type) {
      case HealthMetricType.cardiovascularHealth:
      case HealthMetricType.physicalEndurance:
      case HealthMetricType.goodbyeCramps:
      case HealthMetricType.collagenElasticity:
      case HealthMetricType.kidneyHealth:
        if (m.isNeutral || m.percentage == 0) return AppColors.errorRed;
        const optimalValues = {
          HealthMetricType.cardiovascularHealth: 25.0,
          HealthMetricType.physicalEndurance: 30.0,
          HealthMetricType.goodbyeCramps: 65.0,
          HealthMetricType.collagenElasticity: 32.0,
          HealthMetricType.kidneyHealth: 65.0,
        };
        return m.percentage >= optimalValues[m.type]!
            ? AppColors.mountainMeadow
            : Colors.orange;

      case HealthMetricType.concentrationFocus:
      case HealthMetricType.muscleRegeneration:
        if (m.isPositive) return AppColors.mountainMeadow;
        const midValues = {
          HealthMetricType.concentrationFocus: 15.0,
          HealthMetricType.muscleRegeneration: 15.0,
        };
        return m.percentage <= midValues[m.type]!
            ? Colors.orange
            : AppColors.errorRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final arrow = _getArrowInfo(metric);
    final percentText = '${metric.percentage.round()}%';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              metric.label,
              style: AppTextStyles.merriWeather.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: arrow.color,
                    ),
                    child: Icon(arrow.icon, size: 12, color: _arrowColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    percentText,
                    style: AppTextStyles.radioCanadaBig.copyWith(
                      fontSize: Dimens.fontSize28,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 22, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
