part of 'recipe_tab_bloc.dart';

// @immutable
// abstract class RecipeTabState {}

class RecipeTabState {
  bool isLoading;
  ErrorTypes? onError;
  UserProfileModel? profile;
  List<FoodItemMaster>? foodAndDrinksNames;
  List<RecipeMaster>? recipes;
  List<UploadRecipeFavorite>? recipesFavorites;

  RecipeTabState({
    required this.isLoading,
    this.onError,
    this.profile,
    this.foodAndDrinksNames,
    this.recipes,
    this.recipesFavorites,
  });

  RecipeTabState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    UserProfileModel? profile,
    List<FoodItemMaster>? foodAndDrinksNames,
    List<RecipeMaster>? recipes,
    List<UploadRecipeFavorite>? recipesFavorites,
  }) {
    return RecipeTabState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      profile: profile ?? this.profile,
      foodAndDrinksNames: foodAndDrinksNames ?? this.foodAndDrinksNames,
      recipes: recipes ?? this.recipes,
      recipesFavorites: recipesFavorites ?? this.recipesFavorites,
    );
  }
}
