// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_event_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepEventResponse _$StepEventResponseFromJson(Map<String, dynamic> json) =>
    StepEventResponse(
      eventId: json['eventId'] as int?,
      initialSteps: json['initialSteps'] as int?,
      actualSteps: json['actualSteps'] as int?,
    );

Map<String, dynamic> _$SportEventResponseToJson(StepEventResponse instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'initialSteps': instance.initialSteps,
      'actualSteps': instance.actualSteps,
    };
