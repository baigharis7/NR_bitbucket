import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';

class RecommendationsFoodItem {
  RecommendationGroup recommendationGroup;
  List<RecommendationFoodInfo> objFoods;
  List<RecommendationFoodInfo> deficitFoods;
  List<UsualFoodsItem>? usualHealthyFoods;
  List<UsualFoodsItem>? usualUnHealthyFoods;

  RecommendationsFoodItem({
    required this.recommendationGroup,
    required this.objFoods,
    required this.deficitFoods,
    this.usualHealthyFoods,
    this.usualUnHealthyFoods,
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

class UsualFoodsItem {
  RecommendationFoodInfo foodInfo;
  List<RecommendationFoodInfo> alternativeUsualHealthyFoods;
  List<RecommendationFoodInfo> alternativeUsualUnHealthyFoods;

  UsualFoodsItem({required this.foodInfo, required this.alternativeUsualHealthyFoods, required this.alternativeUsualUnHealthyFoods});
}