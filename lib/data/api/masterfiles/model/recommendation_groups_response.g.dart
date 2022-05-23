// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_groups_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationGroupsResponse _$RecommendationGroupsResponseFromJson(
        Map<String, dynamic> json) =>
    RecommendationGroupsResponse(
      v: json['v'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => RecommendationGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecommendationGroupsResponseToJson(
        RecommendationGroupsResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

RecommendationGroup _$RecommendationGroupFromJson(Map<String, dynamic> json) =>
    RecommendationGroup(
      id: json['id'] as int,
      groups:
          (json['groups'] as List<dynamic>).map((e) => e as String).toList(),
      size: json['size'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
    );

Map<String, dynamic> _$RecommendationGroupToJson(
        RecommendationGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groups': instance.groups,
      'size': instance.size,
      'en': instance.en,
      'es': instance.es,
    };
