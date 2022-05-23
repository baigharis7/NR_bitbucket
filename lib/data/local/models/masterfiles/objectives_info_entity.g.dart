// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objectives_info_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObjectivesInfoEntity _$ObjectivesInfoEntityFromJson(
        Map<String, dynamic> json) =>
    ObjectivesInfoEntity(
      id: json['id'] as int,
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => ObjectiveInfoEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ObjectivesInfoEntityToJson(
        ObjectivesInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

ObjectiveInfoEntity _$ObjectiveInfoEntityFromJson(Map<String, dynamic> json) =>
    ObjectiveInfoEntity(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$ObjectiveInfoEntityToJson(
        ObjectiveInfoEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
    };
