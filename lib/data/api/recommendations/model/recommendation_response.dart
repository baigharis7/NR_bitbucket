import 'package:json_annotation/json_annotation.dart';

part 'recommendation_response.g.dart';

// TODO: dejo esta clase hecha, pero no le veo sentido a usarla.
@JsonSerializable(explicitToJson: true)
class RecommendationResponse {
  List<GroupRecommendation> foodList;
  List<String> userNutrients;

  RecommendationResponse(this.foodList, this.userNutrients);

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) => _$RecommendationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationResponseToJson(this);
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