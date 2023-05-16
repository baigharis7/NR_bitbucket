// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liquid_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiquidFavorite _$LiquidFavoriteFromJson(Map<String, dynamic> json) =>
    LiquidFavorite(
      title: json['title'] as String,
      eventDate: json['eventDate'] as int,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => LiquidInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>)
          .map((e) => LiquidInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      mealTime: json['mealTime'] as int,
    );

Map<String, dynamic> _$LiquidFavoriteToJson(LiquidFavorite instance) =>
    <String, dynamic>{
      'title': instance.title,
      'eventDate': instance.eventDate,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
      'mealTime': instance.mealTime,
    };

LiquidInFavorite _$LiquidInFavoriteFromJson(Map<String, dynamic> json) =>
    LiquidInFavorite(
      id: json['id'] as int,
      name_en: json['name_en'] as String,
      name_es: json['name_es'] as String,
      qty: json['qty'] as int,
      unit: json['unit'] as int,
      cookingMethod: json['cookingMethod'] as int,
      unitsEquivalences: json['unitsEquivalences'] as String?,
    );

Map<String, dynamic> _$LiquidInFavoriteToJson(LiquidInFavorite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'qty': instance.qty,
      'unit': instance.unit,
      'cookingMethod': instance.cookingMethod,
      'unitsEquivalences': instance.unitsEquivalences,
    };
