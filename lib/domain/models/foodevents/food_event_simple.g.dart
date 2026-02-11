// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_event_simple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodEventSimple _$FoodEventSimpleFromJson(Map<String, dynamic> json) =>
    FoodEventSimple(
      userId: json['userId'] as String,
      eventDate: (json['eventDate'] as num).toInt(),
      eventId: (json['eventId'] as num?)?.toInt(),
      mealType: (json['mealType'] as num?)?.toInt(),
      foodName: json['foodName'] as String?,
      comment: json['comment'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => FoodInEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>?)
          ?.map((e) => FoodInEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      dish: json['dish'] as bool?,
    );

Map<String, dynamic> _$FoodEventSimpleToJson(FoodEventSimple instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'eventId': instance.eventId,
      'mealType': instance.mealType,
      'foodName': instance.foodName,
      'comment': instance.comment,
      'ingredients': instance.ingredients?.map((e) => e.toJson()).toList(),
      'drinks': instance.drinks?.map((e) => e.toJson()).toList(),
      'dish': instance.dish,
    };

FoodInEvent _$FoodInEventFromJson(Map<String, dynamic> json) => FoodInEvent(
      id: (json['id'] as num).toInt(),
      qty: (json['qty'] as num).toInt(),
      unit: (json['unit'] as num).toInt(),
      conversionFactor: (json['conversionFactor'] as num?)?.toInt(),
      cookingMethod: (json['cookingMethod'] as num).toInt(),
      usedOil: (json['usedOil'] as num?)?.toInt(),
      unitsEquivalences: json['unitsEquivalences'] as String?,
    );

Map<String, dynamic> _$FoodInEventToJson(FoodInEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qty': instance.qty,
      'unit': instance.unit,
      'conversionFactor': instance.conversionFactor,
      'cookingMethod': instance.cookingMethod,
      'usedOil': instance.usedOil,
      'unitsEquivalences': instance.unitsEquivalences,
    };
