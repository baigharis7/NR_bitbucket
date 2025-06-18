import 'package:nutrenaissance_flutter/domain/interactor/foodroutines/upload_food_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodroutines/food_routines_repository.dart';

class UploadFoodRoutineInteractorImpl extends UploadFoodRoutineInteractor {
  final FoodRoutinesRepository foodRoutinesRepository;

  UploadFoodRoutineInteractorImpl({required this.foodRoutinesRepository});

  @override
  Future<bool> execute(FoodRoutineEvent foodRoutineEvent) => foodRoutinesRepository.uploadRoutine(foodRoutineEvent);

}