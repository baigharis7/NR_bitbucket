import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/string_utils.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_horizontal_bar.dart';

class WeeklyRDANutrientsDashboardWidget extends StatefulWidget {
  final String title;
  final List<NutrientsModel> nutrients;
  final bool isEmpty;
  final Function screenToMove;

  const WeeklyRDANutrientsDashboardWidget({
    Key? key,
    required this.nutrients,
    required this.title,
    required this.isEmpty,
    required this.screenToMove,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeeklyRDANutrientsDashboardWidgetState();

}

class _WeeklyRDANutrientsDashboardWidgetState extends State<WeeklyRDANutrientsDashboardWidget> {
  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.all(Dimens.marginSmall),
      child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: Dimens.marginLarge,),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeNormal,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: IconButton(onPressed: () { widget.screenToMove.call(); }, icon: const Icon(Icons.arrow_forward_ios, size: 18,)),
                    )
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
                    (nutrient.fractionToFill < 1 && nutrient.unit.orEmpty().isNotEmpty) ?
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
                                    FillHorizontalBar(fillColor: nutrient.fractionToFill >= 1 ? AppColors.errorRed : AppColors.mountainMeadow, backgroundBarColor: AppColors.mountainMeadow, fractionToFill: nutrient.fractionToFill,),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(top: Dimens.marginXSmall),
                                      child: Text(
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
                           )
                         ],
                       )
                        : Container(),
                  ).toList()
                ],
              ),
              Container(
                margin: const EdgeInsets.only(bottom: Dimens.marginSmall,),
              )
            ],
      ),
    );
  }

}