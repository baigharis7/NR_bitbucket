import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'nutrients_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.nutrientsInfoEntity)
class NutrientsInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) String name;
  @HiveField(2) String unit; // TODO: Pensar si poner una Sealed Class. Sería un Iny entonces.
  @HiveField(3) String es;
  @HiveField(4) String en;

  NutrientsInfoEntity({required this.id, required this.name, required this.unit, required this.es, required this.en});

  factory NutrientsInfoEntity.fromJson(Map<String, dynamic> json) => _$NutrientsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$NutrientsInfoEntityToJson(this);
}