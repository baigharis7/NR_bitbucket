import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/recipes_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../../domain/models/profile/user_profile_model.dart';

class RecommendationsGeneralState {
  bool isLoading;
  ErrorTypes? onError;
  Recommendation? recommendation;
  UserProfileModel? profile;
  RecommendationGroupsMaster? recommendationGroups;
  List<FoodItemMaster>? foodAndDrinksNames;
  List<RecommendationsFoodItem>? recommendationFoodsItems;
  bool? showRecommendationCard;
  bool? showFoodListCard;
  List<SimpleItem>? foodItems;
  List<RecipeMaster>? recipesList;
  List<RecipeMaster>? recipesListAll;
  // List<int>? foodIds;
  List<int>? exclusions;
  bool? showRecipesCard;
  bool? needToSearchRecipes;

  RecommendationsGeneralState({
    required this.isLoading,
    this.onError,
    this.recommendation,
    this.profile,
    this.recommendationGroups,
    this.foodAndDrinksNames,
    this.recommendationFoodsItems,
    this.showRecommendationCard,
    this.showFoodListCard,
    this.foodItems,
    this.recipesList,
    this.recipesListAll,
    this.exclusions,
    this.showRecipesCard,
    this.needToSearchRecipes,
  });

  RecommendationsGeneralState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    Recommendation? recommendation,
    UserProfileModel? profile,
    RecommendationGroupsMaster? recommendationGroups,
    List<FoodItemMaster>? foodAndDrinksNames,
    List<RecommendationsFoodItem>? recommendationFoodsItems,
    bool? showRecommendationCard,
    bool? showRecipesCard,
    bool? showFoodListCard,
    List<SimpleItem>? foodItems,
    List<RecipeMaster>? recipesList,
    List<RecipeMaster>? recipesListAll,
    List<int>? exclusions,
    bool? needToSearchRecipes,
  }) {
    return RecommendationsGeneralState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      recommendation: recommendation ?? this.recommendation,
      profile: profile ?? this.profile,
      recommendationGroups: recommendationGroups ?? this.recommendationGroups,
      foodAndDrinksNames: foodAndDrinksNames ?? this.foodAndDrinksNames,
      recommendationFoodsItems: recommendationFoodsItems ?? this.recommendationFoodsItems,
      showRecommendationCard: showRecommendationCard ?? this.showRecommendationCard,
      showRecipesCard: showRecipesCard ?? this.showRecipesCard,
      showFoodListCard: showFoodListCard ?? this.showFoodListCard,
      foodItems: foodItems ?? this.foodItems,
      recipesList: recipesList ?? this.recipesList,
      recipesListAll: recipesListAll ?? this.recipesListAll,
      exclusions: exclusions ?? this.exclusions,
      needToSearchRecipes: needToSearchRecipes ?? this.needToSearchRecipes,
    );
  }

}