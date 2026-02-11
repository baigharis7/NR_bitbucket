// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_step_event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadStepEventResponse _$UploadStepEventResponseFromJson(
        Map<String, dynamic> json) =>
    UploadStepEventResponse(
      userId: json['userId'] as String?,
      eventId: (json['eventId'] as num?)?.toInt(),
      initialSteps: (json['initialSteps'] as num?)?.toInt(),
      actualSteps: (json['actualSteps'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UploadStepEventResponseToJson(
        UploadStepEventResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'eventId': instance.eventId,
      'initialSteps': instance.initialSteps,
      'actualSteps': instance.actualSteps,
    };
