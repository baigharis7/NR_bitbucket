import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'units_foods_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.unitsFoodsEntity)
class UnitsFoodsEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<UnitFoodEntity> data;

  UnitsFoodsEntity({required this.id, required this.v, required this.data});

  factory UnitsFoodsEntity.fromJson(Map<String, dynamic> json) => _$UnitsFoodsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UnitsFoodsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.unitFoodEntity)
class UnitFoodEntity {
  @HiveField(0) int id;
  @HiveField(1) String units;

  UnitFoodEntity({required this.id, required this.units,});

  factory UnitFoodEntity.fromJson(Map<String, dynamic> json) => _$UnitFoodEntityFromJson(json);
  Map<String, dynamic> toJson() => _$UnitFoodEntityToJson(this);
}