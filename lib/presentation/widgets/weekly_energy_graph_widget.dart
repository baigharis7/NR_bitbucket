import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/fill_vertical_bar.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

import '../../domain/models/dashboard/nutrients_weekly_model.dart';

class WeeklyEnergyGraphWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final double averageConsumed;
  final double averageSpent;
  final num total;

  const WeeklyEnergyGraphWidget({
    Key? key,
    required this.data,
    required this.title, required this.averageConsumed, required this.averageSpent, required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.mountainMeadow;
    return Card(
      color: AppColors.floralWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
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
            data.isNotEmpty
                ? Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.gross_average_kcal),
                          Text(averageConsumed.toInt().toString()+'Kcal', style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Dimens.fontSizeMedium,
                          ),),
                        ],
                      ),
                      const SizedBox(height: Dimens.heightXXSmall),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.average_spent_kcal),
                          Text(averageSpent.toInt().toString()+'Kcal', style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Dimens.fontSizeMedium,
                          ),)
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: Dimens.marginLarge,
                            vertical: Dimens.marginXLarge),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 120,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    bottom: Dimens.marginXLarge),
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            Expanded(
                              child: Column(
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
                                        Text('$total Kcal'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 250,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ...data.map((energySummaryItem) =>
                                            Container(
                                              margin: const EdgeInsets.symmetric(
                                                  horizontal: Dimens.marginSmall),
                                              child: SizedBox(
                                                height: 70,
                                                child: FillVerticalBar(
                                                  fractionToFill:
                                                      energySummaryItem['Kcal']
                                                          as double,
                                                  barColor: color,
                                                ),
                                              ),
                                            )),
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal:
                                                            Dimens.marginSmall),
                                                child: Text(item),
                                              ),
                                            )
                                            .toList()
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.symmetric(
                        vertical: Dimens.marginXSmall,
                        horizontal: Dimens.marginLarge),
                    child: Text(AppLocalizations.of(context)!.no_food_events),
                  )
          ],
        ),
      ),
    );
  }
}
