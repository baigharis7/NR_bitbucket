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
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('${nutrient.rda} ${nutrient.unit}', style: const TextStyle(color: AppColors.peacockBlue)),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall, horizontal: Dimens.marginXLarge),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 70,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                      color: AppColors.peacockBlue.withOpacity(0.2),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: nutrient.quantityConsumed),
                    duration: const Duration(seconds: 5),
                    builder: (context, value, child) {
                      return Container(
                        width: 72,
                        height: (nutrient.quantityConsumed / nutrient.rda) * 200,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.peacockBlue,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                        ),
                        child: value > 0.1
                            ? Text(
                          '${(nutrient.quantityConsumed)} ${nutrient.unit}',
                          style: const TextStyle(color: Colors.white),
                        )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Text(getNutrientName(nutrient.nutrientInfoMaster.translate(context)), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.peacockBlue, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.solid, decorationThickness: 2,)),
        ],
      ),
    );
  }

}