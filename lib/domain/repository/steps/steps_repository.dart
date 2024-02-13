import 'package:nutrenaissance_flutter/data/local/models/steps/steps_entity.dart';

import '../../../data/api/steps/models/step_event_response.dart';

abstract class StepsRepository {
  Future<bool> uploadSteps(StepEventResponse stepEventResponse);
  Future<void> saveSteps(StepEventResponse stepEventResponse);
  Future<List<StepEventResponse>> getSteps();
  Future<StepEventResponse> todayStep();
}