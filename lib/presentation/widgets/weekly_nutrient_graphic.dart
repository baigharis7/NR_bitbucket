import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_vertical_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/models/dashboard/nutrients_weekly_model.dart';

class WeeklyNutrientGraphic extends StatelessWidget {
  final String title;
  final List<NutrientsWeeklyModel> data;

  const WeeklyNutrientGraphic(
      {Key? key, required this.title, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.errorRed;
    return Column(
      children: [
        ...data.map(
          (nutrientItem) {
            return Column(
              children: [
                SizedBox(
                    width: double.infinity,
                    child: Text(nutrientItem.nutrientInfoMaster
                        .translate(context),
                      style: const TextStyle(
                          color: AppColors.peacockBlue, fontWeight: FontWeight.w700, fontSize: Dimens.fontSizeLarge, decoration: TextDecoration.underline
                      ),),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: Dimens.marginLarge,
                      vertical: Dimens.marginLarge),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 120,
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: Dimens.marginXLarge,),
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: 250,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: Dimens.marginNormal),
                                    color: Colors.grey.shade400,
                                    height: 1,
                                  ),
                                ),
                                // Text('${nutrientItem.rda} ${nutrientItem.nutrientInfoMaster.unit}'),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                ...nutrientItem.weeklyData.map(
                                  (dayDataMap) {
                                    final nutrientConsumed =
                                        dayDataMap['nutrientConsumed']
                                            as double;
                                    final upperLimit = (nutrientItem.upperLimit ?? 0);
                                    color = (nutrientConsumed > upperLimit &&
                                        nutrientConsumed < upperLimit * 0.03 && upperLimit > 0)
                                        ? AppColors.red
                                        : (nutrientConsumed > upperLimit * 0.03 &&
                                        nutrientConsumed < upperLimit * 0.06 && upperLimit > 0)
                                            ? AppColors.mustardYellow
                                            : AppColors.mountainMeadow;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: Dimens.marginSmall),
                                      child: SizedBox(
                                        height: 70,
                                        child: FillVerticalBar(
                                            fractionToFill: dayDataMap[
                                                    'nutrientConsumedFraction']
                                                as double,
                                            barColor: color,),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          Container(
                            color: Colors.black,
                            height: 1,
                            width: 250,
                          ),
                          SizedBox(
                            width: 250,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [
                                ...DateTimeHelper()
                                    .getWeekDaysInitialList(context)
                                    .map(
                                      (item) => Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: Dimens.marginSmall),
                                        child: Text(item),
                                      ),
                                    )
                                    .toList()
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ).toList(),
        data.isEmpty
            ? Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.symmetric(
                    vertical: Dimens.marginXSmall,
                    horizontal: Dimens.marginLarge),
                child: Text(AppLocalizations.of(context)!.no_food_events),
              )
            : Container(),
      ],
    );
  }
}
