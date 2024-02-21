import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';

abstract class UploadRoutineInteractor {
  Future<bool> execute(SportRoutineCompleted sportRoutineCompleted);
}