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
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

class FavoritesRepositoryImpl extends FavoritesRepository {
  final LocalStorageRepository localStorageRepository;
  final FavoritesApi favoritesApi;
  final SyncQueueService syncQueue;

  FavoritesRepositoryImpl({
    required this.localStorageRepository,
    required this.favoritesApi,
    required this.syncQueue,
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
    favoritesApi.uploadFoodFavorite(foodFavorite).catchError((error) {
      syncQueue.enqueue('/favorites/food', foodFavorite);
      return <String, dynamic>{};
    });
    return true;
  }

  @override
  Future<bool> deleteFavoriteFoodFromCloud(String userId, int eventId) async {
    favoritesApi.deleteFoodFavorite(userId, eventId).catchError((error) {
      syncQueue.enqueueDelete('/favorites/food', {'userId': userId, 'eventId': eventId});
      return <String, dynamic>{};
    });
    return true;
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
    favoritesApi.uploadSportFavorite(sportFavorite).catchError((error) {
      syncQueue.enqueue('/favorites/sport', sportFavorite);
      return <String, dynamic>{};
    });
    return true;
  }

  @override
  Future<bool> saveSportFavorite(AddSportFavorite addSportFavorite, bool isEdit) async => localStorageRepository.saveSportFavorite(addSportFavorite, isEdit: isEdit);

  @override
  Future<List<AddSportFavorite>> getSportFavorites() async {
    List sportFavorites = await localStorageRepository.getSportFavorites();
    return sportFavorites.map((entity) => mapToSportFavoriteFromEntity(entity as SportFavoriteEntity)).toList();
  }

  @override
  Future<bool> deleteSportFavoriteFromCloud(String userId, int eventId) async {
    favoritesApi.deleteSportFavorite(userId, eventId).catchError((error) {
      syncQueue.enqueueDelete('/favorites/sport', {'userId': userId, 'eventId': eventId});
      return <String, dynamic>{};
    });
    return true;
  }

  @override
  Future<bool> removeSportFavoriteFromLocal(AddSportFavorite sportFavorite) async {
    try {
      await localStorageRepository.removeSportFavorite(sportFavorite);
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<bool> deleteFavoriteLiquidFromCloud(String userId, int eventDate) async {
    favoritesApi.deleteLiquidFavorite(userId, eventDate).catchError((error) {
      syncQueue.enqueueDelete('/favorites/liquid', {'userId': userId, 'eventDate': eventDate});
      return <String, dynamic>{};
    });
    return true;
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
    final uploadLiquidFav = mapToUploadLiquidFavorite(
        liquidFavorite,
        await localStorageRepository.getProfile().then((value) => value!.userId.orEmpty()),
    );
    favoritesApi.uploadLiquidFavorite(uploadLiquidFav).catchError((error) {
      syncQueue.enqueue('/favorites/liquid', uploadLiquidFav);
      return <String, dynamic>{};
    });
    return true;
  }

}