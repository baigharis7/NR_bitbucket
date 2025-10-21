import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'units_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.unitsInfoEntity)
class UnitsInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<UnitInfoEntity> data;

  UnitsInfoEntity({required this.id, required this.v, required this.data});

  factory UnitsInfoEntity.fromJson(Map<String, dynamic> json) => _$UnitsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UnitsInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.unitInfoEntity)
class UnitInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) String en;
  @HiveField(2) String es;
  @HiveField(3) String? enPlural;
  @HiveField(4) String? esPlural;

  UnitInfoEntity({required this.id, required this.en, required this.es, required this.enPlural, required this.esPlural});

  factory UnitInfoEntity.fromJson(Map<String, dynamic> json) => _$UnitInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UnitInfoEntityToJson(this);

}