import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class RecipesState {
  bool isLoading;
  ErrorTypes? onError;
  List<RecipeMaster>? recipesList;
  List<RecipeMaster>? recipesListAll;
  List<int>? foodIds;
  List<int>? exclusions;
  FoodsAndDrinksNamesMaster? foodNames;
  bool? showCard;

  RecipesState({
    required this.isLoading,
    required this.onError,
    this.recipesList,
    this.recipesListAll,
    this.foodIds,
    this.exclusions,
    this.foodNames,
    this.showCard,
  });

  RecipesState copyWith({
    required bool isLoading,
    required ErrorTypes? onError,
    List<RecipeMaster>? recipesList,
    List<RecipeMaster>? recipesListAll,
    List<int>? foodIds,
    List<int>? exclusions,
    FoodsAndDrinksNamesMaster? foodNames,
    bool? showCard,
  }) {
    return RecipesState(
      isLoading: isLoading,
      onError: onError,
      recipesList: recipesList ?? this.recipesList,
      recipesListAll: recipesListAll ?? this.recipesListAll,
      foodIds: foodIds ?? this.foodIds,
      exclusions: exclusions ?? this.exclusions,
      foodNames: foodNames ?? this.foodNames,
      showCard: showCard ?? this.showCard,
    );
  }

}