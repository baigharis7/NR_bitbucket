import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';

abstract class DeleteFoodRoutineInteractor {
  Future<void> execute(FoodRoutineEvent foodRoutineEvent);
}