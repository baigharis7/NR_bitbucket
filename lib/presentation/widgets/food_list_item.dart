import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class FoodListItem extends StatelessWidget {
  final String foodName;
  final Function onDelete;
  
  const FoodListItem({
    Key? key,
    required this.foodName,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
      padding: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
      decoration: BoxDecoration(
        color: AppColors.floralWhite,
        borderRadius: BorderRadius.circular(Dimens.border11),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            foodName,
            overflow: TextOverflow.clip,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSizeNormal, color: AppColors.yellowishGreen),
          ),
          IconButton(
            onPressed: () => onDelete.call(),
            icon: const Icon(Icons.delete, color: AppColors.yellowishGreen),
          ),
        ],
      ),
    );
  }
  
}