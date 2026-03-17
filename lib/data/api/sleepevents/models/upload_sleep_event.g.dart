// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_sleep_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSleepEvent _$UploadSleepEventFromJson(Map<String, dynamic> json) =>
    UploadSleepEvent(
      userId: json['userId'] as String?,
      eventId: (json['eventId'] as num?)?.toInt(),
      eventDate: (json['eventDate'] as num?)?.toInt(),
      sleepMinutes: (json['sleepMinutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UploadSleepEventToJson(UploadSleepEvent instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventDate': instance.eventDate,
      'sleepMinutes': instance.sleepMinutes,
    };
