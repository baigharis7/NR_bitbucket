// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_groups_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationGroupsEntity _$RecommendationGroupsEntityFromJson(
        Map<String, dynamic> json) =>
    RecommendationGroupsEntity(
      id: json['id'] as int,
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              RecommendationGroupEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecommendationGroupsEntityToJson(
        RecommendationGroupsEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

RecommendationGroupEntity _$RecommendationGroupEntityFromJson(
        Map<String, dynamic> json) =>
    RecommendationGroupEntity(
      id: json['id'] as int,
      groups:
          (json['groups'] as List<dynamic>).map((e) => e as String).toList(),
      size: json['size'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$RecommendationGroupEntityToJson(
        RecommendationGroupEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groups': instance.groups,
      'size': instance.size,
      'en': instance.en,
      'es': instance.es,
    };
