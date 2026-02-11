// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_supplement_routine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSupplementRoutine _$UploadSupplementRoutineFromJson(
        Map<String, dynamic> json) =>
    UploadSupplementRoutine(
      userId: json['userId'] as String,
      eventId: (json['eventId'] as num).toInt(),
      eventDate: (json['eventDate'] as num).toInt(),
      info: (json['info'] as List<dynamic>)
          .map((e) =>
              UploadSupplementRoutineInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String?,
      time: json['time'] as String,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      timeZone: json['timeZone'] as String,
    );

Map<String, dynamic> _$UploadSupplementRoutineToJson(
        UploadSupplementRoutine instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'info': instance.info.map((e) => e.toJson()).toList(),
      'name': instance.name,
      'time': instance.time,
      'daysOfWeek': instance.daysOfWeek,
      'timeZone': instance.timeZone,
    };

UploadSupplementRoutineInfo _$UploadSupplementRoutineInfoFromJson(
        Map<String, dynamic> json) =>
    UploadSupplementRoutineInfo(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$UploadSupplementRoutineInfoToJson(
        UploadSupplementRoutineInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'unit': instance.unit,
    };
