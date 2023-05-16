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

class SelectCookingMethodAction extends CreateNewFoodFavoriteActions {
  FoodInFavorite foodInFavorite;

  SelectCookingMethodAction({required this.foodInFavorite});
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