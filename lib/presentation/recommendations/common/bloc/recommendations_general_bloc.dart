import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_recent_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_exclusions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipes_for_foods_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/recipes_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/recommendation_computation_service.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';

import '../../../../domain/interactor/profile/get_profile_interactor.dart';
import '../../../../domain/interactor/profile/save_profile_entity_interactor.dart';

class RecommendationsGeneralBloc extends Bloc<RecommendationsGeneralActions, RecommendationsGeneralState> {
  final GetUserIdInteractor getUserIdInteractor;
  final GetRecommendationInteractor getRecommendationInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;
  final GetRecipesForFoodsInteractor getRecipesForFoodsInteractor;
  final GetUserExclusionsInteractor getUserExclusionsInteractor;
  final GetProfileInteractor getProfileInteractor;
  final SaveProfileInteractor saveProfileInteractor;
  final RecommendationComputationService recommendationComputationService;
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final GetRecentFoodEventsInteractor getRecentFoodEventsInteractor;
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor;

  // O(1) food name lookup map (built once on init)
  Map<int, FoodItemMaster>? _foodNameMap;

  RecommendationsGeneralBloc({
    required this.getRecommendationInteractor,
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
    required this.getRecipesForFoodsInteractor,
    required this.getUserExclusionsInteractor,
    required this.getProfileInteractor,
    required this.saveProfileInteractor,
    required this.recommendationComputationService,
    required this.getWeekFoodEventsInteractor,
    required this.getRecentFoodEventsInteractor,
    required this.getFoodFavoritesInteractor,
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
    recommendationGroups: RecommendationGroupsMaster(recommendationGroups: []),
    recommendation: Recommendation(foodList: [], userNutrients: [], nutrientsInDeficit: []),
    recentFoodEvents: [],
    foodFavorites: [],
    needToSearchRecipes: true,
  ),) {
    on<InitialStateAction>((event, emit) async {
      // Skip re-computation if results are already cached (not just placeholders)
      if (state.recommendation != null && state.recommendationFoodsItems?.isNotEmpty == true) {
        return;
      }

      emit(state.copyWith(isLoading: false, onError: null));

      // Load recommendation groups first (fast, from Hive) to show skeleton.
      // Master file may be null if reference data isn't loaded yet (first launch,
      // post cache-clear) — fall back to empty rather than crashing.
      final groupsResult = await getMasterFileInteractor.execute(MasterFilesType.recommendationGroups);
      state.recommendationGroups = (groupsResult as RecommendationGroupsMaster?)
          ?? RecommendationGroupsMaster(recommendationGroups: []);

      // Emit placeholder group headers immediately (empty food lists)
      // so the UI shows collapsed groups while the rest loads
      state.recommendationFoodsItems = state.recommendationGroups!.recommendationGroups
          .map((group) => RecommendationsFoodItem(
                recommendationGroup: group,
                objFoods: [],
                deficitFoods: [],
              ))
          .toList();
      emit(state.copyWith(isLoading: false, onError: null));

      // Load remaining data in parallel (including recents & favorites
      // to avoid concurrent event handler state conflicts)
      final results = await Future.wait([
        getProfileInteractor.execute(),
        getUserExclusionsInteractor.execute(),
        _loadFoodAndDrinksNames(),
        _loadRecentFoodEvents(),
        _loadFoodFavorites(),
      ]);

      state.profile = results[0] as dynamic;
      state.exclusions = results[1] as List<int>;
      state.recentFoodEvents = results[3] as List<FoodEventComplete>;
      state.foodFavorites = results[4] as List<FoodFavorite>;
      state.foodItems = getFoodItemFromIds(state.profile?.recommededIds.orEmpty() ?? []);

      // Build O(1) lookup map for food names
      _foodNameMap = {};
      for (final food in state.foodAndDrinksNames ?? []) {
        if (food.id != null) _foodNameMap![food.id!] = food;
      }

      try {
        // Try local computation first
        final weekFoodEvents = await getWeekFoodEventsInteractor.execute();
        Recommendation? recommendation = await recommendationComputationService.compute(
          profile: state.profile!,
          weekFoodEvents: weekFoodEvents,
          recommendationGroups: state.recommendationGroups!,
        );

        if (recommendation == null) {
          // Fall back to API — show loading only for network call
          emit(state.copyWith(isLoading: true));
          recommendation = await getRecommendationInteractor.execute(
            getUserIdInteractor.execute(),
          );
        }

        state.recommendation = recommendation;
        state.recommendationFoodsItems = recommendation!.foodList
            .map((groupRecommendation) {
              final objFoodIds = groupRecommendation.objFoods.toSet();
              final dedupedDeficitFoods = groupRecommendation.deficitFoods
                  .where((id) => !objFoodIds.contains(id))
                  .toList();
              return RecommendationsFoodItem(
                recommendationGroup: findRecommendationGroup(groupRecommendation.recGroup),
                objFoods: getRecommendationFoodInfo(groupRecommendation.objFoods),
                deficitFoods: getRecommendationFoodInfo(dedupedDeficitFoods),
                usualHealthyFoods: getRecommendationOfUsualFoods(groupRecommendation.usualFoods.usualHealthyFoods.orEmpty()),
                usualUnHealthyFoods: getRecommendationOfUsualFoods(groupRecommendation.usualFoods.usualUnhealthyFoods.orEmpty()),
              );
            }).toList();

        // Ensure saved foods appear in their group's dropdown
        _ensureSavedFoodsVisible();

        // Parallelize explaining card checks
        final cardResults = await Future.wait([
          isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.recommendations.index),
          isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.recipes.index),
          isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.foodList.index),
        ]);
        state.showRecommendationCard = cardResults[0];
        state.showRecipesCard = cardResults[1];
        state.showFoodListCard = cardResults[2];

        emit(state.copyWith(isLoading: false, onError: null));
      } catch (error) {
        state.recommendation = null;
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.recommendationError));
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

      // Auto-save picks locally (fire-and-forget)
      _saveRecommendedIdsLocally();

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

      // Auto-save picks locally (fire-and-forget)
      _saveRecommendedIdsLocally();

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

    // Recents & favorites are now loaded inside InitialStateAction to avoid
    // concurrent event handler state conflicts. Keep handlers as no-op fallbacks.
    on<LoadRecentFoodsAction>((event, emit) async {
      if (state.recentFoodEvents != null) return;
      state.recentFoodEvents = await _loadRecentFoodEvents();
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<LoadFavoritesAction>((event, emit) async {
      if (state.foodFavorites != null) return;
      state.foodFavorites = await _loadFoodFavorites();
      emit(state.copyWith(isLoading: false, onError: null));
    });
  }

  Future<List<FoodEventComplete>> _loadRecentFoodEvents() async {
    try {
      return await getRecentFoodEventsInteractor.execute();
    } catch (_) {
      return [];
    }
  }

  Future<List<FoodFavorite>> _loadFoodFavorites() async {
    try {
      return await getFoodFavoritesInteractor.execute();
    } catch (_) {
      return [];
    }
  }

  /// Ensures foods in the user's saved list appear in their recommendation
  /// group dropdown, even if the computation excluded them (e.g. already eaten).
  void _ensureSavedFoodsVisible() {
    final savedFoods = state.foodItems.orEmpty();
    if (savedFoods.isEmpty || state.recommendationFoodsItems == null) return;

    // Collect all food IDs already in recommendation lists
    final existingIds = <int>{};
    for (final item in state.recommendationFoodsItems!) {
      for (final f in item.objFoods) {
        if (f.foodItemMaster.id != null) existingIds.add(f.foodItemMaster.id!);
      }
      for (final f in item.deficitFoods) {
        if (f.foodItemMaster.id != null) existingIds.add(f.foodItemMaster.id!);
      }
      for (final f in (item.usualHealthyFoods ?? [])) {
        if (f.foodInfo.foodItemMaster.id != null) existingIds.add(f.foodInfo.foodItemMaster.id!);
      }
      for (final f in (item.usualUnHealthyFoods ?? [])) {
        if (f.foodInfo.foodItemMaster.id != null) existingIds.add(f.foodInfo.foodItemMaster.id!);
      }
    }

    // For each saved food not already visible, add it to its group's objFoods
    for (final savedItem in savedFoods) {
      if (existingIds.contains(savedItem.id)) continue;

      final food = findFood(savedItem.id);
      if (food.id == null) continue;

      // Find the recommendation group for this food
      final foodGroup = food.group ?? '';
      if (foodGroup.isEmpty) continue;

      for (final recItem in state.recommendationFoodsItems!) {
        if (recItem.recommendationGroup.groups.contains(foodGroup)) {
          recItem.objFoods.add(RecommendationFoodInfo(
            foodItemMaster: food,
            foodNutrients: [],
          ));
          break;
        }
      }
    }
  }

  /// Loads food & drink names master file if not already loaded.
  Future<void> _loadFoodAndDrinksNames() async {
    if (state.foodAndDrinksNames.orEmpty().isEmpty) {
      final foodAndDrinksMasterFile = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames) as FoodsAndDrinksNamesMaster;
      state.foodAndDrinksNames = foodAndDrinksMasterFile.foodsAndDrinksNames!.foodNames?..addAll(foodAndDrinksMasterFile.foodsAndDrinksNames!.drinkNames!.toList());
    }
  }

  /// Saves recommended food IDs to local Hive profile (no API upload).
  void _saveRecommendedIdsLocally() {
    if (state.profile != null) {
      state.profile!.recommededIds = state.foodItems.orEmpty().map((e) => e.id).toList();
      saveProfileInteractor.execute(state.profile!).catchError((_) {});
    }
  }

  RecommendationGroup findRecommendationGroup(int groupId) {
    return state.recommendationGroups!.recommendationGroups.firstWhere((recommendationGroup) => recommendationGroup.id == groupId);
  }

  /// Returns the recommendation group for a food, or null if not found.
  RecommendationGroup? findFoodGroup(int foodId) {
    final food = findFood(foodId);
    final foodGroup = food.group ?? '';
    if (foodGroup.isEmpty || state.recommendationGroups == null) return null;
    for (final recGroup in state.recommendationGroups!.recommendationGroups) {
      if (recGroup.groups.contains(foodGroup)) {
        return recGroup;
      }
    }
    return null;
  }

  /// Returns the category color for a food based on which recommendation list it belongs to.
  /// Blue = objective foods, Green = deficit foods, YellowishGreen = usual foods.
  int findFoodCategoryType(int foodId) {
    for (final item in state.recommendationFoodsItems ?? []) {
      if (item.objFoods.any((f) => f.foodItemMaster.id == foodId)) return 0; // blue
      if (item.deficitFoods.any((f) => f.foodItemMaster.id == foodId)) return 1; // green
      if ((item.usualUnHealthyFoods ?? []).any((f) => f.foodInfo.foodItemMaster.id == foodId)) return 2; // yellowishGreen
      if ((item.usualHealthyFoods ?? []).any((f) => f.foodInfo.foodItemMaster.id == foodId)) return 3; // yellowishGreen
    }
    return -1; // not found
  }

  FoodItemMaster findFood(int foodId) {
    // Use O(1) map lookup if available, fall back to linear scan
    if (_foodNameMap != null) {
      return _foodNameMap![foodId] ?? FoodItemMaster();
    }
    return state.foodAndDrinksNames!.firstWhere((food) => food.id == foodId, orElse: () => FoodItemMaster());
  }

  List<RecommendationFoodInfo> getRecommendationFoodInfo(List<int> foodList) {
    return foodList.map((foodId) => RecommendationFoodInfo(
      foodItemMaster: findFood(foodId),
      foodNutrients: [],
    )).toList();
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
    if (_foodNameMap != null) {
      return _foodNameMap![foodId] ?? FoodItemMaster.empty();
    }
    return state.foodAndDrinksNames!.firstWhere((foodItemMaster) => foodItemMaster.id == foodId, orElse: () => FoodItemMaster.empty());
  }

  List<UsualFoodsItem> getRecommendationOfUsualFoods(List<UsualFoodItem> usualHealthyFoods) {
    List<UsualFoodsItem> list = [];
    for (var usualFoodItem in usualHealthyFoods) {
      var foodItem = UsualFoodsItem(
          foodInfo: RecommendationFoodInfo(
            foodItemMaster: findFood(usualFoodItem.foodId),
            foodNutrients: [],
          ),
          alternativeUsualHealthyFoods: getRecommendationFoodInfo(usualFoodItem.alternativeUsualHealthyFood.orEmpty()),
          alternativeUsualUnHealthyFoods: getRecommendationFoodInfo(usualFoodItem.alternativeUsualUnhealthyFoods.orEmpty()),
      );
    list.add(foodItem);
    }
    return list;
  }

  List<SimpleItem>? getFoodItemFromIds(List<int> foodItems) {
    List<SimpleItem> list = [];
    for (var item in foodItems) {
      list.add(SimpleItem(name: '', id: item));
    }
    return list;
  }

}
