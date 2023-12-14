import 'package:flutter/material.dart';

import '../../domain/models/favorites/food/food_favorite.dart';
import '../../infrastructure/utils/dimens.dart';

class FoodEventFoodsCluster extends StatefulWidget {
  final Function(FoodFavorite foodFavorite) onSelect;
  final List<FoodFavorite> foodList;
  final String? selectedFoodName;
  final String clusterName;
  const FoodEventFoodsCluster({super.key, required this.onSelect, required this.foodList, this.selectedFoodName, required this.clusterName});

  @override
  State<FoodEventFoodsCluster> createState() => _FoodEventFoodsClusterState();
}

class _FoodEventFoodsClusterState extends State<FoodEventFoodsCluster> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginSmall),
          child: Text(widget.clusterName, style: const TextStyle(fontWeight: FontWeight.bold),)),
      GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 0,
          crossAxisSpacing: Dimens.marginNormal,
          mainAxisExtent: 55.0,
          childAspectRatio: 3/1,
        ),
        shrinkWrap: true,
        children: [
          ...widget.foodList.map((food) => Card(
            elevation: 3.00,
            shadowColor: Colors.black,
            child: Container(
              decoration: BoxDecoration(
                color: widget.selectedFoodName == food.title ? Colors.amber : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                onTap: () => widget.onSelect.call(food),
                child: Center(
                  child: Text(
                    food.title.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: Dimens.fontSizeSmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    ],);
  }
}