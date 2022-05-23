import 'package:json_annotation/json_annotation.dart';

part 'objectives_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class ObjectivesInfoEntity {
  int id;
  int v;
  List<ObjectiveInfoEntity> data;

  ObjectivesInfoEntity({required this.id, required this.v, required this.data});

  factory ObjectivesInfoEntity.fromJson(Map<String, dynamic> json) => _$ObjectivesInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectivesInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ObjectiveInfoEntity {
  int id;
  String en;
  String es;

  ObjectiveInfoEntity({required this.id, required this.en, required this.es});

  factory ObjectiveInfoEntity.fromJson(Map<String, dynamic> json) => _$ObjectiveInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectiveInfoEntityToJson(this);
}