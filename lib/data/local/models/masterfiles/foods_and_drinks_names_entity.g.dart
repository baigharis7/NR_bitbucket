// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foods_and_drinks_names_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodsAndDrinksNamesEntity _$FoodsAndDrinksNamesEntityFromJson(
        Map<String, dynamic> json) =>
    FoodsAndDrinksNamesEntity(
      id: json['id'] as int,
      v: json['v'] as int,
      data: FoodsAndDrinkListsEntity.fromJson(
          json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FoodsAndDrinksNamesEntityToJson(
        FoodsAndDrinksNamesEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      'data': instance.data.toJson(),
    };

FoodsAndDrinkListsEntity _$FoodsAndDrinkListsEntityFromJson(
        Map<String, dynamic> json) =>
    FoodsAndDrinkListsEntity(
      foodNames: (json['foodNames'] as List<dynamic>)
          .map((e) => FoodItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinkNames: (json['drinkNames'] as List<dynamic>)
          .map((e) => FoodItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FoodsAndDrinkListsEntityToJson(
        FoodsAndDrinkListsEntity instance) =>
    <String, dynamic>{
      'foodNames': instance.foodNames.map((e) => e.toJson()).toList(),
      'drinkNames': instance.drinkNames.map((e) => e.toJson()).toList(),
    };

FoodItemEntity _$FoodItemEntityFromJson(Map<String, dynamic> json) =>
    FoodItemEntity(
      id: json['id'] as int,
      en: json['en'] as String,
      es: json['es'] as String,
      g: json['g'] as String,
    );

Map<String, dynamic> _$FoodItemEntityToJson(FoodItemEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'g': instance.g,
    };
