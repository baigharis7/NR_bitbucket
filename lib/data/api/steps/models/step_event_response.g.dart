// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepEventResponse _$StepEventResponseFromJson(Map<String, dynamic> json) =>
    StepEventResponse(
      eventId: (json['eventId'] as num?)?.toInt(),
      initialSteps: (json['initialSteps'] as num?)?.toInt(),
      actualSteps: (json['actualSteps'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StepEventResponseToJson(StepEventResponse instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'initialSteps': instance.initialSteps,
      'actualSteps': instance.actualSteps,
    };
