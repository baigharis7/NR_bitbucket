import 'package:nutrenaissance_flutter/data/api/foodroutines/food_routines_api.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodroutines/food_routines_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

import '../../../domain/repository/localstorage/local_storage.dart';

class FoodRoutinesRepositoryImpl extends FoodRoutinesRepository {
  final FoodRoutinesApi foodRoutinesApi;
  final LocalStorageRepository localStorageRepository;

  FoodRoutinesRepositoryImpl({required this.foodRoutinesApi, required this.localStorageRepository});

  @override
  Future<bool> uploadRoutine(FoodRoutineEvent foodRoutineEvent) async {
    try {
      final result = await foodRoutinesApi.uploadRoutine(foodRoutineEvent);
      return true;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> saveRoutine(FoodRoutineEvent foodRoutineEvent, bool isEdit) async {
    try {
      final foodRoutineEntity = mapToFoodRoutineEntity(foodRoutineEvent);
      final result = await localStorageRepository.saveFoodRoutine(foodRoutineEntity, isEdit: isEdit);
    } catch (_) {
      rethrow;
    }
  }



}