// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrients_info_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutrientsInfoMaster _$NutrientsInfoMasterFromJson(Map<String, dynamic> json) =>
    NutrientsInfoMaster(
      data: (json['data'] as List<dynamic>)
          .map((e) => NutrientInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NutrientsInfoMasterToJson(
        NutrientsInfoMaster instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

NutrientInfo _$NutrientInfoFromJson(Map<String, dynamic> json) => NutrientInfo(
      officialName: json['officialName'] as String,
      unit: json['unit'] as String,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$NutrientInfoToJson(NutrientInfo instance) =>
    <String, dynamic>{
      'officialName': instance.officialName,
      'unit': instance.unit,
      'en': instance.en,
      'es': instance.es,
    };
