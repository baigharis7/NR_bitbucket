// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealTime _$MealTimeFromJson(Map<String, dynamic> json) => MealTime(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      time: json['time'] as String?,
    );

Map<String, dynamic> _$MealTimeToJson(MealTime instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'time': instance.time,
    };
