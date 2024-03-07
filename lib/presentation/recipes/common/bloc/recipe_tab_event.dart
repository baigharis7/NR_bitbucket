part of 'recipe_tab_bloc.dart';

// @immutable
abstract class RecipeTabEvent {}

class InitializationRecipeAction extends RecipeTabEvent {}

class RecipeFavoriteRecipeAction extends RecipeTabEvent {
  RecipeMaster itemRecipe;

  RecipeFavoriteRecipeAction({required this.itemRecipe});
}
