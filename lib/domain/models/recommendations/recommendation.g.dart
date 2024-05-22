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
      nutrientsInDeficit: (json['nutrientsInDeficit'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'foodList': instance.foodList.map((e) => e.toJson()).toList(),
      'userNutrients': instance.userNutrients,
      'nutrientsInDeficit': instance.nutrientsInDeficit,
    };

GroupRecommendation _$GroupRecommendationFromJson(Map<String, dynamic> json) =>
    GroupRecommendation(
      json['recGroup'] as int,
      (json['objFoods'] as List<dynamic>).map((e) => e as int).toList(),
      (json['deficitFoods'] as List<dynamic>).map((e) => e as int).toList(),
      UsualFoods.fromJson(json['usualFoods'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GroupRecommendationToJson(
        GroupRecommendation instance) =>
    <String, dynamic>{
      'recGroup': instance.recGroup,
      'objFoods': instance.objFoods,
      'deficitFoods': instance.deficitFoods,
      'usualFoods': instance.usualFoods.toJson(),
    };

UsualFoods _$UsualFoodsFromJson(Map<String, dynamic> json) => UsualFoods(
      (json['usualHealthyFoods'] as List<dynamic>?)
          ?.map((e) => UsualFoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['usualUnhealthyFoods'] as List<dynamic>?)
          ?.map((e) => UsualFoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UsualFoodsToJson(UsualFoods instance) =>
    <String, dynamic>{
      'usualHealthyFoods':
          instance.usualHealthyFoods?.map((e) => e.toJson()).toList(),
      'usualUnhealthyFoods':
          instance.usualUnhealthyFoods?.map((e) => e.toJson()).toList(),
    };

UsualFoodItem _$UsualFoodItemFromJson(Map<String, dynamic> json) =>
    UsualFoodItem(
      json['foodId'] as int,
      (json['alternativeUsualHealthyFoods'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      (json['alternativeUsualUnhealthyFoods'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );

Map<String, dynamic> _$UsualFoodItemToJson(UsualFoodItem instance) =>
    <String, dynamic>{
      'foodId': instance.foodId,
      'alternativeUsualHealthyFood': instance.alternativeUsualHealthyFood,
      'alternativeUsualUnhealthyFoods': instance.alternativeUsualUnhealthyFoods,
    };
