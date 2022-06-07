import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'cooking_methods_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.cookingMethodsEntity)
class CookingMethodsEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<CookingMethodGroupEntity> data;

  CookingMethodsEntity({required this.id, required this.v, required this.data});

  factory CookingMethodsEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.cookingMethodGroupEntity)
class CookingMethodGroupEntity {
  @HiveField(0) String g;
  @HiveField(1) List<int> m;

  CookingMethodGroupEntity({required this.g, required this.m});

  factory CookingMethodGroupEntity.fromJson(Map<String, dynamic> json) => _$CookingMethodGroupEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CookingMethodGroupEntityToJson(this);
}