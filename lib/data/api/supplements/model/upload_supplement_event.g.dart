// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_supplement_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSupplementEvent _$UploadSupplementEventFromJson(
    Map<String, dynamic> json) =>
    UploadSupplementEvent(
      userId: json['userId'] as String,
      eventId: json['eventId'] as int,
      value: json['value'] as int,
    );

Map<String, dynamic> _$UploadSupplementEventToJson(
    UploadSupplementEvent instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'value': instance.value,
    };
