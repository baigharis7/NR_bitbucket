import 'package:nutrenaissance_flutter/domain/interactor/steps/upload_steps_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/steps/steps_repository.dart';

class UploadStepsInteractorImpl extends UploadStepsInteractor {
  final StepsRepository stepsRepository;

  UploadStepsInteractorImpl({required this.stepsRepository});
  @override
  Future<void> execute() => stepsRepository.uploadSteps();

}