import 'package:nutrenaissance_flutter/data/api/steps/models/step_event_response.dart';

abstract class GetTodayStepInteractor {
  Future<StepEventResponse> execute();
}