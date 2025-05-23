// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodFavorite _$FoodFavoriteFromJson(Map<String, dynamic> json) => FoodFavorite(
      title: json['title'] as String,
      eventDate: json['eventDate'] as int,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => FoodInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>)
          .map((e) => FoodInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      mealTime: json['mealTime'] as int,
      dish: json['dish'] as bool?,
    );

Map<String, dynamic> _$FoodFavoriteToJson(FoodFavorite instance) =>
    <String, dynamic>{
      'title': instance.title,
      'eventDate': instance.eventDate,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
      'mealTime': instance.mealTime,
      'dish': instance.dish,
    };

FoodInFavorite _$FoodInFavoriteFromJson(Map<String, dynamic> json) =>
    FoodInFavorite(
      id: json['id'] as int,
      name_en: json['name_en'] as String,
      name_es: json['name_es'] as String,
      qty: json['qty'] as int,
      unit: json['unit'] as int,
      conversionFactor: json['conversionFactor'] as int?,
      usedOil: json['usedOil'] as int?,
      cookingMethod: json['cookingMethod'] as int,
      unitsEquivalences: json['unitsEquivalences'] as String?,
    );

Map<String, dynamic> _$FoodInFavoriteToJson(FoodInFavorite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'qty': instance.qty,
      'unit': instance.unit,
      'conversionFactor': instance.conversionFactor,
      'usedOil': instance.usedOil,
      'cookingMethod': instance.cookingMethod,
      'unitsEquivalences': instance.unitsEquivalences,
    };
