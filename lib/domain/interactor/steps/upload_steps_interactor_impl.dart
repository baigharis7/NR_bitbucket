import 'package:nutrenaissance_flutter/data/api/steps/models/step_event_response.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/upload_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/steps/steps_repository.dart';

class UploadStepsInteractorImpl extends UploadStepsInteractor {
  final StepsRepository stepsRepository;

  UploadStepsInteractorImpl({required this.stepsRepository});
  @override
  Future<bool> execute(StepEventResponse stepEventResponse) => stepsRepository.uploadSteps(stepEventResponse);

}