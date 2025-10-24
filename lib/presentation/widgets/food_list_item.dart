import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                foodName,
                overflow: TextOverflow.clip,
                style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w300, fontSize: Dimens.fontSize13, color: AppColors.yellowishGreen),
              ),
              IconButton(
                onPressed: () => onDelete.call(),
                icon: Image.asset('assets/images/delete_icon.png', height: Dimens.heightXSmall),
              ),
            ],
          ),
          const Divider(
            color: AppColors.yellowishGreen,
            thickness: 1,
          ),
        ],
      ),
    );
  }
  
}