// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_supplement_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSupplementEvent _$UploadSupplementEventFromJson(
        Map<String, dynamic> json) =>
    UploadSupplementEvent(
      userId: json['userId'] as String?,
      eventId: (json['eventId'] as num?)?.toInt(),
      value: (json['value'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UploadSupplementEventToJson(
        UploadSupplementEvent instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'value': instance.value,
    };
