import 'package:json_annotation/json_annotation.dart';

part 'recommendation_groups_response.g.dart';

@JsonSerializable(explicitToJson: true)
class RecommendationGroupsResponse {
  int v;
  List<RecommendationGroupResponse> data;

  RecommendationGroupsResponse({required this.v, required this.data});

  factory RecommendationGroupsResponse.fromJson(Map<String, dynamic> json) => _$RecommendationGroupsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecommendationGroupResponse {
  int id;
  List<String> groups;
  int size;
  String en;
  String es;

  RecommendationGroupResponse({required this.id, required this.groups, required this.size, required this.en, required this.es});

  factory RecommendationGroupResponse.fromJson(Map<String, dynamic> json) => _$RecommendationGroupResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupResponseToJson(this);

}