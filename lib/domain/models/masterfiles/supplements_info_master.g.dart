// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplements_info_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplementsInfoMaster _$SupplementsInfoMasterFromJson(
        Map<String, dynamic> json) =>
    SupplementsInfoMaster(
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => SupplementInfoMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SupplementsInfoMasterToJson(
        SupplementsInfoMaster instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

SupplementInfoMaster _$SupplementInfoMasterFromJson(
        Map<String, dynamic> json) =>
    SupplementInfoMaster(
      id: (json['id'] as num).toInt(),
      es: json['es'] as String,
      en: json['en'] as String,
      unit: json['unit'] as String,
      computerName: json['computerName'] as String?,
    );

Map<String, dynamic> _$SupplementInfoMasterToJson(
        SupplementInfoMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'es': instance.es,
      'en': instance.en,
      'unit': instance.unit,
      'computerName': instance.computerName,
    };
