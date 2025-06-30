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
      color: AppColors.floralWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
      margin: const EdgeInsets.all(Dimens.marginSmall),
      child: Container(
        margin: const EdgeInsets.all(Dimens.marginLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimens.height5,),
            if (!widget.weeklyEnergyWidget.isNull()) widget.weeklyEnergyWidget ?? Container(),
            const SizedBox(height: Dimens.heightSmall,),
            Container(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.kcal_ingested, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium))),
            const SizedBox(height: Dimens.height12,),
            Text(AppLocalizations.of(context)!.gross_description,),
            const SizedBox(height: Dimens.heightXSmall,),
            Row(
              children: [
                Expanded(child: Text(AppLocalizations.of(context)!.spent_kcal_title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium))),
                Text('${widget.energyModel?.spentKcal} Kcal', style: const TextStyle(color: AppColors.mountainMeadow, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium)),
              ],
            ),
            const SizedBox(height: Dimens.height12,),
            Text(AppLocalizations.of(context)!.spent_Kcal_description),
            const SizedBox(height: Dimens.heightXSmall,),
            SizedBox(width: double.infinity, child: Text(AppLocalizations.of(context)!.basal_metabolic,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium
                )),),
            const SizedBox(height: Dimens.height12,),
            Text(AppLocalizations.of(context)!.basal_metabolic_description),
            const SizedBox(height: Dimens.heightXSmall,),
            SizedBox(width: double.infinity, child: Text(AppLocalizations.of(context)!.food_induced_thermo,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium
                )),),
            const SizedBox(height: Dimens.height12,),
            Text(AppLocalizations.of(context)!.absorption_expense),
            const SizedBox(height: Dimens.heightXSmall,),
            SizedBox(width: double.infinity, child: Text(AppLocalizations.of(context)!.energy_expenditure,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: Dimens.fontSizeMedium
                )),),
            const SizedBox(height: Dimens.height12,),
            Text(AppLocalizations.of(context)!.energy_expenditure_description),
          ],
        ),
      ),
    );
  }
}
