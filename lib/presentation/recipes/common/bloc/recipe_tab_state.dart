part of 'recipe_tab_bloc.dart';

// @immutable
// abstract class RecipeTabState {}

class RecipeTabState {
  bool isLoading;
  ErrorTypes? onError;
  UserProfileModel? profile;
  List<FoodItemMaster>? foodAndDrinksNames;
  List<RecipeMaster>? recipes;

  RecipeTabState({
    required this.isLoading,
    this.onError,
    this.profile,
    this.foodAndDrinksNames,
    this.recipes,
  });

  RecipeTabState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    UserProfileModel? profile,
    List<FoodItemMaster>? foodAndDrinksNames,
    List<RecipeMaster>? recipes,
  }) {
    return RecipeTabState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      profile: profile ?? this.profile,
      foodAndDrinksNames: foodAndDrinksNames ?? this.foodAndDrinksNames,
      recipes: recipes ?? this.recipes,
    );
  }
}
