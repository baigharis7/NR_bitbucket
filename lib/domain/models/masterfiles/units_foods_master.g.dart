// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'units_foods_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitsFoodsMaster _$UnitsFoodsMasterFromJson(Map<String, dynamic> json) =>
    UnitsFoodsMaster(
      unitsFoodsMaster: (json['unitsFoodsMaster'] as List<dynamic>)
          .map((e) => UnitFoodMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnitsFoodsMasterToJson(UnitsFoodsMaster instance) =>
    <String, dynamic>{
      'unitsFoodsMaster':
          instance.unitsFoodsMaster.map((e) => e.toJson()).toList(),
    };

UnitFoodMaster _$UnitFoodMasterFromJson(Map<String, dynamic> json) =>
    UnitFoodMaster(
      id: (json['id'] as num).toInt(),
      units: json['units'] as String,
    );

Map<String, dynamic> _$UnitFoodMasterToJson(UnitFoodMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'units': instance.units,
    };
