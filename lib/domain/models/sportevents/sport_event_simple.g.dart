// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_event_simple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportEventSimple _$SportEventSimpleFromJson(Map<String, dynamic> json) =>
    SportEventSimple(
      userId: json['userId'] as String?,
      eventId: json['eventId'] as int?,
      eventDate: json['eventDate'] as int?,
      info: (json['info'] as List<dynamic>?)
          ?.map((e) => SportInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      sportName: json['sportName'] as String?,
    );

Map<String, dynamic> _$SportEventSimpleToJson(SportEventSimple instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
      'sportName': instance.sportName,
    };

SportInfo _$SportInfoFromJson(Map<String, dynamic> json) => SportInfo(
      id: json['id'] as int?,
      name_en: json['name_en'] as String?,
      name_es: json['name_es'] as String?,
      timeStart: json['timeStart'] as int?,
      intensity: json['intensity'] as int?,
      minutes: json['minutes'] as int?,
    );

Map<String, dynamic> _$SportInfoToJson(SportInfo instance) => <String, dynamic>{
      'id': instance.id,
      'name_en': instance.name_en,
      'name_es': instance.name_es,
      'timeStart': instance.timeStart,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
    };
