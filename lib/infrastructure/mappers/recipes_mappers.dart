import 'package:nutrenaissance_flutter/data/api/recipes/model/recipes_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/recipes/recipe_favorite_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
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

RecipeFavoriteEntity mapToRecipeFavoriteEntity(
    UploadRecipeFavorite uploadRecipeFavorite) {
  return RecipeFavoriteEntity(
    userId: uploadRecipeFavorite.userId,
    eventDate: uploadRecipeFavorite.eventDate,
    itemRecipe: mapToRecipeMasterEntity(uploadRecipeFavorite.itemRecipe),
  );
}

RecipeMasterEntity mapToRecipeMasterEntity(RecipeMaster itemRecipe) {
  return RecipeMasterEntity(
    id: itemRecipe.id,
    meal: itemRecipe.meal,
    name_es: itemRecipe.name_es,
    name_en: itemRecipe.name_en,
    ingredients: mapToRecipeIngredientsEntity(itemRecipe.ingredients),
    steps_es: mapToRecipeStepsEntity(itemRecipe.steps_es),
    steps_en: mapToRecipeStepsEntity(itemRecipe.steps_en),
    time: itemRecipe.time,
    difficulty: itemRecipe.difficulty,
    servings: itemRecipe.servings,
    source: itemRecipe.source,
    exclusions: itemRecipe.exclusions,
  );
}

List<RecipeIngredientEntity> mapToRecipeIngredientsEntity(List<RecipeIngredient> ingredients) {
  return ingredients.map((ingredient) => RecipeIngredientEntity(id: ingredient.id, qtyGrams: ingredient.qtyGrams, qtyUnit: ingredient.qtyUnit, unit: ingredient.unit)).toList();
}

RecipeStepsEntity mapToRecipeStepsEntity(RecipeSteps? steps) {
  return RecipeStepsEntity(steps: mapToRecipeStepEntity(steps));
}

List<RecipeStepEntity> mapToRecipeStepEntity(RecipeSteps? steps) {
  return steps?.steps.orEmpty().map((step) => RecipeStepEntity(stepTitle: step.stepTitle, subSteps: step.subSteps)).toList() ?? [];
}

UploadRecipeFavorite mapToUploadRecipeFavorite(
    RecipeFavoriteEntity uploadRecipeFavoriteEntity) {
  return UploadRecipeFavorite(
    userId: uploadRecipeFavoriteEntity.userId,
    eventDate: uploadRecipeFavoriteEntity.eventDate,
    itemRecipe: mapToRecipeMaster(uploadRecipeFavoriteEntity.itemRecipe),
  );
}

RecipeMaster mapToRecipeMaster(RecipeMasterEntity itemRecipe) {
  return RecipeMaster(
    id: itemRecipe.id,
    meal: itemRecipe.meal,
    name_es: itemRecipe.name_es,
    name_en: itemRecipe.name_en,
    ingredients: mapToRecipeIngredients(itemRecipe.ingredients),
    steps_es: mapToRecipeSteps(itemRecipe.steps_es),
    steps_en: mapToRecipeSteps(itemRecipe.steps_en),
    time: itemRecipe.time,
    difficulty: itemRecipe.difficulty,
    servings: itemRecipe.servings,
    source: itemRecipe.source,
    exclusions: itemRecipe.exclusions,
  );
}

List<RecipeIngredient> mapToRecipeIngredients(List<RecipeIngredientEntity> ingredients) {
  return ingredients.map((ingredient) => RecipeIngredient(id: ingredient.id, qtyGrams: ingredient.qtyGrams, qtyUnit: ingredient.qtyUnit, unit: ingredient.unit)).toList();
}

RecipeSteps mapToRecipeSteps(RecipeStepsEntity? steps) {
  return RecipeSteps(steps: mapToRecipeStep(steps));
}

List<Step> mapToRecipeStep(RecipeStepsEntity? steps) {
  return steps?.steps.orEmpty().map((step) => Step(stepTitle: step.stepTitle, subSteps: step.subSteps)).toList() ?? [];
}


