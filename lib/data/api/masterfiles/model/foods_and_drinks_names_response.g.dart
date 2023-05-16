// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foods_and_drinks_names_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodsAndDrinksNamesResponse _$FoodsAndDrinksNamesResponseFromJson(
        Map<String, dynamic> json) =>
    FoodsAndDrinksNamesResponse(
      v: json['v'] as int,
      data: FoodsAndDrinkListsResponse.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FoodsAndDrinksNamesResponseToJson(
        FoodsAndDrinksNamesResponse instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data.toJson(),
    };

FoodsAndDrinkListsResponse _$FoodsAndDrinkListsResponseFromJson(
        Map<String, dynamic> json) =>
    FoodsAndDrinkListsResponse(
      foodNames: (json['foodNames'] as List<dynamic>)
          .map((e) => FoodItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinkNames: (json['drinkNames'] as List<dynamic>)
          .map((e) => FoodItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FoodsAndDrinkListsResponseToJson(
        FoodsAndDrinkListsResponse instance) =>
    <String, dynamic>{
      'foodNames': instance.foodNames.map((e) => e.toJson()).toList(),
      'drinkNames': instance.drinkNames.map((e) => e.toJson()).toList(),
    };

FoodItemResponse _$FoodItemResponseFromJson(Map<String, dynamic> json) =>
    FoodItemResponse(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
      g: json['g'] as String,
      units: json['units'] as String?,
    );

Map<String, dynamic> _$FoodItemResponseToJson(FoodItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'g': instance.g,
      'units': instance.units,
    };
