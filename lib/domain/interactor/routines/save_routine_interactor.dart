import '../../models/routines/sport_routine_completed.dart';

abstract class SaveRoutineInteractor {
  Future<void> execute(SportRoutineCompleted sportRoutineCompleted, bool isEdit);
}