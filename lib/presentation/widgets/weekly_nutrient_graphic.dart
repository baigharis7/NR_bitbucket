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
    return Card(
      color: AppColors.gray,
      elevation: 10,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: Dimens.marginXLarge, vertical: Dimens.marginSmall),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Dimens.fontSizeMedium,
                ),
              ),
            ),
            ...data.where((element) => (element.upperLimit ?? 0.0) > 0).map(
              (nutrientItem) {
                return Column(
                  children: [
                    SizedBox(
                        width: double.infinity,
                        child: Text(nutrientItem.nutrientInfoMaster
                            .translate(context))),
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
                                    Text('${nutrientItem.upperLimit.toString()} ${nutrientItem.nutrientInfoMaster.unit}'),
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
                                        final fractionFill =
                                            dayDataMap['nutrientConsumed']
                                                as double;
                                        color = (fractionFill > 0 &&
                                                fractionFill < 0.3)
                                            ? AppColors.errorRed
                                            : (fractionFill > 0.3 &&
                                                    fractionFill < 0.6)
                                                ? AppColors.daffodil
                                                : AppColors.mountainMeadow;
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: Dimens.marginSmall),
                                          child: SizedBox(
                                            height: 70,
                                            child: FillVerticalBar(
                                                fractionToFill: dayDataMap[
                                                        'nutrientConsumed']
                                                    as double,
                                                barColor: color),
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
        ),
      ),
    );
  }
}
