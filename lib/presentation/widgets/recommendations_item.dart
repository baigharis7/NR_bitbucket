import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/square_checkbox.dart';

import '../../domain/models/recommendations/recommendations_food_item.dart';

class RecommendationsItem extends StatefulWidget {
  final FoodItemMaster foodItemMaster;
  final Function(RecommendationFoodInfo? recommendationFoodInfo) onAlternativeAdd;
  final Function onAdd;
  final bool isChecked;
  final bool? isFrequent;
  final List<RecommendationFoodInfo>? alternativeUsualHealthyFoods;
  final bool? Function(int id) isAlternativeChecked;

  const RecommendationsItem({
    Key? key,
    required this.foodItemMaster,
    required this.onAlternativeAdd,
    required this.onAdd,
    required this.isChecked,
    this.isFrequent = false,
    this.alternativeUsualHealthyFoods,
    required this.isAlternativeChecked,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecommendationsItemState();
}

class _RecommendationsItemState extends State<RecommendationsItem> {
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              widget.foodItemMaster.translate(context),
              overflow: TextOverflow.clip,
            ),
          ),
          /*if (widget.alternativeUsualHealthyFoods.orEmpty().isNotEmpty) */Expanded(
                flex: 2,
                child: DropdownButton<RecommendationFoodInfo>(
                  // value: null,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXXLarge),
                  iconEnabledColor: Colors.black,
                  icon: const Icon(Icons.arrow_drop_down),
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                  dropdownColor: AppColors.anti_flash_white,
                  underline: Container(),
                  menuMaxHeight: 200,
                  onChanged: (RecommendationFoodInfo? value) {
                    // setState(() {
                      widget.onAlternativeAdd.call(value);
                    // });
                  },
                  items: widget.alternativeUsualHealthyFoods.orEmpty().map<DropdownMenuItem<RecommendationFoodInfo>>((RecommendationFoodInfo value) {
                    final itemSelected = widget.isAlternativeChecked.call(value.foodItemMaster.id ?? -1) ?? false;
                    return DropdownMenuItem<RecommendationFoodInfo>(
                      value: value,
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal, vertical: Dimens.paddingNormal), width: double.infinity, color: itemSelected ? AppColors.mountainMeadow : Colors.transparent, child: Text(value.foodItemMaster.translate(context), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: itemSelected ? Colors.white : Colors.black),)),
                    );
                  }).toList(),
                ),),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareCheckbox(
                  color: AppColors.mountainMeadow,
                  isChecked: widget.isChecked,
                  onChanged: () => widget.onAdd.call(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
