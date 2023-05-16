import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';

class FoodListActions {
  FoodListActions();
}

class InitializeStateAction extends FoodListActions {
  InitializeStateAction();
}

class SetFoodIdsActions extends FoodListActions {
  final List<int> foodIds;
  final BuildContext context;

  SetFoodIdsActions({required this.foodIds, required this.context});
}

class OnDeleteFoodIdFromList extends FoodListActions {
  final SimpleItem foodItem;

  OnDeleteFoodIdFromList({required this.foodItem});
}

class HideExplainingCardAction extends FoodListActions {
  HideExplainingCardAction();
}