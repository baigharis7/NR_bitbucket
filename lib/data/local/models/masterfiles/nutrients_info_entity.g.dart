// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrients_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NutrientsInfoEntity _$NutrientsInfoEntityFromJson(Map<String, dynamic> json) =>
    NutrientsInfoEntity(
      id: json['id'] as int,
      name: json['name'] as String,
      unit: json['unit'] as String,
      es: json['es'] as String,
      en: json['en'] as String,
    );

Map<String, dynamic> _$NutrientsInfoEntityToJson(
        NutrientsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'unit': instance.unit,
      'es': instance.es,
      'en': instance.en,
    };
