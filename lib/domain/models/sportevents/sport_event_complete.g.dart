// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_event_complete.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportEventComplete _$SportEventCompleteFromJson(Map<String, dynamic> json) =>
    SportEventComplete(
      userId: json['userId'] as String,
      eventDate: json['eventDate'] as int,
      info: SportEventInfo.fromJson(json['info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SportEventCompleteToJson(SportEventComplete instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'info': instance.info.toJson(),
    };

SportEventInfo _$SportEventInfoFromJson(Map<String, dynamic> json) =>
    SportEventInfo(
      id: json['id'] as int,
      intensity: json['intensity'] as int,
      minutes: json['minutes'] as int,
      kcal: json['kcal'] as int,
    );

Map<String, dynamic> _$SportEventInfoToJson(SportEventInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'kcal': instance.kcal,
    };
