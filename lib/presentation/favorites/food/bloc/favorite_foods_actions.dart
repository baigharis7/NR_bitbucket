import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';

class FavoriteFoodsActions {
  FavoriteFoodsActions();
}

class InitializeState extends FavoriteFoodsActions {
  InitializeState();
}

class RemoveFavoriteAction extends FavoriteFoodsActions {
  final FoodFavorite foodFavorite;
  final Function onFinish;

  RemoveFavoriteAction({required this.onFinish, required this.foodFavorite});
}

class HideExplainingCardAction extends FavoriteFoodsActions {
  HideExplainingCardAction();
}