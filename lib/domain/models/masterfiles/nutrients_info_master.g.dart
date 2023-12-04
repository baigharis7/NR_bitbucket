// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrients_info_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutrientsInfoMaster _$NutrientsInfoMasterFromJson(Map<String, dynamic> json) =>
    NutrientsInfoMaster(
      nutrientsInfo: (json['nutrientsInfo'] as List<dynamic>)
          .map((e) => NutrientInfoMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NutrientsInfoMasterToJson(
        NutrientsInfoMaster instance) =>
    <String, dynamic>{
      'nutrientsInfo': instance.nutrientsInfo.map((e) => e.toJson()).toList(),
    };

NutrientInfoMaster _$NutrientInfoMasterFromJson(Map<String, dynamic> json) =>
    NutrientInfoMaster(
      officialName: json['officialName'] as String,
      unit: json['unit'] as String,
      en: json['en'] as String,
      es: json['es'] as String,
      description_es: json['description_es'] as String?,
      description_en: json['description_en'] as String?,
    );

Map<String, dynamic> _$NutrientInfoMasterToJson(NutrientInfoMaster instance) =>
    <String, dynamic>{
      'officialName': instance.officialName,
      'unit': instance.unit,
      'en': instance.en,
      'es': instance.es,
      'description_es': instance.description_es,
      'description_en': instance.description_en,
    };
