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
  const LiquidDetailWidget({super.key});

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
              AppLocalizations.of(context)!.liquids,
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
                      child: const FillVerticalBar(
                        width: 15,
                        fractionToFill: 0.3,
                        barColor: Colors.blue,
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
                          '${2.toString()} L',
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
                          Text(AppLocalizations.of(context)!.water_description, style: const TextStyle(fontSize: Dimens.fontSizeSmall),),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              onPressed: () => Navigator.pushNamed(
                                      context, AddWaterEventScreen.routeName)
                                  .then((_) {
                                /*onReloadData?.call();*/
                              }),
                              icon: const Icon(Icons.add_circle_outline_sharp, size: 30, color: Colors.blue,),
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
