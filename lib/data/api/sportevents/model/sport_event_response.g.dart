// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportEventResponse _$SportEventResponseFromJson(Map<String, dynamic> json) =>
    SportEventResponse(
      userId: json['userId'] as String,
      eventId: json['eventId'] as int,
      comment: json['comment'] as String?,
      info:
          SportEventInfoResponse.fromJson(json['info'] as Map<String, dynamic>),
      eventKcal: json['eventKcal'] as int?,
    );

Map<String, dynamic> _$SportEventResponseToJson(SportEventResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'comment': instance.comment,
      'info': instance.info.toJson(),
      'eventKcal': instance.eventKcal,
    };

SportEventInfoResponse _$SportEventInfoResponseFromJson(
        Map<String, dynamic> json) =>
    SportEventInfoResponse(
      id: json['id'] as int,
      name_en: json['name_en'] as String,
      name_es: json['name_es'] as String,
      intensity: json['intensity'] as int,
      minutes: json['minutes'] as int,
      kcal: json['kcal'] as int,
    );

Map<String, dynamic> _$SportEventInfoResponseToJson(
        SportEventInfoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'kcal': instance.kcal,
    };
