import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'nutrients_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.nutrientsInfoEntity)
class NutrientsInfoEntity {

  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<NutrientInfoEntity> data;

  NutrientsInfoEntity({required this.id, required this.v, required this.data});

  factory NutrientsInfoEntity.fromJson(Map<String, dynamic> json) => _$NutrientsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientsInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.nutrientInfoEntity)
class NutrientInfoEntity {

  @HiveField(0) String name;
  @HiveField(1) String unit;
  @HiveField(2) String es;
  @HiveField(3) String en;
  @HiveField(4) String? description_es;
  @HiveField(5) String? description_en;

  NutrientInfoEntity({required this.name, required this.unit, required this.es, required this.en, this.description_es, this.description_en});

  factory NutrientInfoEntity.fromJson(Map<String, dynamic> json) => _$NutrientInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientInfoEntityToJson(this);
}