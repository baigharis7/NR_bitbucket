import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'objectives_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.objectivesInfoEntity)
class ObjectivesInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<ObjectiveInfoEntity> data;

  ObjectivesInfoEntity({required this.id, required this.v, required this.data});

  factory ObjectivesInfoEntity.fromJson(Map<String, dynamic> json) => _$ObjectivesInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectivesInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.objectiveInfoEntity)
class ObjectiveInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) String en;
  @HiveField(2) String es;

  ObjectiveInfoEntity({required this.id, required this.en, required this.es});

  factory ObjectiveInfoEntity.fromJson(Map<String, dynamic> json) => _$ObjectiveInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectiveInfoEntityToJson(this);
}