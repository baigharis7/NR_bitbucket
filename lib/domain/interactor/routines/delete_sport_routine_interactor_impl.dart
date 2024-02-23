import 'package:nutrenaissance_flutter/domain/interactor/routines/delete_sport_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/routines/routines_repository.dart';

class DeleteSportRoutineInteractorImpl extends DeleteSportRoutineInteractor {
  final RoutinesRepository routinesRepository;

  DeleteSportRoutineInteractorImpl({required this.routinesRepository});
  @override
  Future<void> execute(String userId, int eventId) => routinesRepository.deleteSportRoutine(userId, eventId);

}