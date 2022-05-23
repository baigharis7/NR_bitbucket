import 'package:json_annotation/json_annotation.dart';

part 'recommendation_groups_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class RecommendationGroupsEntity {
  int id;
  int v;
  List<RecommendationGroupEntity> data;

  RecommendationGroupsEntity({required this.id, required this.v, required this.data});

  factory RecommendationGroupsEntity.fromJson(Map<String, dynamic> json) => _$RecommendationGroupsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecommendationGroupEntity {
  int id;
  List<String> groups;
  int size;
  String en;
  String es;

  RecommendationGroupEntity({required this.id, required this.groups, required this.size, required this.en, required this.es});

  factory RecommendationGroupEntity.fromJson(Map<String, dynamic> json) => _$RecommendationGroupEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupEntityToJson(this);
}