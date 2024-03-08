import 'package:nutrenaissance_flutter/data/api/recipes/model/recipes_response.dart';
import 'package:nutrenaissance_flutter/data/api/recipes/recipes_api.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/recipes_mappers.dart';

import '../../../domain/models/recipes/upload_recipe_favorite.dart';
import '../../../domain/repository/localstorage/local_storage.dart';

class RecipesRepositoryImpl extends RecipesRepository {
  final RecipesApi recipesApi;
  final LocalStorageRepository localStorageRepository;

  RecipesRepositoryImpl({required this.recipesApi, required this.localStorageRepository});

  @override
  Future<List<RecipeMaster>> getRecipes(List<int> foodIds, List<int> exclusions) async {
    final recipesResponse = await recipesApi.getRecipe(foodIds, exclusions);
    if (recipesResponse.isEmpty) {
      return [];
    } else {
      try {
        final recipesListResponse = RecipesListResponse.fromJson(recipesResponse);
        return mapToRecipeMasterList(recipesListResponse);
      } catch (error) {
        rethrow;
      }
    }
  }

  @override
  Future<void> uploadRecipeFavorite(UploadRecipeFavorite uploadRecipeFavorite) async {
    try {
      await recipesApi.uploadRecipeFavorite(uploadRecipeFavorite);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<UploadRecipeFavorite>> getRecipeFavorites() async {
    try {
      final result = await localStorageRepository.getRecipeFavorites();
      return result.map((recipeFavoriteEntity) => mapToUploadRecipeFavorite(recipeFavoriteEntity)).toList();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> saveRecipeFavorite(UploadRecipeFavorite uploadRecipeFavorite) async {
    try {
      await localStorageRepository.saveRecipeFavorite(mapToRecipeFavoriteEntity(uploadRecipeFavorite));
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> deleteRecipeFavorite(String userId, int eventDate) async {
    try {
      await recipesApi.deleteRecipeFavorite(userId, eventDate);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<void> removeRecipeFavorite(UploadRecipeFavorite uploadRecipeFavorite) async {
    try {
      await localStorageRepository.removeRecipeFavorite(mapToRecipeFavoriteEntity(uploadRecipeFavorite));
    } catch(error) {
      rethrow;
    }
  }

}