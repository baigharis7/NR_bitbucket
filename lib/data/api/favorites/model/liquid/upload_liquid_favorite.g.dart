// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_liquid_favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadLiquidFavorite _$UploadLiquidFavoriteFromJson(
        Map<String, dynamic> json) =>
    UploadLiquidFavorite(
      userId: json['userId'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
      title: json['title'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map(
              (e) => UploadLiquidInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>)
          .map(
              (e) => UploadLiquidInFavorite.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      mealTime: (json['mealTime'] as num).toInt(),
    );

Map<String, dynamic> _$UploadLiquidFavoriteToJson(
        UploadLiquidFavorite instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'title': instance.title,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
      'mealTime': instance.mealTime,
    };

UploadLiquidInFavorite _$UploadLiquidInFavoriteFromJson(
        Map<String, dynamic> json) =>
    UploadLiquidInFavorite(
      id: (json['id'] as num).toInt(),
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      qty: (json['qty'] as num).toInt(),
      unit: (json['unit'] as num).toInt(),
      cookingMethod: (json['cookingMethod'] as num).toInt(),
      unitsEquivalences: json['unitsEquivalences'] as String?,
    );

Map<String, dynamic> _$UploadLiquidInFavoriteToJson(
        UploadLiquidInFavorite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'qty': instance.qty,
      'unit': instance.unit,
      'cookingMethod': instance.cookingMethod,
      'unitsEquivalences': instance.unitsEquivalences,
    };
