import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_impact_calculator.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/healthmetrics/health_metric_detail_sheet.dart';
import 'ani_nutri_progress_bar_widget.dart';
import 'health_impact_metrics_row.dart';

class SleepingHoursWidget extends StatelessWidget {
  final double hoursSlept;
  final double hoursGoal;
  final VoidCallback? onTap;
  final SexType? sex;

  const SleepingHoursWidget({
    super.key,
    required this.hoursSlept,
    required this.hoursGoal,
    this.onTap,
    this.sex,
  });

  @override
  Widget build(BuildContext context) {
    final progress = hoursGoal > 0
        ? (hoursSlept / hoursGoal).clamp(0.0, 1.0)
        : 0.0;

    final hours = hoursSlept.floor();
    final minutes = ((hoursSlept - hours) * 60).round();
    final display = '$hours:${minutes.toString().padLeft(2, '0')} h.';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
        padding: const EdgeInsets.all(Dimens.paddingNormal),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xBF0F4A2D),
          borderRadius: BorderRadius.circular(Dimens.border18),
          border: Border.all(color: Colors.white, width: 1),
          image: const DecorationImage(
            image: AssetImage('assets/images/sleep_bkg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.65,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/icon/sleep_icon.png', width: 36, height: 36),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.sleeping_hours,
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
                  display,
                  style: AppTextStyles.radioCanadaBig.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: Dimens.fontSizeXLarge,
                  ),
                ),
                const Spacer(),
                Text(
                  '${AppLocalizations.of(context)!.of_target} ${hoursGoal.toStringAsFixed(0)} ${AppLocalizations.of(context)!.hours_last_night}',
                  style: AppTextStyles.radioCanadaBig.copyWith(
                    fontSize: Dimens.fontSize13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            HealthImpactMetricsRow(
              metrics: HealthImpactCalculator.calculateSleepMetrics(hoursSlept, sex),
              onMetricTap: (metric) => HealthMetricDetailSheet.show(context, metric),
            ),
          ],
        ),
      ),
    );
  }
}
