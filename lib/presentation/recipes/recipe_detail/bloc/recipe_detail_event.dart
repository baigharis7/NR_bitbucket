part of 'recipe_detail_bloc.dart';

// @immutable
abstract class RecipeDetailEvent {}

class InitializationRecipeDetailEventAction extends RecipeDetailEvent {}

class UpdateDateFromRecipeFavoriteScreen extends RecipeDetailEvent {
  UploadRecipeFavorite uploadRecipeFavorite;

  UpdateDateFromRecipeFavoriteScreen({required this.uploadRecipeFavorite});
}


class UpdateDataFromDiscoverScreenEventAction extends RecipeDetailEvent {
  RecipeMaster recipeMaster;

  UpdateDataFromDiscoverScreenEventAction({required this.recipeMaster});
}
