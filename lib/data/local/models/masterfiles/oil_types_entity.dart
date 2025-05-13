import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'oil_types_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.oilTypesEntity)
class OilTypesEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<OilTypeEntity> data;

  OilTypesEntity({required this.id, required this.v, required this.data});

  factory OilTypesEntity.fromJson(Map<String, dynamic> json) => _$OilTypesEntityFromJson(json);
  Map<String, dynamic> toJson() => _$OilTypesEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.oilTypeEntity)
class OilTypeEntity {
  @HiveField(0) int id;
  @HiveField(1) String en;
  @HiveField(2) String es;

  OilTypeEntity({required this.id, required this.en, required this.es});

  factory OilTypeEntity.fromJson(Map<String, dynamic> json) => _$OilTypeEntityFromJson(json);
  Map<String, dynamic> toJson() => _$OilTypeEntityToJson(this);
}