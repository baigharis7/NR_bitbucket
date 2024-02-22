import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';

abstract class RoutinesRepository {
  Future<bool> uploadRoutine(SportRoutineCompleted sportRoutineCompleted);
  Future<List<SportRoutineCompleted>> getRoutines();
  Future<void> saveRoutine(SportRoutineCompleted sportRoutineCompleted, bool isEdit);
}