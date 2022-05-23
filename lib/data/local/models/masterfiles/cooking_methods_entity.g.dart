// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking_methods_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CookingMethodsEntity _$CookingMethodsEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodsEntity(
      id: json['id'] as int,
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              CookingMethodGroupEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookingMethodsEntityToJson(
        CookingMethodsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

CookingMethodGroupEntity _$CookingMethodGroupEntityFromJson(
        Map<String, dynamic> json) =>
    CookingMethodGroupEntity(
      g: json['g'] as String,
      m: (json['m'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$CookingMethodGroupEntityToJson(
        CookingMethodGroupEntity instance) =>
    <String, dynamic>{
      'g': instance.g,
      'm': instance.m,
    };
