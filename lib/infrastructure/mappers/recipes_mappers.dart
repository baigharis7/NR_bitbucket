import 'package:nutrenaissance_flutter/data/api/recipes/model/recipes_response.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

List<RecipeMaster> mapToRecipeMasterList(RecipesListResponse recipesListResponse) {
  if (recipesListResponse.isNull() || recipesListResponse.recipes.isNull()) return [];
  return recipesListResponse.recipes!.map((recipeResponse) => RecipeMaster(
      id: recipeResponse.id,
      meal: getMealTimes(recipeResponse.meal),
      name_es: recipeResponse.name_es,
      name_en: recipeResponse.name_en,
      ingredients: _getIngredients(recipeResponse.ingredients),
      steps_es: _getRecipeSteps(recipeResponse.steps_es.orEmpty()),
      steps_en: _getRecipeSteps(recipeResponse.steps_en.orEmpty()),
      time: recipeResponse.time,
      difficulty: recipeResponse.difficulty,
      servings: recipeResponse.servings,
      source: recipeResponse.source,
      exclusions: recipeResponse.exclusions,
  ),).toList();
}

List<int> getMealTimes(String mealTime) => mealTime.split(',').map((string) => int.parse(string)).toList();

List<RecipeIngredient> _getIngredients(String ingredientsCoded) {
  final ingredients = ingredientsCoded.split(',');
  final recipeIngredientsList = ingredients.map((ingredientCoded) {
    final ingredientFields = ingredientCoded.split('|').map((string) {
      try {
        return double.parse(string);
      } catch (error) {
        return 0.0;
      }
    }).toList();
    int unit = -1;
    try {
      if (ingredientFields.length == 4) {
        unit = ingredientFields[3].toInt();
      } else {
        unit = -1;
      }
    } catch (error) {
      rethrow;
    }

    return RecipeIngredient(
      id: ingredientFields[0].toInt(),
      qtyGrams: ingredientFields[1],
      qtyUnit: ingredientFields[2],
      unit: unit,
    );
  });
  return recipeIngredientsList.toList();
}

RecipeSteps _getRecipeSteps(String recipeStepsCoded) {
  final recipeStepsSplit = recipeStepsCoded.split('||');
  List<Step> recipeSteps = recipeStepsSplit.map((recipeStep) {
    final steps = recipeStep.split('|');
    String? title = steps[0].startsWith('#')
        ? steps[0].replaceFirst('#', '')
        : null;
    if (title != null) {
      steps.removeAt(0);
    }
    return Step(
      stepTitle: title,
      subSteps: steps,
    );
  }).toList();

  return RecipeSteps(steps: recipeSteps);

}