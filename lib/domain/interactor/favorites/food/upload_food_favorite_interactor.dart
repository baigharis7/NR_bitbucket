import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';

abstract class UploadFoodFavoriteInteractor {
  Future<bool> execute(FoodFavorite foodFavorite);
}