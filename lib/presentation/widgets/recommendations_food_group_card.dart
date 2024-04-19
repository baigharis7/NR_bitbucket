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
    return Card(
      color: AppColors.anti_flash_white,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.symmetric(
                      horizontal: Dimens.marginNormal,
                    ),
                    child: Text(
                      recommendationsFoodItem.recommendationGroup.translate(context),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mountainMeadow),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.alternatives,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.add,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...recommendationsFoodItem.recommendedFoods.take(Constants.RECOMMENDATION_LIST_SIZE).map((food) {
            final bool isCheckBoxChecked = isChecked.call(food.foodItemMaster.id);
            return Container(
              color: Colors.white,
              child: RecommendationsItem(
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
              ),
            );
          }),
          ...recommendationsFoodItem.usualUnHealthyFoods.orEmpty().take(Constants.RECOMMENDATION_LIST_SIZE).map((food) {
            final bool isCheckBoxChecked = isChecked.call(food.foodInfo.foodItemMaster.id);
            return Container(
              color: AppColors.errorRed,
              child: RecommendationsItem(
                foodItemMaster: food.foodInfo.foodItemMaster,
                onAlternativeAdd: (recommendationFoodInfo) => onAdd.call(recommendationFoodInfo?.foodItemMaster),
                onAdd: () => onAdd.call(food.foodInfo.foodItemMaster),
                isChecked: isCheckBoxChecked,
                alternativeUsualHealthyFoods: food.alternativeUsualHealthyFoods,
                isAlternativeChecked: (id) => isChecked.call(id),
              ),
            );
          }),
          ...recommendationsFoodItem.usualHealthyFoods.orEmpty().take(Constants.RECOMMENDATION_LIST_SIZE).map((food) {
            final bool isCheckBoxChecked = isChecked.call(food.foodInfo.foodItemMaster.id);
            return Container(
              color: AppColors.cardGreen_200,
              child: RecommendationsItem(
                foodItemMaster: food.foodInfo.foodItemMaster,
                alternativeUsualHealthyFoods: food.alternativeUsualHealthyFoods,
                onAlternativeAdd: (recommendationFoodInfo) => onAdd.call(recommendationFoodInfo?.foodItemMaster),
                isAlternativeChecked: (id) => isChecked.call(id),
                onAdd: () => onAdd.call(food.foodInfo.foodItemMaster),
                isChecked: isCheckBoxChecked,
              ),
            );
          }),
        ],
      ),
    );
  }

}