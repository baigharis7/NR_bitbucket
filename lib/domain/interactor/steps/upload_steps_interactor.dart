import 'package:nutrenaissance_flutter/data/api/steps/models/step_event_response.dart';

abstract class UploadStepsInteractor {
  Future<bool> execute(StepEventResponse stepEventResponse);
}