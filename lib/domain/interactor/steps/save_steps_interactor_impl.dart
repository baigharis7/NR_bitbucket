import 'package:nutrenaissance_flutter/domain/interactor/steps/save_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/steps/steps_repository.dart';

import '../../../data/api/steps/models/step_event_response.dart';

class SaveStepsInteractorImpl extends SaveStepsInteractor {
  final StepsRepository stepsRepository;

  SaveStepsInteractorImpl({required this.stepsRepository});

  @override
  Future<void> execute(StepEventResponse stepEventResponse) => stepsRepository.saveSteps(stepEventResponse);

}