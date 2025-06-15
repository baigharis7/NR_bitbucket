import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/dash_title_widget.dart';
import '../../infrastructure/utils/dimens.dart';
import 'ani_nutri_progress_bar_widget.dart';

class WaterIntakeWidget extends StatelessWidget {
  final double totalLitersGoal; // e.g. 1.93
  final int consumedGlasses;    // e.g. 5
  final Function? onInfoClick;
  final Function onAddWater;
  final double glassVolume = 0.25; // 250ml per glass

  const WaterIntakeWidget({super.key,
    required this.totalLitersGoal,
    required this.consumedGlasses,
    this.onInfoClick,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    int totalGlasses = (totalLitersGoal / glassVolume).ceil();
    double totalConsumedLiters = consumedGlasses * glassVolume;
    double progress = (totalConsumedLiters / totalLitersGoal).clamp(0.0, 1.0);

    return Column(
      children: [
        DashTitleWidget(title: AppLocalizations.of(context)!.hydration, onInfoClick: onInfoClick.isNull() ? null : () => onInfoClick?.call()),
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
              GridView(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: Dimens.marginNormal,
                  mainAxisExtent: 55.0,
                ),
                shrinkWrap: true,
                children: List.generate(totalGlasses, (index) {
                  bool isFilled = index < consumedGlasses;
                  return InkWell(
                    onTap: () {
                      if (!isFilled) onAddWater.call();
                    },
                    child: Container(
                      width: Dimens.widthSmall,
                      height: Dimens.width55,
                      // margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall),
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
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: List.generate(totalGlasses, (index) {
              //       bool isFilled = index < consumedGlasses;
              //       return InkWell(
              //         onTap: () {
              //           if (!isFilled) onAddWater.call();
              //         },
              //         child: Container(
              //           width: Dimens.widthSmall,
              //           height: Dimens.width55,
              //           // margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall),
              //           decoration: BoxDecoration(
              //             image: DecorationImage(
              //               image: AssetImage(isFilled
              //                   ? 'assets/images/filled_glass.png'
              //                   : 'assets/images/empty_glass.png'),
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //           child: !isFilled
              //               ? const Center(
              //             child: Icon(Icons.add, size: 18, color: Colors.white),
              //           )
              //               : null,
              //         ),
              //       );
              //     }),
              //   ),
              // ),
              // Progress Bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall),
                  child: AnimatedNutrientProgressBarWidget(percent: progress * 100, height: Dimens.heightXXSmall,)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${totalConsumedLiters.toStringAsFixed(2)} l.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Dimens.fontSizeLarge,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.from} ${totalLitersGoal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.liters}.',
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeMedium,
                      color: Colors.white70,
                    ),
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
