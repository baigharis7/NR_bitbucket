import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_exclusions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipes_for_foods_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/recipes_helper.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/recipes/bloc/recipes_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/recipes/bloc/recipes_state.dart';

class RecipesBloc extends BaseBloc<RecipesActions, RecipesState> {
  final GetRecipesForFoodsInteractor getRecipesForFoodsInteractor;
  final GetUserExclusionsInteractor getUserExclusionsInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;

  RecipesBloc({
    required this.getRecipesForFoodsInteractor,
    required this.getUserExclusionsInteractor,
    required this.getMasterFileInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
  }) : super(RecipesState(
    isLoading: false,
    onError: null,
    recipesList: [],
    recipesListAll: [],
    exclusions: [],
    foodIds: [],
    foodNames: FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(foodNames: [], drinkNames: [])),
    showCard: false,
  ),) {
    on<InitializeStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null,));
      state.exclusions = await getUserExclusionsInteractor.execute();
      state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.showCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.recipes.index);

      emit(state.copyWith(isLoading: true, onError: null,));
    });

    on<SetFoodIdsAndGetRecipesAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null,));
      state.foodIds = event.foodIds;
      final recipesList = await getRecipesForFoodsInteractor.execute(state.foodIds!, state.exclusions!);
      state.recipesList = recipesList;
      state.recipesListAll!.addAll(state.recipesList!);
      emit(state.copyWith(isLoading: false, onError: null,));
    });

    on<FilterRecipesListByIngredientAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null,));
      final recipesSubList = [];
      for (var recipe in state.recipesList!) {
        final foodId = RecipesHelper().findFoodIdByFoodName(event.foodName, event.currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
        if (foodId != null) {
          for (var ingredient in recipe.ingredients) {

          }
        } else {
          // emit(state.copyWith(isLoading: false));
        }
      }
    });

    on<RestoreRecipesListAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null,));
    });

    on<HideExplainingCardAction>((event, emit) {
      state.showCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.recipes.index);

      emit(state.copyWith(isLoading: false, onError: null,));
    });

    on<EmptyRecommendationAction>((event, emit) {

    });
  }

  List<RecipeMaster> getRecipesForMealTime(int mealTime) {
    final recipes = <RecipeMaster>[];
    for (var recipe in state.recipesList!) {
      if (recipe.meal.contains(mealTime)) {
        recipes.add(recipe);
      }
    }
    return recipes;
  }

  bool areRecipesForMealTime(int mealTime) => state.recipesList!.any((recipe) => recipe.meal.contains(mealTime));

  List<List<String>> getIngredientsNames(List<RecipeMaster> recipeMasterList, List<int> foodIds, BuildContext context) {
    final ingredientsList = recipeMasterList.map((recipe) => recipe.ingredients).toList();
    final List<List<String>> ingredientsTranslated = [];
    for (var ingredients in ingredientsList) {
      final List<String> ingredientsNames = [];
      for (var ingredient in ingredients) {
        if (foodIds.contains(ingredient.id)) {
          final name = getFoodNameByFoodId(ingredient.id, context).orEmpty();
          if (!ingredientsNames.contains(name)) ingredientsNames.add(name);
        }
      }
      ingredientsTranslated.add([...ingredientsNames]);
    }
    return ingredientsTranslated;
  }

  String? getFoodNameByFoodId(int foodId, BuildContext context) {
    return state.foodNames!.foodsAndDrinksNames!.foodNames!.firstWhere((foodItemMaster) => foodItemMaster.id == foodId, orElse: () => FoodItemMaster.empty()).translate(context);
  }

}