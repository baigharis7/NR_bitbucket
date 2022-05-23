import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'cooking_methods_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.cookingMethodsInfoEntity)
class CookingMethodsInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<CookingMethodInfoEntity> data;

  CookingMethodsInfoEntity({required this.id, required this.v, required this.data});

  factory CookingMethodsInfoEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.cookingMethodInfoEntity)
class CookingMethodInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) String en;
  @HiveField(2) String es;

  CookingMethodInfoEntity({required this.id, required this.en, required this.es});

  factory CookingMethodInfoEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodInfoEntityToJson(this);
}