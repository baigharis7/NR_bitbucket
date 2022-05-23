// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsInfoEntity _$CookingMethodsInfoEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsInfoEntity(
      id: json['id'] as int,
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              CookingMethodInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsInfoEntityToJson(
        CookingMethodsInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

CookingMethodInfoEntity _$CookingMethodInfoEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodInfoEntity(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$CookingMethodInfoEntityToJson(
        CookingMethodInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
