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
      officialName: json['officialName'] as String,
      unit: json['unit'] as String,
      name_es: json['name_es'] as String,
      name_en: json['name_en'] as String,
    );

Map<String, dynamic> _$NutrientInfoResponseToJson(
        NutrientInfoResponse instance) =>
    <String, dynamic>{
      'officialName': instance.officialName,
      'unit': instance.unit,
      'name_es': instance.name_es,
      'name_en': instance.name_en,
    };
