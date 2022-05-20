// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_received.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationReceived _$RecommendationReceivedFromJson(
        Map<String, dynamic> json) =>
    RecommendationReceived(
      (json['foodList'] as List<dynamic>)
          .map((e) => GroupRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['userNutrients'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RecommendationReceivedToJson(
        RecommendationReceived instance) =>
    <String, dynamic>{
      'foodList': instance.foodList.map((e) => e.toJson()).toList(),
      'userNutrients': instance.userNutrients,
    };

GroupRecommendation _$GroupRecommendationFromJson(Map<String, dynamic> json) =>
    GroupRecommendation(
      json['recGroup'] as int,
      (json['foods'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$GroupRecommendationToJson(
        GroupRecommendation instance) =>
    <String, dynamic>{
      'recGroup': instance.recGroup,
      'foods': instance.foods,
    };
