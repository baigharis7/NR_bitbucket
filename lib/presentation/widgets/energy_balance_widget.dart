import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EnergyBalanceWidget extends StatelessWidget {
  final EnergyModel? energyModel;

  const EnergyBalanceWidget({
    Key? key,
    required this.energyModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(Dimens.marginSmall),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: Dimens.marginNormal,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.energy_balance_title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              left: Dimens.marginNormal,
              top: Dimens.marginNormal,
              right: Dimens.marginNormal,
            ),
            child: Stack(
              children: [
                FillHorizontalBar(
                  height: 30,
                  fractionToFill: energyModel?.fractionToFill.toDouble() ?? 0,
                  backgroundBarColor: Colors.teal[100],
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                  child: Text(
                    '${energyModel?.totalKcal ?? 0} kcal',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal, right: Dimens.marginNormal),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.raw_kcal_title),
                Text('${energyModel?.rawKcalTaken ?? 0} kcal')
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: Dimens.marginNormal, top: Dimens.marginNormal, right: Dimens.marginNormal, bottom: Dimens.marginNormal),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.spent_kcal_title),
                Text('${energyModel?.spentKcal ?? 0} kcal')
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}