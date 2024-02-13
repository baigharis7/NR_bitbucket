import 'package:nutrenaissance_flutter/domain/interactor/steps/get_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/steps/steps_repository.dart';

import '../../../data/api/steps/models/step_event_response.dart';

class GetStepsInteractorImpl extends GetStepsInteractor {
  final StepsRepository stepsRepository;

  GetStepsInteractorImpl({required this.stepsRepository});
  @override
  Future<List<StepEventResponse>> execute() => stepsRepository.getSteps();

}