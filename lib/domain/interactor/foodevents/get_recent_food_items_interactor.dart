import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';

abstract class GetRecentFoodItemsInteractor {
  Future<List<FoodFavorite>> execute();
}
