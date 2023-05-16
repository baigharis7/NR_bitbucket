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
  List<int> usualFoods;

  GroupRecommendation(this.recGroup, this.foods, this.usualFoods);

  factory GroupRecommendation.fromJson(Map<String, dynamic> json) => _$GroupRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$GroupRecommendationToJson(this);
}