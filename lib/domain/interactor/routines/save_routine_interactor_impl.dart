import 'package:nutrenaissance_flutter/domain/interactor/routines/save_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/repository/routines/routines_repository.dart';

class SaveRoutineInteractorImpl extends SaveRoutineInteractor {
  final RoutinesRepository routinesRepository;

  SaveRoutineInteractorImpl({required this.routinesRepository});

  @override
  Future<void> execute(SportRoutineCompleted sportRoutineCompleted, bool isEdit) => routinesRepository.saveRoutine(sportRoutineCompleted, isEdit);

}