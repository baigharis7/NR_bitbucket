// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_groups.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationGroups _$RecommendationGroupsFromJson(
        Map<String, dynamic> json) =>
    RecommendationGroups(
      recommendationGroups: (json['recommendationGroups'] as List<dynamic>)
          .map((e) => RecommendationGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecommendationGroupsToJson(
        RecommendationGroups instance) =>
    <String, dynamic>{
      'recommendationGroups':
          instance.recommendationGroups.map((e) => e.toJson()).toList(),
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
