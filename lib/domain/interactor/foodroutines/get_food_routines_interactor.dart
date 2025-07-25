import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';

abstract class GetFoodRoutinesInteractor {
  Future<List<FoodRoutineEvent>> execute();
}