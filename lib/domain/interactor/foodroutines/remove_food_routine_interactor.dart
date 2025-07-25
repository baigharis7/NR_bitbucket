import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';

abstract class RemoveFoodRoutineInteractor {
  Future<void> execute(FoodRoutineEvent foodRoutineEvent);
}