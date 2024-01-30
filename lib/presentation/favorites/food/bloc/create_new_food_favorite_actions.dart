import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';

class CreateNewFoodFavoriteActions {
  CreateNewFoodFavoriteActions();
}

class InitializeStateAction extends CreateNewFoodFavoriteActions {
  InitializeStateAction();
}

class RemoveFoodFromFavoriteAction extends CreateNewFoodFavoriteActions {
  FoodInFavorite foodInFavorite;

  RemoveFoodFromFavoriteAction({required this.foodInFavorite});
}

class AddFoodFromFavoriteAction extends CreateNewFoodFavoriteActions {
  FoodInFavorite foodInFavorite;

  AddFoodFromFavoriteAction({required this.foodInFavorite});
}

class UpdateQuantityAction extends CreateNewFoodFavoriteActions {
  FoodInFavorite foodInFavorite;

  UpdateQuantityAction({required this.foodInFavorite});
}

class UpdateUnitAction extends CreateNewFoodFavoriteActions {
  FoodInFavorite foodInFavorite;

  UpdateUnitAction({required this.foodInFavorite});
}

class UpdateCookingMethodAction extends CreateNewFoodFavoriteActions {
  FoodInFavorite foodInFavorite;

  UpdateCookingMethodAction({required this.foodInFavorite});
}

class AddFoodNameAction extends CreateNewFoodFavoriteActions {
  String name;

  AddFoodNameAction({required this.name});
}

class AddMealTimeAction extends CreateNewFoodFavoriteActions {
  int mealTime;

  AddMealTimeAction({required this.mealTime});
}

class FinishFoodFavoriteAction extends CreateNewFoodFavoriteActions {
  Function onFinish;

  FinishFoodFavoriteAction({required this.onFinish});
}

class AddFavFoodFromFrequent extends CreateNewFoodFavoriteActions {
  final FoodFavorite frequentFood;

  AddFavFoodFromFrequent({required this.frequentFood});
}

class FinishFrequentFoodToAddFavorite extends CreateNewFoodFavoriteActions {
  final Function onFinish;

  FinishFrequentFoodToAddFavorite({required this.onFinish});
}

class SetFavFoodFromFavoriteDetailNavigation extends CreateNewFoodFavoriteActions {
  final FoodFavorite foodFavorite;

  SetFavFoodFromFavoriteDetailNavigation({required this.foodFavorite});
}