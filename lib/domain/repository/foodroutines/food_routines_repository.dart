import 'dart:ffi';

import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';

abstract class FoodRoutinesRepository {
  Future<bool> uploadRoutine(FoodRoutineEvent foodRoutineEvent);
  Future<void> saveRoutine(FoodRoutineEvent foodRoutineEvent, bool isEdit);
  Future<List<FoodRoutineEvent>> getRoutines();
  Future<void> deleteFoodRoutine(FoodRoutineEvent foodRoutineEvent);
  Future<void> removeFoodRoutine(FoodRoutineEvent foodRoutineEvent);
}