import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/view/add_water_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_vertical_bar.dart';

class LiquidSummaryWidget extends StatelessWidget {
  final double quantityTaken;
  final double? width;
  final double fractionToFill;
  final Function? onReloadData;

  const LiquidSummaryWidget({
    Key? key,
    required this.quantityTaken,
    this.width,
    required this.fractionToFill,
    this.onReloadData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: Dimens.marginLarge),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.liquids,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeNormal,
                    color: Colors.black,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal, horizontal: Dimens.marginXLarge,),
                  alignment: Alignment.centerRight,
                  height: 100,
                  child: FillVerticalBar(
                    width: width ?? 15,
                    fractionToFill: fractionToFill,
                    barColor: Colors.blue,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${quantityTaken.toString()} L',
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeXLarge,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.water,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          onPressed: () => Navigator.pushNamed(context, AddWaterEventScreen.routeName).then((_) => onReloadData?.call()),
                          icon: const Icon(Icons.add_circle_outline_sharp),),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

}