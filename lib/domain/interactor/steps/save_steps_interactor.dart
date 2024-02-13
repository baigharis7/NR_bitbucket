import 'package:nutrenaissance_flutter/data/api/steps/models/step_event_response.dart';

abstract class SaveStepsInteractor {
  Future<void> execute(StepEventResponse stepEventResponse);
}