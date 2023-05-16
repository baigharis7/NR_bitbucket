// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      foodList: (json['foodList'] as List<dynamic>)
          .map((e) => GroupRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      userNutrients: (json['userNutrients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'foodList': instance.foodList.map((e) => e.toJson()).toList(),
      'userNutrients': instance.userNutrients,
    };

GroupRecommendation _$GroupRecommendationFromJson(Map<String, dynamic> json) =>
    GroupRecommendation(
      json['recGroup'] as int,
      (json['foods'] as List<dynamic>).map((e) => e as int).toList(),
      (json['usualFoods'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$GroupRecommendationToJson(
        GroupRecommendation instance) =>
    <String, dynamic>{
      'recGroup': instance.recGroup,
      'foods': instance.foods,
      'usualFoods': instance.usualFoods,
    };
