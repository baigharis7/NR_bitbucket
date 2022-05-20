import 'package:json_annotation/json_annotation.dart';

part 'recommendation_received.g.dart';

// TODO: dejo esta clase hecha, pero no le veo sentido a usarla.
@JsonSerializable(explicitToJson: true)
class RecommendationReceived {
  List<GroupRecommendation> foodList;
  List<String> userNutrients;

  RecommendationReceived(this.foodList, this.userNutrients);

  factory RecommendationReceived.fromJson(Map<String, dynamic> json) => _$RecommendationReceivedFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationReceivedToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GroupRecommendation {
  int recGroup;
  List<int> foods;

  GroupRecommendation(this.recGroup, this.foods);

  factory GroupRecommendation.fromJson(Map<String, dynamic> json) => _$GroupRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$GroupRecommendationToJson(this);
}