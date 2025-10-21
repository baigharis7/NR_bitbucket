// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'units_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitsInfoResponse _$UnitsInfoResponseFromJson(Map<String, dynamic> json) =>
    UnitsInfoResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => UnitInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnitsInfoResponseToJson(UnitsInfoResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

UnitInfoResponse _$UnitInfoResponseFromJson(Map<String, dynamic> json) =>
    UnitInfoResponse(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
      enPlural: json['en_plural'] as String?,
      esPlural:  json['es_plural'] as String?,
    );

Map<String, dynamic> _$UnitInfoResponseToJson(UnitInfoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'en_plural': instance.enPlural,
      'es_plural': instance.esPlural,
    };
