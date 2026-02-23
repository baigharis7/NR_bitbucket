// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_files_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MasterFilesResponse _$MasterFilesResponseFromJson(Map<String, dynamic> json) =>
    MasterFilesResponse(
      cookingMethodsResponse: json['cookingMethodsResponse'] == null
          ? null
          : CookingMethodsResponse.fromJson(
              json['cookingMethodsResponse'] as Map<String, dynamic>),
      cookingMethodsInfoResponse: json['cookingMethodsInfoResponse'] == null
          ? null
          : CookingMethodsInfoResponse.fromJson(
              json['cookingMethodsInfoResponse'] as Map<String, dynamic>),
      oilTypesResponse: json['oilTypesResponse'] == null
          ? null
          : OilTypesResponse.fromJson(
              json['oilTypesResponse'] as Map<String, dynamic>),
      conversionFactorsResponse: json['conversionFactorsResponse'] == null
          ? null
          : ConversionFactorsResponse.fromJson(
              json['conversionFactorsResponse'] as Map<String, dynamic>),
      conversionFactorsInfoResponse: json['conversionFactorsInfoResponse'] ==
              null
          ? null
          : ConversionFactorsInfoResponse.fromJson(
              json['conversionFactorsInfoResponse'] as Map<String, dynamic>),
      nutrientsInfoResponse: json['nutrientsInfoResponse'] == null
          ? null
          : NutrientsInfoResponse.fromJson(
              json['nutrientsInfoResponse'] as Map<String, dynamic>),
      foodsAndDrinksNamesResponse: json['foodsAndDrinksNamesResponse'] == null
          ? null
          : FoodsAndDrinksNamesResponse.fromJson(
              json['foodsAndDrinksNamesResponse'] as Map<String, dynamic>),
      objectivesResponse: json['objectivesResponse'] == null
          ? null
          : ObjectivesInfoResponse.fromJson(
              json['objectivesResponse'] as Map<String, dynamic>),
      recommendationGroupsResponse: json['recommendationGroupsResponse'] == null
          ? null
          : RecommendationGroupsResponse.fromJson(
              json['recommendationGroupsResponse'] as Map<String, dynamic>),
      sportsInfoResponse: json['sportsInfoResponse'] == null
          ? null
          : SportsInfoResponse.fromJson(
              json['sportsInfoResponse'] as Map<String, dynamic>),
      unitsInfoResponse: json['unitsInfoResponse'] == null
          ? null
          : UnitsInfoResponse.fromJson(
              json['unitsInfoResponse'] as Map<String, dynamic>),
      unitsFoodsResponse: json['unitsFoodsResponse'] == null
          ? null
          : UnitsFoodsResponse.fromJson(
              json['unitsFoodsResponse'] as Map<String, dynamic>),
      supplementsInfoResponse: json['supplementsInfoResponse'] == null
          ? null
          : SupplementsInfoResponse.fromJson(
              json['supplementsInfoResponse'] as Map<String, dynamic>),
      subjectiveAnalysisResponse: json['subjectiveAnalysisResponse'] == null
          ? null
          : SubjectiveAnalysisListResponse.fromJson(
              json['subjectiveAnalysisResponse'] as Map<String, dynamic>),
      cookingMethodsOilsInfoResponse: json['cookingMethodsOilsInfoResponse'] ==
              null
          ? null
          : CookingMethodsOilsInfoResponse.fromJson(
              json['cookingMethodsOilsInfoResponse'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MasterFilesResponseToJson(
        MasterFilesResponse instance) =>
    <String, dynamic>{
      'cookingMethodsResponse': instance.cookingMethodsResponse?.toJson(),
      'cookingMethodsInfoResponse':
          instance.cookingMethodsInfoResponse?.toJson(),
      'oilTypesResponse': instance.oilTypesResponse?.toJson(),
      'conversionFactorsResponse': instance.conversionFactorsResponse?.toJson(),
      'conversionFactorsInfoResponse':
          instance.conversionFactorsInfoResponse?.toJson(),
      'nutrientsInfoResponse': instance.nutrientsInfoResponse?.toJson(),
      'foodsAndDrinksNamesResponse':
          instance.foodsAndDrinksNamesResponse?.toJson(),
      'objectivesResponse': instance.objectivesResponse?.toJson(),
      'recommendationGroupsResponse':
          instance.recommendationGroupsResponse?.toJson(),
      'sportsInfoResponse': instance.sportsInfoResponse?.toJson(),
      'unitsInfoResponse': instance.unitsInfoResponse?.toJson(),
      'unitsFoodsResponse': instance.unitsFoodsResponse?.toJson(),
      'supplementsInfoResponse': instance.supplementsInfoResponse?.toJson(),
      'subjectiveAnalysisResponse':
          instance.subjectiveAnalysisResponse?.toJson(),
      'cookingMethodsOilsInfoResponse':
          instance.cookingMethodsOilsInfoResponse?.toJson(),
    };
