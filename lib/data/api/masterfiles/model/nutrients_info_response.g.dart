// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrients_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutrientsInfoResponse _$NutrientsInfoResponseFromJson(
        Map<String, dynamic> json) =>
    NutrientsInfoResponse(
      name: json['name'] as String,
      unit: json['unit'] as String,
      es: json['es'] as String,
      en: json['en'] as String,
    );

Map<String, dynamic> _$NutrientsInfoResponseToJson(
        NutrientsInfoResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'unit': instance.unit,
      'es': instance.es,
      'en': instance.en,
    };
