// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_food_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadFoodFavorite _$UploadFoodFavoriteFromJson(Map<String, dynamic> json) =>
    UploadFoodFavorite(
      userId: json['userId'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => UploadFoodInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>)
          .map((e) => UploadFoodInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      dish: json['dish'] as bool?,
      mealTime: (json['mealTime'] as num).toInt(),
      isRoutine: json['isRoutine'] as bool?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UploadFoodFavoriteToJson(UploadFoodFavorite instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'title': instance.title,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
      'mealTime': instance.mealTime,
      'dish': instance.dish,
      'isRoutine': instance.isRoutine,
      'daysOfWeek': instance.daysOfWeek,
    };

UploadFoodInFavorite _$UploadFoodInFavoriteFromJson(
        Map<String, dynamic> json) =>
    UploadFoodInFavorite(
      id: (json['id'] as num).toInt(),
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      qty: (json['qty'] as num).toInt(),
      unit: (json['unit'] as num).toInt(),
      cookingMethod: (json['cookingMethod'] as num).toInt(),
      conversionFactor: (json['conversionFactor'] as num?)?.toInt(),
      usedOil: (json['usedOil'] as num?)?.toInt(),
      unitsEquivalences: json['unitsEquivalences'] as String?,
    );

Map<String, dynamic> _$UploadFoodInFavoriteToJson(
        UploadFoodInFavorite instance) =>
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
