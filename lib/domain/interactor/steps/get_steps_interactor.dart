import '../../../data/api/steps/models/step_event_response.dart';

abstract class GetStepsInteractor {
  Future<List<StepEventResponse>> execute();
}