import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/dashed_line.dart';

import '../../domain/models/dashboard/nutrients_weekly_model.dart';
import '../../infrastructure/helpers/date_time_helper.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';

class WeeklyItemChart extends StatelessWidget {
  NutrientsWeeklyModel weeklyNutrientItem;

  WeeklyItemChart({super.key, required this.weeklyNutrientItem});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: Dimens.height12,
        ),
        Text(
          weeklyNutrientItem.nutrientInfoMaster.translate(context),
          style: const TextStyle(
              color: AppColors.peacockBlue,
              fontWeight: FontWeight.w700,
              fontSize: Dimens.fontSizeLarge,
              decoration: TextDecoration.underline),
        ),
        const SizedBox(height: Dimens.heightXSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 104,
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 1,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width - 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ...weeklyNutrientItem.weeklyData.map((weekDayItem) {
                              final nutrientConsumed =
                                  weekDayItem['nutrientConsumed'] as double;
                              final nutrientRda = weeklyNutrientItem.rda ?? 0;
                              final nutrientFraction =
                                  nutrientConsumed / nutrientRda;
                              final heightPercent = 104 * nutrientFraction;
                              final upperLimit =
                                  (weeklyNutrientItem.upperLimit ?? 0);
                              final color =
                                  (nutrientConsumed < upperLimit * 0.35 &&
                                          upperLimit > 0)
                                      ? AppColors.red
                                      : (nutrientConsumed > upperLimit * 0.35 &&
                                              nutrientConsumed <
                                                  upperLimit * 0.75 &&
                                              upperLimit > 0)
                                          ? AppColors.mustardYellow
                                          : AppColors.mountainMeadow;
                              return Container(
                                width: 11,
                                height: heightPercent.toDouble(),
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(
                                            Dimens.borderLarge))),
                              );
                            }),
                            // ...DateTimeHelper()
                            //     .getWeekDaysInitialList(context)
                            //     .map(
                            //       (item) => Container(
                            //     width: 11,
                            //     height: 50,
                            //     decoration: const BoxDecoration(color: AppColors.mustardYellow, borderRadius: BorderRadius.vertical(top: Radius.circular(Dimens.borderLarge))),
                            //   ),
                            // ).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 30,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width - 100,
                      height: 1,
                      color: AppColors.greyChateau,
                    ),
                  ),
                  // Positioned(
                  //   bottom: 35,
                  //   child: Container(
                  //     width: MediaQuery.sizeOf(context).width - 100,
                  //     height: 1,
                  //     color: AppColors.greyChateau,
                  //   ),
                  // ),
                  // Positioned(top: 35, child: DashedLine(width: MediaQuery.sizeOf(context).width - 100, color: AppColors.greyChateau, dashWidth: 5, dashSpacing: 5, dashHeight: 2)),
                  // Positioned(bottom: 35, child: DashedLine(width: MediaQuery.sizeOf(context).width - 100, color: AppColors.greyChateau, dashWidth: 5, dashSpacing: 5, dashHeight: 2)),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  color: Colors.black,
                  height: 1,
                  width: MediaQuery.sizeOf(context).width - 100,
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width - 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...DateTimeHelper()
                      .getWeekDaysInitialList(context)
                      .map(
                        (item) => Text(item),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
