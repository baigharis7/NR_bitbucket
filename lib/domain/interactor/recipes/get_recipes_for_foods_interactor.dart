import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';

abstract class GetRecipesForFoodsInteractor {
  Future<List<RecipeMaster>> execute(List<int> foodIds, List<int> exclusions);
}