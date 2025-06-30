// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_routine_completed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportRoutineCompleted _$SportRoutineCompletedFromJson(
        Map<String, dynamic> json) =>
    SportRoutineCompleted(
      userId: json['userId'] as String?,
      eventId: json['eventId'] as int?,
      eventDate: json['eventDate'] as int?,
      info: (json['info'] as List<dynamic>?)
              ?.map((e) => Info.fromJson(e as Map<String, dynamic>))
              .toList(),
      comment: json['comment'] as String?,
      sportName: json['sportName'] as String?,
      scheduleTime: json['scheduleTime'] as String,
      daysOfWeek: json['daysOfWeek'] as List<int>?,
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$SportRoutineCompletedToJson(
        SportRoutineCompleted instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'info': instance.info?.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
      'sportName': instance.sportName,
      'scheduleTime': instance.scheduleTime,
      'daysOfWeek': instance.daysOfWeek,
      'timeZone': instance.timeZone,
    };

Info _$InfoFromJson(Map<String, dynamic> json) => Info(
      id: json['id'] as num?,
      nameEn: json['name_en'] as String?,
      nameEs: json['name_es'] as String?,
      timeStart: json['timeStart'] as num?,
      intensity: json['intensity'] as num?,
      minutes: json['minutes'] as num?,
    );

Map<String, dynamic> _$InfoToJson(Info instance) => <String, dynamic>{
      'id': instance.id,
      'name_en': instance.nameEn,
      'name_es': instance.nameEs,
      'timeStart': instance.timeStart,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
    };
