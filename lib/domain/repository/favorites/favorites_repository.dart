import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

abstract class FavoritesRepository {
  Future<List<FoodFavorite>> getFoodFavorites();
  Future<void> saveFoodFavorite(FoodFavorite foodFavorite, bool? isEdit);
  Future<bool> uploadFoodFavorite(FoodFavorite foodFavorite);
  Future<bool> deleteFavoriteFoodFromCloud(String userId, int eventDate);
  Future<bool> removeFoodFavoriteFromLocal(FoodFavorite foodFavorite);
  Future<bool> uploadSportFavorite(AddSportFavorite sportFavorite);
  Future<bool> saveSportFavorite(SportFavorite sportFavorite, bool isEdit);
  Future<List<SportFavorite>> getSportFavorites();
  Future<bool> deleteSportFavoriteFromCloud(String userId, int eventDate);
  Future<bool> removeSportFavoriteFromLocal(SportFavorite sportFavorite, String userId);
  Future<List<LiquidFavorite>> getLiquidFavorites();
  Future<void> saveLiquidFavorite(LiquidFavorite liquidFavorite);
  Future<bool> uploadLiquidFavorite(LiquidFavorite liquidFavorite);
  Future<bool> deleteFavoriteLiquidFromCloud(String userId, int eventDate);
  Future<bool> removeLiquidFavoriteFromLocal(LiquidFavorite liquidFavorite);
}