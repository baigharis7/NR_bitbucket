part of 'recipe_detail_bloc.dart';

// @immutable
// abstract class RecipeDetailState {}

class RecipeDetailState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodItemMaster>? foodAndDrinksNames;
  UploadRecipeFavorite? uploadRecipeFavorite;

  RecipeDetailState({
    required this.isLoading,
    this.onError,
    this.foodAndDrinksNames,
    this.uploadRecipeFavorite,
  });

  RecipeDetailState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodItemMaster>? foodAndDrinksNames,
    UploadRecipeFavorite? uploadRecipeFavorite,
  }) {
    return RecipeDetailState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodAndDrinksNames: foodAndDrinksNames ?? this.foodAndDrinksNames,
      uploadRecipeFavorite: uploadRecipeFavorite ?? this.uploadRecipeFavorite,
    );
  }
}
