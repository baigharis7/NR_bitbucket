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
      eventKcal: json['eventKcal'] as int?,
    );

Map<String, dynamic> _$SportEventCompleteToJson(SportEventComplete instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'info': instance.info.toJson(),
      'eventKcal': instance.eventKcal,
    };

SportEventInfo _$SportEventInfoFromJson(Map<String, dynamic> json) =>
    SportEventInfo(
      id: json['id'] as int,
      name_en: json['name_en'] as String,
      name_es: json['name_es'] as String,
      intensity: json['intensity'] as int,
      minutes: json['minutes'] as int,
      kcal: json['kcal'] as int,
    );

Map<String, dynamic> _$SportEventInfoToJson(SportEventInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'kcal': instance.kcal,
    };
