import 'package:nutrenaissance_flutter/domain/interactor/routines/get_routines_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/repository/routines/routines_repository.dart';

class GetRoutinesInteractorImpl extends GetRoutinesInteractor {
  final RoutinesRepository routinesRepository;

  GetRoutinesInteractorImpl({required this.routinesRepository});

  @override
  Future<List<SportRoutineCompleted>> execute() => routinesRepository.getRoutines();

}