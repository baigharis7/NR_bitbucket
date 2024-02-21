import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';

abstract class GetRoutinesInteractor {
  Future<List<SportRoutineCompleted>> execute();
}