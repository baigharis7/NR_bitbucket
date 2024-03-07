import 'package:nutrenaissance_flutter/data/api/recipes/model/recipes_response.dart';
import 'package:nutrenaissance_flutter/data/api/recipes/recipes_api.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/recipes_mappers.dart';

import '../../../domain/models/recipes/upload_recipe_favorite.dart';

class RecipesRepositoryImpl extends RecipesRepository {
  final RecipesApi recipesApi;

  RecipesRepositoryImpl({required this.recipesApi});

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

}