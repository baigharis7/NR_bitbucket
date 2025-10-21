// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplements_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplementsInfoResponse _$SupplementsInfoResponseFromJson(Map<String, dynamic> json) =>
    SupplementsInfoResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map(
              (e) => SupplementInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SupplementsInfoResponseToJson(SupplementsInfoResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

SupplementInfoResponse _$SupplementInfoResponse(Map<String, dynamic> json) =>
    SupplementInfoResponse(
      id: json['id'] as int,
      es: json['es'] as String,
      en: json['en'] as String,
      unit: json['unit'] as String,
      computerName: json['computer_name'] as String?,
    );

Map<String, dynamic> _$SupplementInfoResponseToJson(SupplementInfoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'es': instance.es,
      'en': instance.en,
      'unit': instance.unit,
      'computer_name': instance.computerName,
    };
