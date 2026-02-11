// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplements_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplementsInfoResponse _$SupplementsInfoResponseFromJson(
        Map<String, dynamic> json) =>
    SupplementsInfoResponse(
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map(
              (e) => SupplementInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SupplementsInfoResponseToJson(
        SupplementsInfoResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

SupplementInfoResponse _$SupplementInfoResponseFromJson(
        Map<String, dynamic> json) =>
    SupplementInfoResponse(
      id: (json['id'] as num).toInt(),
      es: json['es'] as String,
      en: json['en'] as String,
      unit: json['unit'] as String,
      computerName: json['computerName'] as String?,
    );

Map<String, dynamic> _$SupplementInfoResponseToJson(
        SupplementInfoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'es': instance.es,
      'en': instance.en,
      'unit': instance.unit,
      'computerName': instance.computerName,
    };
