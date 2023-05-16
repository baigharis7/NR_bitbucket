import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';

abstract class RemoveFoodFavoriteFromLocalInteractor {
  Future<bool> execute(FoodFavorite foodFavorite);
}