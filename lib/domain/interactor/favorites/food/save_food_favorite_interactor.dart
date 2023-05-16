import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';

abstract class SaveFoodFavoriteInteractor {
  Future<void> execute(FoodFavorite foodFavorite, bool isEdit);
}