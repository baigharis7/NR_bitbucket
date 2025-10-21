import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/delete_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodroutines/food_routines_repository.dart';

class DeleteFoodRoutineInteractorImpl extends DeleteFoodRoutineInteractor {
  final FoodRoutinesRepository foodRoutinesRepository;
  DeleteFoodRoutineInteractorImpl({required this.foodRoutinesRepository});


  @override
  Future<void> execute(FoodRoutineEvent foodRoutineEvent) => foodRoutinesRepository.deleteFoodRoutine(foodRoutineEvent);


}