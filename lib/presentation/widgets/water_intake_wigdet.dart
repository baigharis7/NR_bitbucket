import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/dimens.dart';
import 'ani_nutri_progress_bar_widget.dart';

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
  bool _isExpanded = true;
  final double glassVolume = 0.25;

  @override
  Widget build(BuildContext context) {
    int totalGlasses = (widget.totalLitersGoal / glassVolume).ceil();
    double totalConsumedLiters = widget.consumedGlasses * glassVolume;
    double progress = (totalConsumedLiters / widget.totalLitersGoal).clamp(0.0, 1.0);

    return Column(
      children: [
        // Collapsible title bar
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
            padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingSmall),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
            ),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.hydration,
                  style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize20),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isExpanded ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 22),
                ),
                const Spacer(),
                if (!widget.onInfoClick.isNull()) InkWell(
                  onTap: () => widget.onInfoClick?.call(),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: Image.asset('assets/images/info.png'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginNormal),
          padding: const EdgeInsets.all(Dimens.paddingNormal),
          decoration: BoxDecoration(
            color: AppColors.darkJungleGreen,
            border: Border.all(color: Colors.white, width: Dimens.width1),
            borderRadius: BorderRadius.circular(Dimens.border18),
          ),
          child: Column(
            children: [
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
              // Collapsible bottom section (progress bar + data metrics)
              AnimatedCrossFade(
                firstChild: Column(
                  children: [
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
                  ],
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
