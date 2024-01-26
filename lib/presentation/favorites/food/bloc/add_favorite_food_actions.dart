import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';

class AddFavoriteFoodActions {
  AddFavoriteFoodActions();
}

class InitializeStateAction extends AddFavoriteFoodActions {
  InitializeStateAction();
}

class SetFoodsInFavoriteAction extends AddFavoriteFoodActions {
  final FoodEventComplete foodsInFavorite;

  SetFoodsInFavoriteAction({required this.foodsInFavorite});
}

class SetFoodFavoriteToEditAction extends AddFavoriteFoodActions {
  final FoodFavorite foodFavorite;

  SetFoodFavoriteToEditAction({required this.foodFavorite});
}

class AddCommentToFavoriteActions extends AddFavoriteFoodActions {
  final String comment;

  AddCommentToFavoriteActions({required this.comment});
}

class AddFoodNameAction extends AddFavoriteFoodActions {
  String name;

  AddFoodNameAction({required this.name});
}

class AddMealTimeAction extends AddFavoriteFoodActions {
  int mealTime;

  AddMealTimeAction({required this.mealTime});
}


class FinishAddingFavoriteAction extends AddFavoriteFoodActions {
  final Function onFinish;

  FinishAddingFavoriteAction({required this.onFinish});
}

class FinishFoodCommentAction extends AddFavoriteFoodActions {
  final Function onFinish;
  final FoodEventComplete foodEventComplete;

  FinishFoodCommentAction({required this.foodEventComplete, required this.onFinish});
}

class FinishFoodFavoriteCommentAction extends AddFavoriteFoodActions {
  final Function onFinish;
  final FoodFavorite foodFavorite;

  FinishFoodFavoriteCommentAction({required this.foodFavorite, required this.onFinish});
}

class RemoveFavoriteFoodEventAction extends AddFavoriteFoodActions {
  final FoodFavorite? foodFavorite;
  final Function onFinish;

  RemoveFavoriteFoodEventAction({required this.onFinish, required this.foodFavorite});
}