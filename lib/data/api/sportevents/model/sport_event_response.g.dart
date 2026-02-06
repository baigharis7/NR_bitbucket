// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportEventResponse _$SportEventResponseFromJson(Map<String, dynamic> json) =>
    SportEventResponse(
      userId: json['userId'] as String,
      eventId: (json['eventId'] as num).toInt(),
      eventDate: (json['eventDate'] as num).toInt(),
      comment: json['comment'] as String?,
      sportName: json['sportName'] as String?,
      info: (json['info'] as List<dynamic>?)
          ?.map(
              (e) => SportEventInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventKcal: (json['eventKcal'] as num?)?.toInt(),
      source: json['source'] as String?,
    );

Map<String, dynamic> _$SportEventResponseToJson(SportEventResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'comment': instance.comment,
      'sportName': instance.sportName,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'eventKcal': instance.eventKcal,
      'source': instance.source,
    };

SportEventInfoResponse _$SportEventInfoResponseFromJson(
        Map<String, dynamic> json) =>
    SportEventInfoResponse(
      id: (json['id'] as num).toInt(),
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      intensity: (json['intensity'] as num?)?.toInt(),
      minutes: (json['minutes'] as num).toInt(),
      timeStart: (json['timeStart'] as num?)?.toInt(),
      kcal: (json['kcal'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      avgHeartRate: (json['avgHeartRate'] as num?)?.toInt(),
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
      'distance': instance.distance,
      'avgHeartRate': instance.avgHeartRate,
    };
