import 'package:nutrenaissance_flutter/data/api/favorites/favorites_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/food/food_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/liquid/liquid_favorite_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/sport/sport_favorite_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';
import 'package:nutrenaissance_flutter/domain/repository/localstorage/local_storage.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';

class FavoritesRepositoryImpl extends FavoritesRepository {
  final LocalStorageRepository localStorageRepository;
  final FavoritesApi favoritesApi;

  FavoritesRepositoryImpl({
    required this.localStorageRepository,
    required this.favoritesApi,
  });

  @override
  Future<List<FoodFavorite>> getFoodFavorites() async {
    final foodFavorites = await localStorageRepository.getFoodFavorites();
    return foodFavorites.map((entity) => mapToFoodFavoriteFromEntity(entity as FoodFavoriteEntity)).toList();
  }

  @override
  Future<void> saveFoodFavorite(FoodFavorite foodFavorite, bool? isEdit) async {
    await localStorageRepository.saveFoodFavorite(foodFavorite, isEdit: isEdit);
  }

  @override
  Future<bool> uploadFoodFavorite(FoodFavorite foodFavorite) async {
    final uploadFoodFavorite = mapToUploadFoodFavorite(
      foodFavorite,
      await localStorageRepository.getProfile().then((value) => value!.userId.orEmpty()),
    );
    try {
      await favoritesApi.uploadFoodFavorite(uploadFoodFavorite);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteFavoriteFoodFromCloud(String userId, int eventDate) async {
    try {
      await favoritesApi.deleteFoodFavorite(userId, eventDate);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> removeFoodFavoriteFromLocal(FoodFavorite foodFavorite) async {
    try {
      await localStorageRepository.removeFoodFavorite(foodFavorite);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> uploadSportFavorite(AddSportFavorite sportFavorite) async {
    try {
      await favoritesApi.uploadSportFavorite(sportFavorite);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> saveSportFavorite(SportFavorite sportFavorite, bool isEdit) async => localStorageRepository.saveSportFavorite(sportFavorite, isEdit: isEdit);

  @override
  Future<List<SportFavorite>> getSportFavorites() async {
    List sportFavorites = await localStorageRepository.getSportFavorites();
    return sportFavorites.map((entity) => mapToSportFavoriteFromEntity(entity as SportFavoriteEntity)).toList();
  }

  @override
  Future<bool> deleteSportFavoriteFromCloud(String userId, int eventDate) async {
    try {
      await favoritesApi.deleteSportFavorite(userId, eventDate);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> removeSportFavoriteFromLocal(SportFavorite sportFavorite, String userId) async {
    try {
      await localStorageRepository.removeSportFavorite(sportFavorite, userId);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> deleteFavoriteLiquidFromCloud(String userId, int eventDate) async {
    try {
      await favoritesApi.deleteFoodFavorite(userId, eventDate);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<List<LiquidFavorite>> getLiquidFavorites() async {
    final liquidFavorites = await localStorageRepository.getLiquidFavorites();
    return liquidFavorites.map((entity) => mapToLiquidFavoriteFromEntity(entity as LiquidFavoriteEntity)).toList();
  }

  @override
  Future<bool> removeLiquidFavoriteFromLocal(liquidFavorite) async {
    try {
      await localStorageRepository.removeLiquidFavorite(liquidFavorite);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<void> saveLiquidFavorite(liquidFavorite) async => await localStorageRepository.saveLiquidFavorite(liquidFavorite);

  @override
  Future<bool> uploadLiquidFavorite(liquidFavorite) async {
    final uploadLiquidFavorite = mapToUploadLiquidFavorite(
        liquidFavorite,
        await localStorageRepository.getProfile().then((value) => value!.userId.orEmpty()),
    );
    try {
    await favoritesApi.uploadLiquidFavorite(uploadLiquidFavorite);
    return true;
    } catch (_) {
    return false;
    }
  }

}