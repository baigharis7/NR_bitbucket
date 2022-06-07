// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrients_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutrientsInfoResponse _$NutrientsInfoResponseFromJson(
        Map<String, dynamic> json) =>
    NutrientsInfoResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => NutrientInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NutrientsInfoResponseToJson(
        NutrientsInfoResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

NutrientInfoResponse _$NutrientInfoResponseFromJson(
        Map<String, dynamic> json) =>
    NutrientInfoResponse(
      name: json['name'] as String,
      unit: json['unit'] as String,
      es: json['es'] as String,
      en: json['en'] as String,
    );

Map<String, dynamic> _$NutrientInfoResponseToJson(
        NutrientInfoResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'unit': instance.unit,
      'es': instance.es,
      'en': instance.en,
    };
