import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/save_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodroutines/food_routines_repository.dart';

class SaveFoodRoutineInteractorImpl extends SaveFoodRoutineInteractor {
  final FoodRoutinesRepository foodRoutinesRepository;

  SaveFoodRoutineInteractorImpl({required this.foodRoutinesRepository});

  @override
  Future<void> execute(FoodRoutineEvent foodRoutineEvent, bool isEdit) => foodRoutinesRepository.saveRoutine(foodRoutineEvent, isEdit);



}