import 'package:nutrenaissance_flutter/data/api/steps/models/step_event_response.dart';
import 'package:nutrenaissance_flutter/data/api/steps/models/upload_step_event_response.dart';
import 'package:nutrenaissance_flutter/data/local/models/steps/steps_entity.dart';

StepEventResponse mapToStepEventResponse(StepsEntity stepsEntity) =>
    StepEventResponse(
      eventId: stepsEntity.eventId,
      initialSteps: stepsEntity.initialSteps,
      actualSteps: stepsEntity.actualSteps,
    );

StepsEntity mapToStepEntity(StepEventResponse stepEventResponse) =>
    StepsEntity(
      eventId: stepEventResponse.eventId,
      initialSteps: stepEventResponse.initialSteps,
      actualSteps: stepEventResponse.actualSteps,
    );

UploadStepEventResponse mapToUploadStepEventResponse(
    String userId, StepEventResponse stepEventResponse) {
  return UploadStepEventResponse(
    userId: userId,
    eventId: stepEventResponse.eventId,
    initialSteps: stepEventResponse.initialSteps,
    actualSteps: stepEventResponse.actualSteps,
  );
}
