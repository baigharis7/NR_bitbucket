// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_event_simple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodEventSimple _$FoodEventSimpleFromJson(Map<String, dynamic> json) =>
    FoodEventSimple(
      userId: json['userId'] as String,
      eventDate: json['eventDate'] as int,
      eventId: json['eventId'] as int?,
      foodName: json['foodName'] as String?,
      comment: json['comment'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => FoodInEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>?)
          ?.map((e) => FoodInEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FoodEventSimpleToJson(FoodEventSimple instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'eventId': instance.eventId,
      'foodName': instance.foodName,
      'comment': instance.comment,
      'ingredients': instance.ingredients?.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks?.map((e) => e.toJson()).toList(),
    };

FoodInEvent _$FoodInEventFromJson(Map<String, dynamic> json) => FoodInEvent(
      id: json['id'] as int,
      qty: json['qty'] as int,
      unit: json['unit'] as int,
      cookingMethod: json['cookingMethod'] as int,
      unitsEquivalences: json['unitsEquivalences'] as String?,
    );

Map<String, dynamic> _$FoodInEventToJson(FoodInEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qty': instance.qty,
      'unit': instance.unit,
      'cookingMethod': instance.cookingMethod,
      'unitsEquivalences': instance.unitsEquivalences,
    };
