import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';

abstract class SaveFoodRoutineInteractor {
  Future<void> execute(FoodRoutineEvent foodRoutineEvent, bool isEdit);
}