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
      sportName: json['sportName'] as String?,
      info: (json['info'] as List<dynamic>?)
          ?.map(
              (e) => SportEventInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventKcal: json['eventKcals'] as int?,
    );

Map<String, dynamic> _$SportEventResponseToJson(SportEventResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'comment': instance.comment,
      'sportName': instance.sportName,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'eventKcals': instance.eventKcal,
    };

SportEventInfoResponse _$SportEventInfoResponseFromJson(
        Map<String, dynamic> json) =>
    SportEventInfoResponse(
      id: json['id'] as int,
      name_en: json['name_en'] as String,
      name_es: json['name_es'] as String,
      intensity: json['intensity'] as int,
      minutes: json['minutes'] as int,
      timeStart: json['timeStart'] as int,
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
      'timeStart': instance.timeStart,
      'kcal': instance.kcal,
    };
