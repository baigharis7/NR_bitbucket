import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../domain/models/dashboard/nutrients_model.dart';
import '../../infrastructure/utils/string_utils.dart';

class VerticalNutrientWidget extends StatelessWidget {
  final NutrientsModel nutrient;
  const VerticalNutrientWidget({super.key, required this.nutrient});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall),
      height: Dimens.heightMedium,
      width: Dimens.width60,
      child: Column(
        children: [
          Text('${nutrient.rda} ${nutrient.unit}', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.peacockBlue, fontSize: Dimens.fontSizeXSmall, fontWeight: FontWeight.w600)),
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.margin6),
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 31,
                      height: 84,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: AppColors.black,
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: nutrient.quantityConsumed),
                      duration: const Duration(seconds: 5),
                      builder: (context, value, child) {
                        return Container(
                          width: 31,
                          height: (nutrient.quantityConsumed / nutrient.rda) * 150,
                          // alignment: Alignment.bottomCenter,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.algaeGreen, AppColors.mediumGreen], begin: Alignment.bottomCenter, end: Alignment.topCenter,),
                            // gradient: LinearGradient(colors: [AppColors.rose, AppColors.persianRed], begin: Alignment.bottomCenter, end: Alignment.topCenter,),
                            // color: AppColors.peacockBlue,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(nutrient.quantityConsumed)}',
                      style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeXSmall, fontWeight: FontWeight.w600),
                    ),
                    // Text(
                    //   '${nutrient.unit}',
                    //   style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSize5, fontWeight: FontWeight.w600),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          Text(getNutrientName(nutrient.nutrientInfoMaster.translate(context)).toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.peacockBlue, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.solid, decorationThickness: 2,)),
        ],
      ),
    );
  }

}