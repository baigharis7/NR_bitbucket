// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_food_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadFoodFavorite _$UploadFoodFavoriteFromJson(Map<String, dynamic> json) =>
    UploadFoodFavorite(
      userId: json['userId'] as String,
      eventDate: json['eventDate'] as int,
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => UploadFoodInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>)
          .map((e) => UploadFoodInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      mealTime: json['mealTime'] as int,
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
    };

UploadFoodInFavorite _$UploadFoodInFavoriteFromJson(
        Map<String, dynamic> json) =>
    UploadFoodInFavorite(
      id: json['id'] as int,
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      qty: json['qty'] as int,
      unit: json['unit'] as int,
      cookingMethod: json['cookingMethod'] as int,
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
      'cookingMethod': instance.cookingMethod,
      'unitsEquivalences': instance.unitsEquivalences,
    };
