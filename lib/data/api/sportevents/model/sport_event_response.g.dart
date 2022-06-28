// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportEventResponse _$SportEventResponseFromJson(Map<String, dynamic> json) =>
    SportEventResponse(
      userId: json['userId'] as String,
      eventDate: json['eventDate'] as int,
      info:
          SportEventInfoResponse.fromJson(json['info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SportEventResponseToJson(SportEventResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventDate': instance.eventDate,
      'info': instance.info.toJson(),
    };

SportEventInfoResponse _$SportEventInfoResponseFromJson(
        Map<String, dynamic> json) =>
    SportEventInfoResponse(
      id: json['id'] as int,
      intensity: json['intensity'] as int,
      minutes: json['minutes'] as int,
      kcal: json['kcal'] as int,
    );

Map<String, dynamic> _$SportEventInfoResponseToJson(
        SportEventInfoResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
      'kcal': instance.kcal,
    };
