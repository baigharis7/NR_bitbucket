import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recommendations_item.dart';

class RecommendationsFoodGroupCard extends StatelessWidget {
  final RecommendationsFoodItem recommendationsFoodItem;
  final Function onAdd;
  final Function isChecked;

  const RecommendationsFoodGroupCard({
    Key? key,
    required this.recommendationsFoodItem,
    required this.onAdd,
    required this.isChecked,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const SizedBox(height: Dimens.height32),
        Container(
          padding: const EdgeInsets.all(Dimens.paddingNormal),
          decoration: BoxDecoration(
            color: AppColors.yellowishGreen,
            borderRadius: BorderRadius.circular(Dimens.border8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  recommendationsFoodItem.recommendationGroup.translate(context),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeSmall, color: Colors.white),
                  overflow: TextOverflow.clip,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.alternatives,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeSmall, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.add,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeSmall, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimens.height12),
        ...recommendationsFoodItem.objFoods.take(Constants.RECOMMENDATION_LIST_SIZE).map((food) {
          final bool isCheckBoxChecked = isChecked.call(food.foodItemMaster.id);
          return RecommendationsItem(
            foodItemMaster: food.foodItemMaster,
            alternativeUsualHealthyFoods: const [],
            isAlternativeChecked: (id) {
              return null;
            },
            onAlternativeAdd: (recommendationFoodInfo) {
              // ToastHelper().showToast(text: recommendationFoodInfo?.foodItemMaster.id.toString() ?? '');
            },
            onAdd: () => onAdd.call(food.foodItemMaster),
            isChecked: isCheckBoxChecked,
            checkBoxColor: AppColors.peacockBlue,
          );
        }),
        const SizedBox(height: Dimens.height12),
        ...recommendationsFoodItem.deficitFoods.take(Constants.RECOMMENDATION_LIST_SIZE).map((food) {
          final bool isCheckBoxChecked = isChecked.call(food.foodItemMaster.id);
          return RecommendationsItem(
            foodItemMaster: food.foodItemMaster,
            alternativeUsualHealthyFoods: const [],
            isAlternativeChecked: (id) {
              return null;
            },
            onAlternativeAdd: (recommendationFoodInfo) {
              // ToastHelper().showToast(text: recommendationFoodInfo?.foodItemMaster.id.toString() ?? '');
            },
            onAdd: () => onAdd.call(food.foodItemMaster),
            isChecked: isCheckBoxChecked,
            checkBoxColor: AppColors.green,
          );
        }),
        const SizedBox(height: Dimens.height12),
        ...recommendationsFoodItem.usualUnHealthyFoods.orEmpty().take(Constants.RECOMMENDATION_LIST_SIZE).map((food) {
          final bool isCheckBoxChecked = isChecked.call(food.foodInfo.foodItemMaster.id);
          return RecommendationsItem(
            foodItemMaster: food.foodInfo.foodItemMaster,
            onAlternativeAdd: (recommendationFoodInfo) => onAdd.call(recommendationFoodInfo?.foodItemMaster),
            onAdd: () => onAdd.call(food.foodInfo.foodItemMaster),
            isChecked: isCheckBoxChecked,
            checkBoxColor: AppColors.yellowishGreen,
            alternativeUsualHealthyFoods: food.alternativeUsualHealthyFoods,
            isAlternativeChecked: (id) => isChecked.call(id),
          );
        }),
        const SizedBox(height: Dimens.height32),
      ],
    );
  }

}