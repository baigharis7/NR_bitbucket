import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/remove_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodroutines/food_routines_repository.dart';

class RemoveFoodRoutineInteractorImpl extends RemoveFoodRoutineInteractor {
  final FoodRoutinesRepository foodRoutinesRepository;

  RemoveFoodRoutineInteractorImpl({required this.foodRoutinesRepository});

  @override
  Future<void> execute(FoodRoutineEvent foodRoutineEvent) => foodRoutinesRepository.removeFoodRoutine(foodRoutineEvent);

}