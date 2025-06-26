import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';

import '../../domain/models/dashboard/sugar_&_fiber_model.dart';
import '../../infrastructure/utils/dimens.dart';
import '../../infrastructure/utils/string_utils.dart';
import '../waterevent/view/add_water_event_screen.dart';
import 'fill_horizontal_bar.dart';
import 'fill_vertical_bar.dart';

class LiquidDetailWidget extends StatefulWidget {
  final double quantityTaken;
  final double fractionToFill;
  final Function? addWaterCall;
  final Function? removeWaterCall;

  const LiquidDetailWidget({super.key,
    required this.quantityTaken,
    required this.fractionToFill,
    this.addWaterCall,
    this.removeWaterCall,
  });

  @override
  State<LiquidDetailWidget> createState() => _LiquidDetailWidgetState();
}

class _LiquidDetailWidgetState extends State<LiquidDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(Dimens.marginNormal),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(Dimens.marginLarge),
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.ingested_water,
              style: const TextStyle(
                fontSize: Dimens.fontSizeNormal,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: Dimens.margin5XLarge,
            child: Card(
              color: Colors.blue.shade50,
              elevation: 5.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: Dimens.marginNormal,
                        horizontal: Dimens.marginXLarge,
                      ),
                      alignment: Alignment.centerRight,
                      height: 150,
                      child: FillVerticalBar(
                        width: 12,
                        fractionToFill: widget.fractionToFill,
                        barColor: Colors.blue,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.quantityTaken} L',
                          style: const TextStyle(
                            fontSize: Dimens.fontSizeXLarge,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.water,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              onPressed: () => widget.addWaterCall?.call(),
                              icon: const Icon(Icons.add_circle_outline_sharp, size: 30, color: Colors.blue,),
                            ),
                          ),
                          Text(AppLocalizations.of(context)!.water_description, style: const TextStyle(fontSize: Dimens.fontSizeSmall),),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              onPressed: () => widget.removeWaterCall?.call(),
                              icon: const Icon(Icons.remove_circle_outline_sharp, size: 30, color: Colors.blue,),
                            ),
                          ),
                        ],
                      ),),
                ],
              ),
            ),
          ),
          Container(width: double.infinity, margin: const EdgeInsets.all(Dimens.marginXLarge), child: Text(AppLocalizations.of(context)!.minimum_water_required, style: const TextStyle(
            fontSize: Dimens.fontSizeMedium,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),),),
          Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge, vertical: Dimens.marginLarge), child: Text(AppLocalizations.of(context)!.minimum_water_description),),
        ],
      ),
    );
  }
}
