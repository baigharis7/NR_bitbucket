// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_routine_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodRoutineEvent _$FoodRoutineEventFromJson(Map<String, dynamic> json) =>
    FoodRoutineEvent(
      userId: json['userId'] as String,
      eventDate: json['eventDate'] as int,
      eventId: json['eventId'] as int?,
      mealType: json['mealType'] as int?,
      foodName: json['foodName'] as String?,
      comment: json['comment'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => FoodRoutineInEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>?)
          ?.map((e) => FoodRoutineInEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      dish: json['dish'] as bool?,
      isRoutine: json['isRoutine'] as bool?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      time: json['time'] as String?,
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$FoodRoutineEventToJson(FoodRoutineEvent instance) =>
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
      'isRoutine': instance.isRoutine,
      'daysOfWeek': instance.daysOfWeek,
      'time': instance.time,
      'timeZone': instance.timeZone,
    };

FoodRoutineInEvent _$FoodRoutineInEventFromJson(Map<String, dynamic> json) => FoodRoutineInEvent(
      id: json['id'] as int,
      qty: json['qty'] as int,
      unit: json['unit'] as int,
      conversionFactor: json['conversionFactor'] as int?,
      cookingMethod: json['cookingMethod'] as int,
      usedOil: json['usedOil'] as int?,
      unitsEquivalences: json['unitsEquivalences'] as String?,
    );

Map<String, dynamic> _$FoodRoutineInEventToJson(FoodRoutineInEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qty': instance.qty,
      'unit': instance.unit,
      'conversionFactor': instance.conversionFactor,
      'cookingMethod': instance.cookingMethod,
      'usedOil': instance.usedOil,
      'unitsEquivalences': instance.unitsEquivalences,
    };
