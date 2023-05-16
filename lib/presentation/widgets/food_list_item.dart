import 'package:flutter/material.dart';
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 1,
          color: Colors.grey[200],
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                foodName,
                overflow: TextOverflow.clip,
              ),
              IconButton(
                onPressed: () => onDelete.call(),
                icon: const Icon(Icons.delete),
              )
            ],
          ),
        ),
      ],
    );
  }
  
}