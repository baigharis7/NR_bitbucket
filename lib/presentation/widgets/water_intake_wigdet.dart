import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_impact_calculator.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/healthmetrics/health_metric_detail_sheet.dart';
import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/dimens.dart';
import 'ani_nutri_progress_bar_widget.dart';
import 'health_impact_metrics_row.dart';

class WaterIntakeWidget extends StatefulWidget {
  final double totalLitersGoal;
  final int consumedGlasses;
  final Function? onInfoClick;
  final Function onAddWater;
  final Function onRemoveWater;

  const WaterIntakeWidget({super.key,
    required this.totalLitersGoal,
    required this.consumedGlasses,
    this.onInfoClick,
    required this.onAddWater,
    required this.onRemoveWater,
  });

  @override
  State<WaterIntakeWidget> createState() => _WaterIntakeWidgetState();
}

class _WaterIntakeWidgetState extends State<WaterIntakeWidget> {
  final double glassVolume = 0.25;

  @override
  Widget build(BuildContext context) {
    final int recommendedGlasses = (widget.totalLitersGoal / glassVolume).ceil();
    // Always show one extra empty glass once the user reaches/exceeds the
    // personalised recommendation, so they can keep logging consumption past it.
    final int totalGlasses = widget.consumedGlasses >= recommendedGlasses
        ? widget.consumedGlasses + 1
        : recommendedGlasses;
    double totalConsumedLiters = widget.consumedGlasses * glassVolume;
    double progress = (totalConsumedLiters / widget.totalLitersGoal).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
      padding: const EdgeInsets.all(Dimens.paddingNormal),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xBF0F4A2D),
        border: Border.all(color: Colors.white, width: Dimens.width1),
        borderRadius: BorderRadius.circular(Dimens.border18),
        image: const DecorationImage(
          image: AssetImage('assets/images/hydration_bkg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      child: Column(
        children: [
          // Title row. Previously had a chevron + tap-to-toggle, but the
          // toggled flag was never read — every section below stayed visible
          // either way — so the dropdown was decorative and confusing.
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.hydration,
                style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          // Glasses - always visible
          Wrap(
            runSpacing: 8,
            children: List.generate(totalGlasses, (index) {
              bool isFilled = index < widget.consumedGlasses;
              return InkWell(
                onTap: () {
                  if (!isFilled) {
                    widget.onAddWater.call();
                  } else {
                    widget.onRemoveWater.call();
                  }
                },
                child: Container(
                  width: Dimens.widthSmall,
                  height: Dimens.width55,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(isFilled
                          ? 'assets/images/filled_glass.png'
                          : 'assets/images/empty_glass.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: !isFilled
                      ? const Center(
                    child: Icon(Icons.add, size: 18, color: Colors.white),
                  )
                      : null,
                ),
              );
            }),
          ),
          // Progress bar + data metrics - always visible
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
            child: AnimatedNutrientProgressBarWidget(percent: progress * 100, height: Dimens.heightXXSmall,),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalConsumedLiters.toStringAsFixed(2)} L.',
                style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeXLarge),
              ),
              Text(
                '${AppLocalizations.of(context)!.from} ${widget.totalLitersGoal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.liters}.',
                style: AppTextStyles.radioCanadaBig.copyWith(fontSize: Dimens.fontSize13, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          HealthImpactMetricsRow(
            metrics: HealthImpactCalculator.calculateHydrationMetrics(widget.consumedGlasses, AppLocalizations.of(context)!),
            onMetricTap: (metric) => HealthMetricDetailSheet.show(context, metric),
          ),
        ],
      ),
    );
  }
}
