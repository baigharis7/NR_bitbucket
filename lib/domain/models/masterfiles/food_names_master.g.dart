// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_names_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodsAndDrinksNamesMaster _$FoodsAndDrinksNamesMasterFromJson(
        Map<String, dynamic> json) =>
    FoodsAndDrinksNamesMaster(
      json['foodsAndDrinksNames'] == null
          ? null
          : FoodsAndDrinkListsMaster.fromJson(
              json['foodsAndDrinksNames'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FoodsAndDrinksNamesMasterToJson(
        FoodsAndDrinksNamesMaster instance) =>
    <String, dynamic>{
      'foodsAndDrinksNames': instance.foodsAndDrinksNames?.toJson(),
    };

FoodsAndDrinkListsMaster _$FoodsAndDrinkListsMasterFromJson(
        Map<String, dynamic> json) =>
    FoodsAndDrinkListsMaster(
      foodNames: (json['foodNames'] as List<dynamic>?)
          ?.map((e) => FoodItemMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinkNames: (json['drinkNames'] as List<dynamic>?)
          ?.map((e) => FoodItemMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FoodsAndDrinkListsMasterToJson(
        FoodsAndDrinkListsMaster instance) =>
    <String, dynamic>{
      'foodNames': instance.foodNames?.map((e) => e.toJson()).toList(),
      'drinkNames': instance.drinkNames?.map((e) => e.toJson()).toList(),
    };

FoodItemMaster _$FoodItemMasterFromJson(Map<String, dynamic> json) =>
    FoodItemMaster(
      id: json['id'] as int?,
      en: json['en'] as String?,
      es: json['es'] as String?,
      group: json['group'] as String?,
      units: json['units'] as String?,
    );

Map<String, dynamic> _$FoodItemMasterToJson(FoodItemMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'group': instance.group,
      'units': instance.units,
    };
