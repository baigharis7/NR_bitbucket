// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_routine_completed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportRoutineCompleted _$SportRoutineCompletedFromJson(
        Map<String, dynamic> json) =>
    SportRoutineCompleted(
      userId: json['userId'] as String?,
      eventId: (json['eventId'] as num?)?.toInt(),
      eventDate: (json['eventDate'] as num?)?.toInt(),
      info: (json['info'] as List<dynamic>?)
          ?.map((e) => Info.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
      sportName: json['sportName'] as String?,
      scheduleTime: json['scheduleTime'] as String?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      timeZone: json['timeZone'] as String?,
      isRoutine: json['isRoutine'] as bool?,
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
      'isRoutine': instance.isRoutine,
    };

Info _$InfoFromJson(Map<String, dynamic> json) => Info(
      id: json['id'] as num?,
      nameEn: json['nameEn'] as String?,
      nameEs: json['nameEs'] as String?,
      timeStart: json['timeStart'] as num?,
      intensity: json['intensity'] as num?,
      minutes: json['minutes'] as num?,
    );

Map<String, dynamic> _$InfoToJson(Info instance) => <String, dynamic>{
      'id': instance.id,
      'nameEn': instance.nameEn,
      'nameEs': instance.nameEs,
      'timeStart': instance.timeStart,
      'intensity': instance.intensity,
      'minutes': instance.minutes,
    };
