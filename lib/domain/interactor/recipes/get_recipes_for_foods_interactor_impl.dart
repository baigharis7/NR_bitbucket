import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipes_for_foods_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';

class GetRecipesForFoodsInteractorImpl extends GetRecipesForFoodsInteractor {
  final RecipesRepository recipesRepository;

  GetRecipesForFoodsInteractorImpl({required this.recipesRepository});

  @override
  Future<List<RecipeMaster>> execute(List<int> foodIds, List<int> exclusions) async => await recipesRepository.getRecipes(foodIds, exclusions);

}