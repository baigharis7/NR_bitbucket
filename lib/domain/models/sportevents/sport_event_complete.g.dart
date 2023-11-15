// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_event_complete.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportEventComplete _$SportEventCompleteFromJson(Map<String, dynamic> json) =>
    SportEventComplete(
      userId: json['userId'] as String,
      eventDate: json['eventId'] as int,
      comment: json['comment'] as String?,
          sportName: json['sportName'] as String?,
      info:(json['info'] as List<dynamic>?)
          ?.map((e) => SportEventInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventKcals: json['eventKcals'] as int?,
    );

Map<String, dynamic> _$SportEventCompleteToJson(SportEventComplete instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'comment': instance.comment,
      'sportName': instance.comment,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'eventKcals': instance.eventKcals,
    };

SportEventInfo _$SportEventInfoFromJson(Map<String, dynamic> json) =>
    SportEventInfo(
      id: json['id'] as int,
      name_en: json['name_en'] as String,
      name_es: json['name_es'] as String,
      intensity: json['intensity'] as int,
      minutes: json['minutes'] as int,
      timeStart: json['timeStart'] as int,
      kcal: json['kcal'] as int,
    );

Map<String, dynamic> _$SportEventInfoToJson(SportEventInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'timeStart': instance.timeStart,
      'kcal': instance.kcal,
    };
