import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recommendations_item.dart';

class RecommendationsFoodGroupCard extends StatefulWidget {
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
  State<RecommendationsFoodGroupCard> createState() => _RecommendationsFoodGroupCardState();
}

class _RecommendationsFoodGroupCardState extends State<RecommendationsFoodGroupCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(Dimens.paddingNormal),
            decoration: BoxDecoration(
              color: _isExpanded ? AppColors.yellowishGreen59 : AppColors.butter59,
              borderRadius: _isExpanded
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(Dimens.border15),
                      topRight: Radius.circular(Dimens.border15),
                    )
                  : BorderRadius.circular(Dimens.border15),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.recommendationsFoodItem.recommendationGroup.translate(context),
                    style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeNormal, color: _isExpanded ? Colors.white : AppColors.yellowishGreen),
                    overflow: TextOverflow.clip,
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down, color: _isExpanded ? Colors.white : AppColors.yellowishGreen, size: 24),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandedContent(),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const SizedBox(height: Dimens.height12),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.floralWhite,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Dimens.border15),
          bottomRight: Radius.circular(Dimens.border15),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingSmall),
      child: Column(
        children: [
          ...widget.recommendationsFoodItem.objFoods.where((f) => f.foodItemMaster.id != null).map((food) {
            final bool isCheckBoxChecked = widget.isChecked.call(food.foodItemMaster.id!);
            return RecommendationsItem(
              foodItemMaster: food.foodItemMaster,
              alternativeUsualHealthyFoods: const [],
              isAlternativeChecked: (id) => null,
              onAlternativeAdd: (recommendationFoodInfo) {},
              onAdd: () => widget.onAdd.call(food.foodItemMaster),
              isChecked: isCheckBoxChecked,
              checkBoxColor: AppColors.peacockBlue,
            );
          }),
          ...widget.recommendationsFoodItem.deficitFoods.where((f) => f.foodItemMaster.id != null).map((food) {
            final bool isCheckBoxChecked = widget.isChecked.call(food.foodItemMaster.id!);
            return RecommendationsItem(
              foodItemMaster: food.foodItemMaster,
              alternativeUsualHealthyFoods: const [],
              isAlternativeChecked: (id) => null,
              onAlternativeAdd: (recommendationFoodInfo) {},
              onAdd: () => widget.onAdd.call(food.foodItemMaster),
              isChecked: isCheckBoxChecked,
              checkBoxColor: AppColors.green,
            );
          }),
          ...(widget.recommendationsFoodItem.usualUnHealthyFoods ?? []).where((f) => f.foodInfo.foodItemMaster.id != null).map((food) {
            final bool isCheckBoxChecked = widget.isChecked.call(food.foodInfo.foodItemMaster.id!);
            return RecommendationsItem(
              foodItemMaster: food.foodInfo.foodItemMaster,
              onAlternativeAdd: (recommendationFoodInfo) => widget.onAdd.call(recommendationFoodInfo?.foodItemMaster),
              onAdd: () => widget.onAdd.call(food.foodInfo.foodItemMaster),
              isChecked: isCheckBoxChecked,
              checkBoxColor: AppColors.yellowishGreen,
              alternativeUsualHealthyFoods: food.alternativeUsualHealthyFoods,
              isAlternativeChecked: (id) => widget.isChecked.call(id),
            );
          }),
          const SizedBox(height: Dimens.paddingSmall),
        ],
      ),
    );
  }
}
