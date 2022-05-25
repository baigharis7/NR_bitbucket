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
          : FoodsAndDrinksNames.fromJson(
              json['foodsAndDrinksNames'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FoodsAndDrinksNamesMasterToJson(
        FoodsAndDrinksNamesMaster instance) =>
    <String, dynamic>{
      'foodsAndDrinksNames': instance.foodsAndDrinksNames?.toJson(),
    };

FoodsAndDrinksNames _$FoodsAndDrinksNamesFromJson(Map<String, dynamic> json) =>
    FoodsAndDrinksNames(
      json['v'] as int?,
      json['data'] == null
          ? null
          : FoodsAndDrinkListsMaster.fromJson(
              json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FoodsAndDrinksNamesToJson(
        FoodsAndDrinksNames instance) =>
    <String, dynamic>{
      'v': instance.v,
      'data': instance.data?.toJson(),
    };

FoodsAndDrinkListsMaster _$FoodsAndDrinkListsMasterFromJson(
        Map<String, dynamic> json) =>
    FoodsAndDrinkListsMaster(
      (json['foodNames'] as List<dynamic>?)
          ?.map((e) => FoodItemMaster.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['drinkNames'] as List<dynamic>?)
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
      json['id'] as int?,
      json['en'] as String?,
      json['es'] as String?,
      json['group'] as String?,
    );

Map<String, dynamic> _$FoodItemMasterToJson(FoodItemMaster instance) =>
    <String, dynamic>{
      'id': instance.id,
      'en': instance.en,
      'es': instance.es,
      'group': instance.group,
    };
