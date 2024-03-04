import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class RecipeIngredientItem extends StatelessWidget {
  final String foodName;
  final String imageSource;
  final String qty;

  const RecipeIngredientItem({
    Key? key,
    required this.foodName,
    required this.imageSource,
    required this.qty,
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
              Image.asset(imageSource, height: 38),
              const SizedBox(width: Dimens.widthXXXXSmall,),
              Expanded(
                child: Text(
                  foodName,
                  overflow: TextOverflow.clip,
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