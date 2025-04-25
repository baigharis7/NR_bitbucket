import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/ingested_spent_widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'nutrient_element_widget.dart';

class NutritionProgressWidget extends StatefulWidget {
  final EnergyModel? energyModel;
  final List<NutrientsModel> nutrientsList;
  const NutritionProgressWidget({super.key, required this.energyModel, required this.nutrientsList});

  @override
  _NutritionProgressWidgetState createState() => _NutritionProgressWidgetState();
}

class _NutritionProgressWidgetState extends State<NutritionProgressWidget> {

  @override
  Widget build(BuildContext context) {
    final double remaining = double.parse((widget.energyModel!.totalKcal - widget.energyModel!.rawKcalTaken + widget.energyModel!.spentKcal).toString());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Card(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
        color: AppColors.darkJungleGreen,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginLarge),
                child: Row(
                  children: [
                    IngestedSpentWidget(svg: 'assets/svg/fork_spoon.svg', title: AppLocalizations.of(context)!.kcal_ingested, value: widget.energyModel!.rawKcalTaken.orZero()),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                        child: CircularPercentIndicator(
                          radius: Dimens.border80,
                          animation: true,
                          animationDuration: 5000,
                          lineWidth: Dimens.width18,
                          percent: remaining / widget.energyModel!.totalKcal.orZero(),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${remaining.toInt()}',
                                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(AppLocalizations.of(context)!.kcal_remaining,
                                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
                              Text(AppLocalizations.of(context)!.from + ' ${widget.energyModel!.totalKcal}.',
                                  style: const TextStyle(fontSize: Dimens.fontSizeSmall, color: Colors.white54)),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: AppColors.mountainMeadow,
                          backgroundColor: Colors.white10,
                          curve: Curves.linear,
                        ),
                      ),
                    ),
                    IngestedSpentWidget(svg: 'assets/svg/flame.svg', title: AppLocalizations.of(context)!.spent_kcal_title, value: widget.energyModel!.spentKcal.orZero()),
                  ],
                ),
              ),
              Row(
                children: [
                  ...widget.nutrientsList.map((nutrient) =>
                      Expanded(
                          child: NutrientElementWidget(label: nutrient.nutrientInfoMaster.translate(context), current: nutrient.quantityConsumed, goal: nutrient.rda.toDouble(), unit: nutrient.unit.orEmpty())
                        ,)
                    ,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
