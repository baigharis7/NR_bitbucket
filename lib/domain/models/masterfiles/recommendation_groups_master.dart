import 'package:json_annotation/json_annotation.dart';

import 'translatable.dart';

part 'recommendation_groups_master.g.dart';

@JsonSerializable(explicitToJson: true)
class RecommendationGroupsMaster {
  List<RecommendationGroup> recommendationGroups;

  RecommendationGroupsMaster({required this.recommendationGroups});

  factory RecommendationGroupsMaster.fromJson(Map<String, dynamic> json) => _$RecommendationGroupsMasterFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupsMasterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecommendationGroup extends Translatable {
  int id;
  List<String> groups;
  int size;
  String en;
  String es;

  RecommendationGroup({required this.id, required this.groups, required this.size, required this.en, required this.es});

  factory RecommendationGroup.fromJson(Map<String, dynamic> json) => _$RecommendationGroupFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupToJson(this);

}