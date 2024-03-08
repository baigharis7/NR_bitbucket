part of 'recipe_tab_bloc.dart';

// @immutable
abstract class RecipeTabEvent {}

class InitializationRecipeAction extends RecipeTabEvent {}

class RecipeFavoriteRecipeAction extends RecipeTabEvent {
  RecipeMaster itemRecipe;

  RecipeFavoriteRecipeAction({required this.itemRecipe});
}

class DeleteRecipeFavoriteAction extends RecipeTabEvent {
  UploadRecipeFavorite uploadRecipeFavorite;

  DeleteRecipeFavoriteAction({required this.uploadRecipeFavorite});
}
