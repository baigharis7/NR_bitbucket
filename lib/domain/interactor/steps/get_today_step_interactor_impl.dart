import 'package:nutrenaissance_flutter/data/api/steps/models/step_event_response.dart';
import 'package:nutrenaissance_flutter/domain/interactor/steps/get_today_step_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/steps/steps_repository.dart';

class GetTodayStepInteractorImpl extends GetTodayStepInteractor {
  final StepsRepository stepsRepository;

  GetTodayStepInteractorImpl({required this.stepsRepository});
  @override
  Future<StepEventResponse> execute() => stepsRepository.todayStep();

}