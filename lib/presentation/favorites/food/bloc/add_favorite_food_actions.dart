import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';

class AddFavoriteFoodActions {
  AddFavoriteFoodActions();
}

class InitializeStateAction extends AddFavoriteFoodActions {
  InitializeStateAction();
}

class SetFoodsInFavoriteAction extends AddFavoriteFoodActions {
  final List<FoodInFavorite> foodsInFavorite;

  SetFoodsInFavoriteAction({required this.foodsInFavorite});
}

class SetFoodFavoriteToEditAction extends AddFavoriteFoodActions {
  final FoodFavorite foodFavorite;

  SetFoodFavoriteToEditAction({required this.foodFavorite});
}

class AddCommentToFavoriteActions extends AddFavoriteFoodActions {
  final String comment;
  final Function onFinish;

  AddCommentToFavoriteActions({required this.comment, required this.onFinish});
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