import 'package:json_annotation/json_annotation.dart';

part 'recommendation_groups_response.g.dart';

@JsonSerializable(explicitToJson: true)
class RecommendationGroupsResponse {
  int v;
  List<RecommendationGroup> data;

  RecommendationGroupsResponse({required this.v, required this.data});

  factory RecommendationGroupsResponse.fromJson(Map<String, dynamic> json) => _$RecommendationGroupsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupsResponseToJson(this);
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