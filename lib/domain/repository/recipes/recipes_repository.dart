import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';

abstract class RecipesRepository {
  Future<List<RecipeMaster>> getRecipes(List<int> foodIds, List<int> exclusions);
}