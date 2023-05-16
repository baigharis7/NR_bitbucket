// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'units_info_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitsInfoMaster _$UnitsInfoMasterFromJson(Map<String, dynamic> json) =>
    UnitsInfoMaster(
      unitsInfoMaster: (json['unitsInfoMaster'] as List<dynamic>)
          .map((e) => UnitInfoMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnitsInfoMasterToJson(UnitsInfoMaster instance) =>
    <String, dynamic>{
      'unitsInfoMaster':
          instance.unitsInfoMaster.map((e) => e.toJson()).toList(),
    };

UnitInfoMaster _$UnitInfoMasterFromJson(Map<String, dynamic> json) =>
    UnitInfoMaster(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$UnitInfoMasterToJson(UnitInfoMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
