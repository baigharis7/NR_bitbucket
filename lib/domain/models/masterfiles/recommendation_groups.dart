import 'package:json_annotation/json_annotation.dart';

part 'recommendation_groups.g.dart';

@JsonSerializable(explicitToJson: true)
class RecommendationGroups {
  List<RecommendationGroup> recommendationGroups;

  RecommendationGroups({required this.recommendationGroups});

  factory RecommendationGroups.fromJson(Map<String, dynamic> json) => _$RecommendationGroupsFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecommendationGroup {
  int id;
  List<String> groups;
  int size;
  String en;
  String es;

  RecommendationGroup({required this.id, required this.groups, required this.size, required this.en, required this.es});

  factory RecommendationGroup.fromJson(Map<String, dynamic> json) => _$RecommendationGroupFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupToJson(this);
}