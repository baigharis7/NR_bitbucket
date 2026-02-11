// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_groups_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationGroupsResponse _$RecommendationGroupsResponseFromJson(
        Map<String, dynamic> json) =>
    RecommendationGroupsResponse(
      v: (json['v'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              RecommendationGroupResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecommendationGroupsResponseToJson(
        RecommendationGroupsResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

RecommendationGroupResponse _$RecommendationGroupResponseFromJson(
        Map<String, dynamic> json) =>
    RecommendationGroupResponse(
      id: (json['id'] as num).toInt(),
      groups:
          (json['groups'] as List<dynamic>).map((e) => e as String).toList(),
      size: (json['size'] as num).toInt(),
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$RecommendationGroupResponseToJson(
        RecommendationGroupResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groups': instance.groups,
      'size': instance.size,
      'en': instance.en,
      'es': instance.es,
    };
