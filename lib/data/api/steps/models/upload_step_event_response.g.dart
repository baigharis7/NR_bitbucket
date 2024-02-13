// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_step_event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadStepEventResponse _$UploadStepEventResponseFromJson(
        Map<String, dynamic> json) =>
    UploadStepEventResponse(
      userId: json['userId'] as String?,
      eventId: json['eventId'] as int?,
      initialSteps: json['initialSteps'] as int?,
      actualSteps: json['actualSteps'] as int?,
    );

Map<String, dynamic> _$UploadStepEventResponseToJson(
        UploadStepEventResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'initialSteps': instance.initialSteps,
      'actualSteps': instance.actualSteps,
    };
