import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';

import '../../repository/foodroutines/food_routines_repository.dart';
import 'get_food_routines_interactor.dart';

class GetFoodRoutinesInteractorImpl extends GetFoodRoutinesInteractor {
  final FoodRoutinesRepository foodRoutinesRepository;

  GetFoodRoutinesInteractorImpl({required this.foodRoutinesRepository});

  @override
  Future<List<FoodRoutineEvent>> execute() => foodRoutinesRepository.getRoutines();

}