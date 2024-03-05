import 'package:json_annotation/json_annotation.dart';

part 'recommendation.g.dart';

@JsonSerializable(explicitToJson: true)
class Recommendation {
  List<GroupRecommendation> foodList;
  List<String> userNutrients;

  Recommendation({
    required this.foodList,
    required this.userNutrients,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) => _$RecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GroupRecommendation {
  int recGroup;
  List<int> foods;
  UsualFoods usualFoods;

  GroupRecommendation(this.recGroup, this.foods, this.usualFoods);

  factory GroupRecommendation.fromJson(Map<String, dynamic> json) => _$GroupRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$GroupRecommendationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UsualFoods {
  List<UsualFoodItem>? usualHealthyFoods;
  List<UsualFoodItem>? usualUnhealthyFoods;

  UsualFoods(this.usualHealthyFoods, this.usualUnhealthyFoods);

  factory UsualFoods.fromJson(Map<String, dynamic> json) => _$UsualFoodsFromJson(json);
  Map<String, dynamic> toJson() => _$UsualFoodsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UsualFoodItem {
  int foodId;
  List<int>? alternativeUsualHealthyFood;
  List<int>? alternativeUsualUnhealthyFoods;

  UsualFoodItem(this.foodId, this.alternativeUsualHealthyFood, this.alternativeUsualUnhealthyFoods,);

  factory UsualFoodItem.fromJson(Map<String, dynamic> json) => _$UsualFoodItemFromJson(json);
  Map<String, dynamic> toJson() => _$UsualFoodItemToJson(this);
}