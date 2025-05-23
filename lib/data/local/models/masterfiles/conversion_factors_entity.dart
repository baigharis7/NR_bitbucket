import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'conversion_factors_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.conversionFactorsEntity)
class ConversionFactorsEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<ConversionFactorEntity> data;

  ConversionFactorsEntity({required this.id, required this.v, required this.data});
  factory ConversionFactorsEntity.fromJson(Map<String, dynamic> json) => _$ConversionFactorsEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorsEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.conversionFactorEntity)
class ConversionFactorEntity {
  @HiveField(0) int id;
  @HiveField(1) String en;
  @HiveField(2) String es;

  ConversionFactorEntity({required this.id, required this.en, required this.es});
  factory ConversionFactorEntity.fromJson(Map<String, dynamic> json) => _$ConversionFactorEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorEntityToJson(this);
}