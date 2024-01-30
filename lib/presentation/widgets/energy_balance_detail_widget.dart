import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

import '../../domain/models/dashboard/energy_model.dart';
import '../../infrastructure/utils/dimens.dart';
import '../../infrastructure/utils/string_utils.dart';
import 'fill_horizontal_bar.dart';

class EnergyBalanceDetailWidget extends StatefulWidget {
  final EnergyModel? energyModel;
  final Widget? weeklyEnergyWidget;
  const EnergyBalanceDetailWidget({super.key, required this.energyModel, required this.weeklyEnergyWidget});

  @override
  State<EnergyBalanceDetailWidget> createState() =>
      _EnergyBalanceDetailWidgetState();
}

class _EnergyBalanceDetailWidgetState extends State<EnergyBalanceDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(Dimens.marginSmall),
      child: Container(
        margin: const EdgeInsets.all(Dimens.marginLarge),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                left: Dimens.marginNormal,
                top: Dimens.marginSmall,
              ),
              child: SizedBox(
                child: Text(
                  AppLocalizations.of(context)!.energy_balance_title,
                  style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimens.heightXSmall,),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Dimens.marginSmall,
                vertical: Dimens.marginXSmall,
              ),
              child: Stack(
                children: [
                  FillHorizontalBar(
                    fillColor: (widget.energyModel?.fractionToFill.orZero() ?? 0) >= 1 ? AppColors.errorRed : AppColors.mountainMeadow,
                    height: 30,
                    backgroundBarColor: AppColors.cardGreen_200,
                    fractionToFill: widget.energyModel?.fractionToFill ?? 0.0,
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                    child: Text(
                      '${(widget.energyModel?.rawKcalTaken ?? 0) - (widget.energyModel?.spentKcal ?? 0)} kcal',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal, right: Dimens.marginNormal,),
              alignment: Alignment.centerRight,
              child: Text('${(widget.energyModel?.totalKcal ?? 0)} kcal'),
            ),
            // const SizedBox(height: Dimens.heightSmall,),
            // Row(
            //   children: [
            //     Expanded(child: Text(AppLocalizations.of(context)!.gross_kcal, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium))),
            //     Text('${widget.energyModel?.rawKcalTaken} Kcal', style: const TextStyle(color: AppColors.mountainMeadow, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium)),
            //   ],
            // ),
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(
                left: Dimens.marginNormal,
                top: Dimens.marginSmall,
              ),
              child: SizedBox(
                child: Text(
                  AppLocalizations.of(context)!.gross_kcal,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimens.heightXSmall,),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: Dimens.marginSmall,
                vertical: Dimens.marginXSmall,
              ),
              child: Stack(
                children: [
                  FillHorizontalBar(
                    height: 30,
                    backgroundBarColor: AppColors.cardGreen_200,
                    fractionToFill: (widget.energyModel!.rawKcalTaken.orZero() / widget.energyModel!.totalKcal) > 1 ? 1.0 : (widget.energyModel!.rawKcalTaken.orZero() / widget.energyModel!.totalKcal),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                    child: Text(
                      '${(widget.energyModel?.rawKcalTaken ?? 0)} kcal',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal, right: Dimens.marginNormal,),
              alignment: Alignment.centerRight,
              child: Text('${(widget.energyModel?.totalKcal ?? 0)} kcal'),
            ),
            const SizedBox(height: Dimens.heightXSmall,),
            Text(AppLocalizations.of(context)!.gross_description,),
            const SizedBox(height: Dimens.heightSmall,),
            Row(
              children: [
                Expanded(child: Text(AppLocalizations.of(context)!.spent_kcal_title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium))),
                Text('${widget.energyModel?.spentKcal} Kcal', style: const TextStyle(color: AppColors.mountainMeadow, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium)),
              ],
            ),
            const SizedBox(height: Dimens.heightXSmall,),
            Container(child: Text(AppLocalizations.of(context)!.spent_Kcal_description),),
            const SizedBox(height: Dimens.heightXSmall,),
            if (!widget.weeklyEnergyWidget.isNull()) widget.weeklyEnergyWidget ?? Container(),
            const SizedBox(height: Dimens.heightSmall,),
            Container(width: double.infinity, child: Text(AppLocalizations.of(context)!.basal_metabolic,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium
                )),),
            const SizedBox(height: Dimens.heightXSmall,),
            Container(child: Text(AppLocalizations.of(context)!.basal_metabolic_description),),
            const SizedBox(height: Dimens.heightSmall,),
            Container(width: double.infinity, child: Text(AppLocalizations.of(context)!.food_induced_thermo,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium
                )),),
            const SizedBox(height: Dimens.heightXSmall,),
            Container(child: Text(AppLocalizations.of(context)!.absorption_expense),),
            const SizedBox(height: Dimens.heightSmall,),
            Container(width: double.infinity, child: Text(AppLocalizations.of(context)!.energy_expenditure,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium
                )),),
            const SizedBox(height: Dimens.heightXSmall,),
            Container(child: Text(AppLocalizations.of(context)!.energy_expenditure_description),),
          ],
        ),
      ),
    );
  }
}
