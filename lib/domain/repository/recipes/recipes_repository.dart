import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';

abstract class RecipesRepository {
  Future<List<RecipeMaster>> getRecipes(List<int> foodIds, List<int> exclusions);
  Future<void> uploadRecipeFavorite(UploadRecipeFavorite uploadRecipeFavorite);
}