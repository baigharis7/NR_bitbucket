import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/dash_title_widget.dart';
import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/dimens.dart';
import 'ani_nutri_progress_bar_widget.dart';

class WaterIntakeWidget extends StatelessWidget {
  final double totalLitersGoal; // e.g. 1.93
  final int consumedGlasses;    // e.g. 5
  final Function? onInfoClick;
  final Function onAddWater;
  final Function onRemoveWater;
  final double glassVolume = 0.25; // 250ml per glass

  const WaterIntakeWidget({super.key,
    required this.totalLitersGoal,
    required this.consumedGlasses,
    this.onInfoClick,
    required this.onAddWater,
    required this.onRemoveWater,
  });

  @override
  Widget build(BuildContext context) {
    int totalGlasses = (totalLitersGoal / glassVolume).ceil();
    double totalConsumedLiters = consumedGlasses * glassVolume;
    double progress = (totalConsumedLiters / totalLitersGoal).clamp(0.0, 1.0);

    return Column(
      children: [
        DashTitleWidget(title: AppLocalizations.of(context)!.hydration, onInfoClick: onInfoClick.isNull() ? null : () => onInfoClick?.call(), style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize20)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginNormal),
          padding: const EdgeInsets.all(Dimens.paddingLarge),
          decoration: BoxDecoration(
            color: AppColors.darkJungleGreen,
            border: Border.all(color: Colors.white, width: Dimens.width1),
            borderRadius: BorderRadius.circular(Dimens.border18),
          ),
          child: Column(
            children: [
              Wrap(
                children: List.generate(totalGlasses, (index) {
                  bool isFilled = index < consumedGlasses;
                  return InkWell(
                    onTap: () {
                      if (!isFilled) {
                        onAddWater.call();
                      } else {
                        onRemoveWater.call();
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
              // Progress Bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
                  child: AnimatedNutrientProgressBarWidget(percent: progress * 100, height: Dimens.heightXXSmall,)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${totalConsumedLiters.toStringAsFixed(2)} L.',
                    style: AppTextStyles.radioCanadaBig.copyWith(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeXLarge),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.from} ${totalLitersGoal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.liters}.',
                    style: AppTextStyles.radioCanadaBig.copyWith(fontSize: Dimens.fontSize13, color: Colors.white70),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
