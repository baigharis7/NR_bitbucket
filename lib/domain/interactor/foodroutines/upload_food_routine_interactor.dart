import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';

abstract class UploadFoodRoutineInteractor {
  Future<bool> execute(FoodRoutineEvent foodRoutineEvent);
}