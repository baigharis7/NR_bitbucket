// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oil_types_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OilTypesResponse _$OilTypesResponseFromJson(Map<String, dynamic> json) =>
    OilTypesResponse(
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => OilTypeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OilTypesResponseToJson(OilTypesResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

OilTypeResponse _$OilTypeResponseFromJson(Map<String, dynamic> json) =>
    OilTypeResponse(
      id: (json['id'] as num).toInt(),
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$OilTypeResponseToJson(OilTypeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
