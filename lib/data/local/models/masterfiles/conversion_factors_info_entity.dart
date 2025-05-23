import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'conversion_factors_info_entity.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.conversionFactorsInfoEntity)
class ConversionFactorsInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) int v;
  @HiveField(2) List<ConversionFactorInfoEntity> data;

  ConversionFactorsInfoEntity({required this.id, required this.v, required this.data});
  factory ConversionFactorsInfoEntity.fromJson(Map<String, dynamic> json) => _$ConversionFactorsInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorsInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.conversionFactorInfoEntity)
class ConversionFactorInfoEntity {
  @HiveField(0) int id;
  @HiveField(1) String value;
  @HiveField(2) List<ConversionInfoEntity> list;

  ConversionFactorInfoEntity({required this.id, required this.value, required this.list});
  factory ConversionFactorInfoEntity.fromJson(Map<String, dynamic> json) => _$ConversionFactorInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionFactorInfoEntityToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.conversionInfoEntity)
class ConversionInfoEntity {
  @HiveField(0) String g;
  @HiveField(1) num v;

  ConversionInfoEntity({required this.g, required this.v});

  factory ConversionInfoEntity.fromJson(Map<String, dynamic> json) => _$ConversionInfoEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionInfoEntityToJson(this);
}