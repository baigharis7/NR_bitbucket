// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodFavorite _$FoodFavoriteFromJson(Map<String, dynamic> json) => FoodFavorite(
      userId: json['userId'] as String?,
      eventId: (json['eventId'] as num?)?.toInt(),
      eventDate: (json['eventDate'] as num?)?.toInt(),
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => FoodInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>)
          .map((e) => FoodInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      mealTime: (json['mealTime'] as num?)?.toInt(),
      dish: json['dish'] as bool?,
      isRoutine: json['isRoutine'] as bool?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      time: json['time'] as String?,
      timeZone: json['timeZone'] as String?,
      isFavorite: json['isFavorite'] as bool?,
    );

Map<String, dynamic> _$FoodFavoriteToJson(FoodFavorite instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks.map((e) => e.toJson()).toList(),
      'title': instance.title,
      'comment': instance.comment,
      'mealTime': instance.mealTime,
      'dish': instance.dish,
      'isRoutine': instance.isRoutine,
      'daysOfWeek': instance.daysOfWeek,
      'time': instance.time,
      'timeZone': instance.timeZone,
      'isFavorite': instance.isFavorite,
    };

FoodInFavorite _$FoodInFavoriteFromJson(Map<String, dynamic> json) =>
    FoodInFavorite(
      id: (json['id'] as num).toInt(),
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      qty: (json['qty'] as num).toInt(),
      unit: (json['unit'] as num).toInt(),
      conversionFactor: (json['conversionFactor'] as num?)?.toInt(),
      usedOil: (json['usedOil'] as num?)?.toInt(),
      cookingMethod: (json['cookingMethod'] as num).toInt(),
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
