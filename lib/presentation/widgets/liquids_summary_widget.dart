import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/view/add_water_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_vertical_bar.dart';

class LiquidSummaryWidget extends StatelessWidget {
  final double quantityTaken;
  final double? width;
  final double fractionToFill;
  final Function? onReloadData;
  final Function screenToMove;
  final Function? addWaterCall;

  const LiquidSummaryWidget({
    Key? key,
    required this.quantityTaken,
    this.width,
    required this.fractionToFill,
    this.onReloadData,
    this.addWaterCall,
    required this.screenToMove,
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
                  AppLocalizations.of(context)!.water,
                  style: const TextStyle(
                    fontSize: Dimens.fontSizeNormal,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(onPressed: () => screenToMove.call(), icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                )
              ],
            ),
          ),
          InkWell(
            onTap: () => addWaterCall?.call(),
              child: Image.asset('assets/images/water.png', height: 80)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal, horizontal: Dimens.marginXLarge,),
            alignment: Alignment.centerRight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FillHorizontalBar(
                  fractionToFill: fractionToFill,
                  fillColor: Colors.blue,
                  // backgroundBarColor: ,
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                  child: Text(
                    '${quantityTaken.toString()} L',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: Dimens.fontSizeSmall),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
            child: const Text(
              '2 L',
              style: TextStyle(
                fontSize: Dimens.fontSizeSmall,
              ),
            ),
          )
        ],
      ),
    );
  }

}