import 'package:nutrenaissance_flutter/domain/interactor/routines/remove_sport_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/repository/routines/routines_repository.dart';

class RemoveSportRoutineInteractorImpl extends RemoveSportRoutineInteractor {
  final RoutinesRepository routinesRepository;

  RemoveSportRoutineInteractorImpl({required this.routinesRepository});

  @override
  Future<void> execute(SportRoutineCompleted sportRoutineCompleted) => routinesRepository.removeSportRoutine(sportRoutineCompleted);

}