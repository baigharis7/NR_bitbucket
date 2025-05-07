import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/string_utils.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';

class NutrientsDashboardWidget extends StatefulWidget {
  final String title;
  final List<NutrientsModel> nutrients;
  final bool isEmpty;
  final Function? screenToMove;

  const NutrientsDashboardWidget({
    Key? key,
    required this.nutrients,
    required this.title,
    required this.isEmpty,
    this.screenToMove,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NutrientsDashboardWidgetState();

}

class _NutrientsDashboardWidgetState extends State<NutrientsDashboardWidget> {
  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.all(Dimens.marginSmall),
      child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginNormal),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeNormal,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.screenToMove != null) Container(
                      alignment: Alignment.centerRight,
                      child: IconButton(onPressed: () { widget.screenToMove?.call(); }, icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                    ),
                  ],
                ),
              ),
              widget.isEmpty
                  ? Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginXSmall, horizontal: Dimens.marginLarge),
                  child: Text(AppLocalizations.of(context)!.no_food_events),
              )
                  : Column(
                children: [
                  ...widget.nutrients.map((nutrient) =>
                    // nutrient.fractionToFill > 0 ?
                    Column(
                         children: [
                           Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.only(
                                    left: Dimens.marginNormal,
                                    top: Dimens.marginSmall,
                                  ),
                                  child: SizedBox(
                                    child: Text(
                                      getNutrientName(nutrient.nutrientInfoMaster.translate(context)),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      right: Dimens.marginLarge,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                    FillHorizontalBar(fillColor: nutrient.fractionToFill >= 1 && nutrient.upperLimit > 0.0 ? AppColors.errorRed : AppColors.mountainMeadow, backgroundBarColor: AppColors.cardGreen_200, fractionToFill: nutrient.fractionToFill,),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall),
                                      child: Text(textAlign: TextAlign.center,
                                        '${(nutrient.quantityConsumed)} ${nutrient.unit}',
                                        style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall),
                                      ),
                                    ),
                                  ],),
                                ),
                              ),
                            ],
                           ),
                           Container(
                             alignment: Alignment.centerRight,
                             margin: const EdgeInsets.only(right: Dimens.marginNormal),
                             child: Text(
                               '${nutrient.upperLimit} ${nutrient.unit}',
                               style: const TextStyle(
                                 fontSize: Dimens.fontSizeSmall,
                               ),
                             ),
                           ),
                         ],
                       )
                        // : Container(),
                  ).toList(),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(bottom: Dimens.marginSmall,),
              ),
            ],
      ),
    );
  }

}