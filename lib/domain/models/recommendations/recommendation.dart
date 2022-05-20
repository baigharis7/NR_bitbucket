import 'package:json_annotation/json_annotation.dart';

part 'recommendation.g.dart';

@JsonSerializable(explicitToJson: true)
class Recommendation {
  List<GroupRecommendation> foodList;
  List<String> userNutrients;

  Recommendation(this.foodList, this.userNutrients);

  factory Recommendation.fromJson(Map<String, dynamic> json) => _$RecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GroupRecommendation {
  int recGroup;
  List<int> foods;

  GroupRecommendation(this.recGroup, this.foods);

  factory GroupRecommendation.fromJson(Map<String, dynamic> json) => _$GroupRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$GroupRecommendationToJson(this);
}