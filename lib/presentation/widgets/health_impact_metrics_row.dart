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

  @override
  Widget build(BuildContext context) {
    final circleColor = metric.isNeutral
        ? AppColors.battleshipGrey
        : metric.isPositive
            ? AppColors.mountainMeadow
            : AppColors.errorRed;

    final arrowIcon = metric.isNeutral
        ? null
        : metric.isPositive
            ? Icons.arrow_upward
            : Icons.arrow_downward;

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
                  if (arrowIcon != null)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                      ),
                      child: Icon(arrowIcon, size: 12, color: _arrowColor),
                    ),
                  if (metric.isNeutral)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                      ),
                      child: const Icon(Icons.remove, size: 12, color: _arrowColor),
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
