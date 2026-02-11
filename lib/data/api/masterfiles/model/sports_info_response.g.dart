// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sports_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportsInfoResponse _$SportsInfoResponseFromJson(Map<String, dynamic> json) =>
    SportsInfoResponse(
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => SportInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SportsInfoResponseToJson(SportsInfoResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

SportInfoResponse _$SportInfoResponseFromJson(Map<String, dynamic> json) =>
    SportInfoResponse(
      id: (json['id'] as num).toInt(),
      en: json['en'] as String,
      es: json['es'] as String,
      mets: (json['mets'] as num).toInt(),
    );

Map<String, dynamic> _$SportInfoResponseToJson(SportInfoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'mets': instance.mets,
    };
