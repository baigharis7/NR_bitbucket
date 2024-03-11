import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

import '../../domain/models/masterfiles/food_names_master.dart';
import '../../domain/models/recipes/recipes_master.dart';

class RecipeIngredientItem extends StatelessWidget {
  final String name;
  final String? imageSource;
  final String qty;
  final TextStyle? styleText;

  const RecipeIngredientItem({
    Key? key,
    required this.name,
    this.imageSource,
    required this.qty,
    this.styleText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 1,
          color: Colors.grey[200],
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall,),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              imageSource.isNotNull() ? Image.asset(imageSource!, height: 38) : SizedBox(width: 33, height: 33, child: Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal + 2, vertical: Dimens.marginNormal + 2), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.mountainMeadow),)),
              const SizedBox(width: Dimens.widthXXXXSmall,),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.clip, style : styleText,
                ),
              ),
              Expanded(child: Text(qty)),
            ],
          ),
        ),
      ],
    );
  }
  
}