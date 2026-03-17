import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_impact_calculator.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/healthmetrics/health_metric_detail_sheet.dart';
import 'ani_nutri_progress_bar_widget.dart';
import 'health_impact_metrics_row.dart';

class StepsWidget extends StatelessWidget {
  final int stepsTaken;
  final int stepsGoal;
  final VoidCallback? onTap;

  const StepsWidget({
    super.key,
    required this.stepsTaken,
    required this.stepsGoal,
    this.onTap,
  });

  String _formatNumber(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final progress = stepsGoal > 0
        ? (stepsTaken / stepsGoal).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
        padding: const EdgeInsets.all(Dimens.paddingNormal),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF6F0507),
          borderRadius: BorderRadius.circular(Dimens.border18),
          border: Border.all(color: Colors.white, width: 1),
          image: const DecorationImage(
            image: AssetImage('assets/images/steps_bkg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.50,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/icon/steps_icon.png', width: 36, height: 36),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.steps,
                  style: AppTextStyles.merriWeather.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: Dimens.fontSize20,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.monitor_heart, size: 30, color: Colors.white),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedNutrientProgressBarWidget(
              percent: progress * 100,
              height: Dimens.heightXXSmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _formatNumber(stepsTaken),
                  style: AppTextStyles.radioCanadaBig.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: Dimens.fontSizeXLarge,
                  ),
                ),
                const Spacer(),
                Text(
                  '${AppLocalizations.of(context)!.of_target} ${_formatNumber(stepsGoal)} ${AppLocalizations.of(context)!.steps_for_today}',
                  style: AppTextStyles.radioCanadaBig.copyWith(
                    fontSize: Dimens.fontSize13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            HealthImpactMetricsRow(
              metrics: HealthImpactCalculator.calculateStepsMetrics(stepsTaken),
              onMetricTap: (metric) => HealthMetricDetailSheet.show(context, metric),
            ),
          ],
        ),
      ),
    );
  }
}
