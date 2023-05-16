import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';

class RecommendationsFoodItem {
  RecommendationGroup recommendationGroup;
  List<RecommendationFoodInfo> recommendedFoods;
  List<RecommendationFoodInfo> frequentFoods;

  RecommendationsFoodItem({
    required this.recommendationGroup,
    required this.recommendedFoods,
    required this.frequentFoods,
  });

}

class RecommendationFoodInfo {
  FoodItemMaster foodItemMaster;
  List<String>? foodNutrients;

  RecommendationFoodInfo({
    required this.foodItemMaster,
    required this.foodNutrients,
  });

}