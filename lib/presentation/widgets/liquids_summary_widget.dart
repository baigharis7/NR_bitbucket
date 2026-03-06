import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/waterevent/view/add_water_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_vertical_bar.dart';

import '../../infrastructure/utils/constants.dart';

class LiquidSummaryWidget extends StatelessWidget {
  final double quantityTaken;
  final double? width;
  final String? totalWater;
  final double fractionToFill;
  final Function? onReloadData;
  final Function screenToMove;
  final Function? addWaterCall;
  final Function? removeWaterCall;

  const LiquidSummaryWidget({
    Key? key,
    required this.quantityTaken,
    this.width,
    this.totalWater,
    required this.fractionToFill,
    this.onReloadData,
    this.addWaterCall,
    this.removeWaterCall,
    required this.screenToMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Card(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginNormal),
        child: Column(
          children: [
            // Container(
            //   margin: const EdgeInsets.only(left: Dimens.marginLarge),
            //   alignment: Alignment.centerLeft,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         AppLocalizations.of(context)!.water,
            //         style: const TextStyle(
            //           fontSize: Dimens.fontSizeNormal,
            //           color: Colors.black,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       Container(
            //         alignment: Alignment.centerRight,
            //         child: IconButton(onPressed: () => screenToMove.call(), icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
            //       )
            //     ],
            //   ),
            // ),
            Row(children: [
              InkWell(onTap: () => removeWaterCall?.call(), child: Image.asset('assets/images/water_minus.png', height: 20)),
              const Spacer(),
              InkWell(onTap: () => addWaterCall?.call(), child: Image.asset('assets/images/water_plus.png', height: 23)),
            ],),
            const Text('${Constants.DEFAULT_ADD_WATER_QUANTITY} L'),
            InkWell(
              onTap: () => screenToMove.call(),
                child: Image.asset(currentLanguage == Constants.LANGUAGE_ES ? 'assets/images/water.png' : 'assets/images/glass.png', height: 65,),),
            Container(
              margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal,),
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
                      '$quantityTaken L',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: Dimens.fontSizeSmall),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
              child: Text(
                '$totalWater L',
                style: const TextStyle(
                  fontSize: Dimens.fontSizeSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}