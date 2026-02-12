import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'cooking_methods_oils_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.cookingMethodsOilsInfoEntity)
class CookingMethodsOilsInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<CookingMethodOilInfoEntity> data;

  CookingMethodsOilsInfoEntity({required this.id, required this.v, required this.data});

  factory CookingMethodsOilsInfoEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodsOilsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsOilsInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.cookingMethodOilInfoEntity)
class CookingMethodOilInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) String name;
  @HiveField(2) double percentage;

  CookingMethodOilInfoEntity({required this.id, required this.name, required this.percentage});

  factory CookingMethodOilInfoEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodOilInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodOilInfoEntityToJson(this);
}
