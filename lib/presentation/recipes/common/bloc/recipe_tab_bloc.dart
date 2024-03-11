import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipe_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/upload_recipe_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';

import '../../../../data/local/models/masterfiles/master_files_type.dart';
import '../../../../domain/interactor/preferences/get_user_id_interactor.dart';
import '../../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../../domain/interactor/recipes/delete_recipe_favorite_interactor.dart';
import '../../../../domain/interactor/recipes/get_recipes_for_foods_interactor.dart';
import '../../../../domain/interactor/recipes/remove_recipe_favorite_interactor.dart';
import '../../../../domain/interactor/recipes/save_recipe_favorite_interactor.dart';
import '../../../../domain/models/masterfiles/food_names_master.dart';
import '../../../../domain/models/profile/user_profile_model.dart';
import '../../../../domain/models/recipes/recipes_master.dart';

part 'recipe_tab_event.dart';

part 'recipe_tab_state.dart';

class RecipeTabBloc extends Bloc<RecipeTabEvent, RecipeTabState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetProfileInteractor getProfileInteractor;
  final GetRecipesForFoodsInteractor getRecipesForFoodsInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadRecipeFavoriteInteractor uploadRecipeFavoriteInteractor;
  final GetRecipeFavoritesInteractor getRecipeFavoritesInteractor;
  final SaveRecipeFavoriteInteractor saveRecipeFavoriteInteractor;
  final DeleteRecipeFavoriteInteractor deleteRecipeFavoriteInteractor;
  final RemoveRecipeFavoriteInteractor removeRecipeFavoriteInteractor;

  RecipeTabBloc({
    required this.getUserIdInteractor,
    required this.getProfileInteractor,
    required this.getRecipesForFoodsInteractor,
    required this.getMasterFileInteractor,
    required this.uploadRecipeFavoriteInteractor,
    required this.getRecipeFavoritesInteractor,
    required this.saveRecipeFavoriteInteractor,
    required this.deleteRecipeFavoriteInteractor,
    required this.removeRecipeFavoriteInteractor,
  }) : super(RecipeTabState(isLoading: false)) {
    on<InitializationRecipeAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.profile = await getProfileInteractor.execute();
      final foodAndDrinksMasterFile = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames) as FoodsAndDrinksNamesMaster;
      state.foodAndDrinksNames = foodAndDrinksMasterFile.foodsAndDrinksNames!.foodNames?..addAll(foodAndDrinksMasterFile.foodsAndDrinksNames!.drinkNames!.toList());
      state.recipesFavorites = await getRecipeFavoritesInteractor.execute();
      final foodIds = state.profile?.recommededIds.orEmpty() ?? [];
      final exclusions = state.profile?.exclusions?.exclusions.orEmpty() ?? [];
      state.recipes = await getRecipesForFoodsInteractor.execute(foodIds, exclusions);
      emit(state.copyWith(isLoading: false));
    });

    on<RecipeFavoriteRecipeAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      var uploadRecipe = UploadRecipeFavorite(
          userId: getUserIdInteractor.execute(),
          eventDate: DateTime.now().millisecondsSinceEpoch,
          itemRecipe: event.itemRecipe,
      );

      try {
        await uploadRecipeFavoriteInteractor.execute(uploadRecipe);
        try {
          await saveRecipeFavoriteInteractor.execute(uploadRecipe);
          add(InitializationRecipeAction());
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadFoodFavoriteError));
      }

    },);

    on<DeleteRecipeFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await deleteRecipeFavoriteInteractor.execute(event.uploadRecipeFavorite.userId.orEmpty(), event.uploadRecipeFavorite.eventDate.orZero());
        try {
          await removeRecipeFavoriteInteractor.execute(event.uploadRecipeFavorite);
          add(InitializationRecipeAction());
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodFavoriteError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodFavoriteError));
      }
    },);
  }

  bool areRecipesForMealTime(int mealTime) => state.recipes.orEmpty().any((recipe) => recipe.meal.contains(mealTime));

  bool areRecipeFavoritesForMealTime(int mealTime) => state.recipesFavorites.orEmpty().any((recipe) => recipe.itemRecipe.meal.contains(mealTime));

  List<RecipeMaster> getRecipesForMealTime(int mealTime) {
    final recipes = <RecipeMaster>[];
    for (var recipe in state.recipes.orEmpty()) {
      if (recipe.meal.contains(mealTime)) {
        recipes.add(recipe);
      }
    }
    return recipes;
  }

  List<UploadRecipeFavorite> getRecipeFavoritesForMealTime(int mealTime) {
    final recipes = <UploadRecipeFavorite>[];
    for (var recipe in state.recipesFavorites.orEmpty()) {
      if (recipe.itemRecipe.meal.contains(mealTime)) {
        recipes.add(recipe);
      }
    }
    return recipes;
  }

  List<FoodItemMaster> getIngredientsInfo(List<RecipeIngredient> ingredients) {
    List<FoodItemMaster> listOfIngredientInfo = [];

    for (var ingredient in ingredients) {
      final ingredientInfo = getFoodNameByFoodId(ingredient.id);
      if (ingredientInfo.en.orEmpty().isNotEmpty && ingredientInfo.en.orEmpty().isNotEmpty) {
        listOfIngredientInfo.add(ingredientInfo);
      }
    }

    return listOfIngredientInfo;
  }

  FoodItemMaster getFoodNameByFoodId(int foodId) {
    return state.foodAndDrinksNames.orEmpty().firstWhere((foodItemMaster) => foodItemMaster.id == foodId, orElse: () => FoodItemMaster.empty());
  }
}
