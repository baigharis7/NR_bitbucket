import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'recommendation_groups_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.recommendationGroupsEntity)
class RecommendationGroupsEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<RecommendationGroupEntity> data;

  RecommendationGroupsEntity({required this.id, required this.v, required this.data});

  factory RecommendationGroupsEntity.fromJson(Map<String, dynamic> json) => _$RecommendationGroupsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.recommendationGroupEntity)
class RecommendationGroupEntity {
  @HiveField(0) int id;
  @HiveField(1) List<String> groups;
  @HiveField(2) int size;
  @HiveField(3) String en;
  @HiveField(4) String es;

  RecommendationGroupEntity({required this.id, required this.groups, required this.size, required this.en, required this.es});

  factory RecommendationGroupEntity.fromJson(Map<String, dynamic> json) => _$RecommendationGroupEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationGroupEntityToJson(this);
}