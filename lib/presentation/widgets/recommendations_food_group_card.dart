import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
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
      color: Colors.blue[100],
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Container(
                //     alignment: Alignment.center,
                //     child: Text(
                //       AppLocalizations.of(context)!.alternatives,
                //     ),
                //   ),
                // ),
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
          ...recommendationsFoodItem.recommendedFoods.map((food) {
            final bool isCheckBoxChecked = isChecked.call(food.foodItemMaster.id);
            return Container(
              color: Colors.white,
              child: RecommendationsItem(
                foodItemMaster: food.foodItemMaster,
                onAlternative: () => {/** TODO: mandar a back el id de la comida*/},
                onAdd: () => onAdd.call(food.foodItemMaster),
                isChecked: isCheckBoxChecked,
              ),
            );
          }).toList(),
          ...recommendationsFoodItem.frequentFoods.map((food) {
            final bool isCheckBoxChecked = isChecked.call(food.foodItemMaster.id);
            return Container(
              color: AppColors.cardGreen_200,
              child: RecommendationsItem(
                foodItemMaster: food.foodItemMaster,
                onAlternative: () => {/** TODO: mandar a back el id de la comida*/},
                onAdd: () => onAdd.call(food.foodItemMaster),
                isChecked: isCheckBoxChecked,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

}