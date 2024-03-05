import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_exclusions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipes_for_foods_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/recipes_helper.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';

class RecommendationsGeneralBloc extends Bloc<RecommendationsGeneralActions, RecommendationsGeneralState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetRecommendationInteractor getRecommendationInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;
  final GetRecipesForFoodsInteractor getRecipesForFoodsInteractor;
  final GetUserExclusionsInteractor getUserExclusionsInteractor;

  RecommendationsGeneralBloc({
    required this.getRecommendationInteractor,
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
    required this.getRecipesForFoodsInteractor,
    required this.getUserExclusionsInteractor,
  }) : super(RecommendationsGeneralState(
    isLoading: false,
    onError: null,
    recommendationFoodsItems: [],
    showRecommendationCard: false,
    showFoodListCard: false,
    showRecipesCard: false,
    foodItems: [],
    recipesList: [],
    recipesListAll: [],
    exclusions: [],
    foodAndDrinksNames: [],
    // foodIds: [],
    recommendationGroups: RecommendationGroupsMaster(recommendationGroups: []),
    recommendation: Recommendation(foodList: [], userNutrients: []),
    needToSearchRecipes: true,
  ),) {
    on<InitialStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.recommendationGroups!.recommendationGroups.isEmpty) state.recommendationGroups = await getMasterFileInteractor.execute(MasterFilesType.recommendationGroups);
      if (state.foodAndDrinksNames!.isEmpty) {
        final foodAndDrinksMasterFile = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames) as FoodsAndDrinksNamesMaster;
        state.foodAndDrinksNames = foodAndDrinksMasterFile.foodsAndDrinksNames!.foodNames?..addAll(foodAndDrinksMasterFile.foodsAndDrinksNames!.drinkNames!.toList());
      }
      if (state.exclusions!.isEmpty) state.exclusions = await getUserExclusionsInteractor.execute();

      if (state.recommendationFoodsItems!.isEmpty) {
        try {
          final recommendation = await getRecommendationInteractor.execute(getUserIdInteractor.execute(),);
          state.recommendation = recommendation;
          state.recommendationFoodsItems = [];
          state.recommendationFoodsItems = state.recommendation!.foodList
              .map((groupRecommendation) =>
              RecommendationsFoodItem(
                recommendationGroup: findRecommendationGroup(groupRecommendation.recGroup,),
                recommendedFoods: getRecommendationFoodInfo(groupRecommendation.foods,),
                frequentFoods: getRecommendationFoodInfo([]),
                // usualHealthyFoods: getRecommendationOfUsualFoods(groupRecommendation.usualFoods.usualHealthyFoods.orEmpty()),
                // usualUnHealthyFoods: getRecommendationOfUsualFoods(groupRecommendation.usualFoods.usualUnhealthyFoods.orEmpty()),
              ),).toList();
          state.showRecommendationCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.recommendations.index);
          state.showRecipesCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.recipes.index);
          state.showFoodListCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.foodList.index);

          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          state.recommendation = null;
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.recommendationError));
        }
      } else {
        emit(state.copyWith(isLoading: false, onError: null));
      }
    });

    on<EmptyRecommendationAction>((event, emit) {
      emit(state.copyWith(isLoading: false, onError: null, recommendationFoodsItems: []));
    });

    on<ManageFoodToListAction>((event, emit) {
      state.foodItems!.map((simpleItem) => simpleItem.id).toList().contains(event.foodItem.id)
          ? state.foodItems!.removeWhere((simpleItem) => simpleItem.id == event.foodItem.id)
          : state.foodItems!.add(event.foodItem);

      state.needToSearchRecipes = true;
      emit(state.copyWith(isLoading: false, onError: null,));
    });

    on<HideRecommendationsExplainingCardAction>((event, emit) {
      state.showRecommendationCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.recommendations.index);

      emit(state.copyWith(isLoading: false, onError: null,));
    });

    on<OnDeleteFoodIdFromList>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      state.foodItems!.remove(event.foodItem);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<HideFoodListExplainingCardAction>((event, emit) {
      state.showFoodListCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.foodList.index);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SetFoodIdsAndGetRecipesAction>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null,));

      if (state.needToSearchRecipes == true) {
        final recipesList = await getRecipesForFoodsInteractor.execute(
            state.foodItems!.map((item) => item.id).toList(),
            state.exclusions!,
        );
        state.recipesList = recipesList;
        state.recipesListAll!.addAll(state.recipesList!);

        state.needToSearchRecipes = false;
        emit(state.copyWith(isLoading: false, onError: null,));
      } else {
        emit(state.copyWith(isLoading: false, onError: null,));
      }
    });

    on<FilterRecipesListByIngredientAction>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null,));
      final recipesSubList = [];
      for (var recipe in state.recipesList!) {
        final foodId = RecipesHelper().findFoodIdByFoodName(event.foodName, event.currentLanguage, state.foodAndDrinksNames!);
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

    on<HideRecipeExplainingCardAction>((event, emit) {
      state.showRecipesCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.recipes.index);

      emit(state.copyWith(isLoading: false, onError: null,));
    });
  }

  RecommendationGroup findRecommendationGroup(int groupId) {
    return state.recommendationGroups!.recommendationGroups.firstWhere((recommendationGroup) => recommendationGroup.id == groupId);
  }

  FoodItemMaster findFood(int foodId) {
    return state.foodAndDrinksNames!.firstWhere((food) => food.id == foodId, orElse: () => FoodItemMaster());
  }

  List<RecommendationFoodInfo> getRecommendationFoodInfo(List<int> foodList) {
    // List<RecommendationFoodInfo> list = [];
    // for (int foodId in foodList) {
    //   FoodItemMaster foodItemMaster = findFood(foodId);
    //   if (!foodItemMaster.id.isNull()) {
    //     list.add(RecommendationFoodInfo(
    //           foodItemMaster: findFood(foodId),
    //           foodNutrients: /** DUMMY, must receive from backend */[],
    //         ),);
    //   }
    // }


    final list = foodList.map((foodId) => RecommendationFoodInfo(
      foodItemMaster: findFood(foodId),
      foodNutrients: /** DUMMY, must receive from backend */[],
    ),).toList();

    return list;
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

  // List<List<FoodItemMaster>> getIngredientsNames(List<RecipeMaster> recipeMasterList, List<int> foodIds) {
  //   final ingredientsList = recipeMasterList.map((recipe) => recipe.ingredients).toList();
  //   final List<List<FoodItemMaster>> ingredientsFoodItemMaster = [];
  //   for (var ingredients in ingredientsList) {
  //     final List<FoodItemMaster> ingredientsItems = [];
  //     for (var ingredient in ingredients) {
  //       if (foodIds.contains(ingredient.id)) {
  //         final foodItemMaster = getFoodNameByFoodId(ingredient.id);
  //         if (!ingredientsItems.contains(foodItemMaster)) ingredientsItems.add(foodItemMaster);
  //       }
  //     }
  //     ingredientsFoodItemMaster.add([...ingredientsItems]);
  //   }
  //   return ingredientsFoodItemMaster;
  // }

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
    return state.foodAndDrinksNames!.firstWhere((foodItemMaster) => foodItemMaster.id == foodId, orElse: () => FoodItemMaster.empty());
  }

  List<UsualFoodsItem> getRecommendationOfUsualFoods(List<UsualFoodItem> usualHealthyFoods) {
    List<UsualFoodsItem> list = [];
    for (var usualFoodItem in usualHealthyFoods) {
      var foodItem = UsualFoodsItem(
          foodInfo: RecommendationFoodInfo(
            foodItemMaster: findFood(usualFoodItem.foodId),
            foodNutrients: /** DUMMY, must receive from backend */[],
          ),
          alternativeUsualHealthyFoods: getRecommendationFoodInfo(usualFoodItem.alternativeUsualHealthyFood.orEmpty()),
          alternativeUsualUnHealthyFoods: getRecommendationFoodInfo(usualFoodItem.alternativeUsualUnhealthyFoods.orEmpty()),
      );
    list.add(foodItem);
    }
    return list;
  }

}