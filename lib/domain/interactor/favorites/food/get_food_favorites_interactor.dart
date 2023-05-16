import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';

abstract class GetFoodFavoritesInteractor {
  Future<List<FoodFavorite>> execute();
}