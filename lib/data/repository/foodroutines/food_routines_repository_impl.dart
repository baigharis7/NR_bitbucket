import 'package:nutrenaissance_flutter/data/api/foodroutines/food_routines_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/foodroutines/food_routine_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/foodroutines/food_routines_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

import '../../../domain/repository/localstorage/local_storage.dart';

class FoodRoutinesRepositoryImpl extends FoodRoutinesRepository {
  final FoodRoutinesApi foodRoutinesApi;
  final LocalStorageRepository localStorageRepository;
  final SyncQueueService syncQueue;

  FoodRoutinesRepositoryImpl({required this.foodRoutinesApi, required this.localStorageRepository, required this.syncQueue});

  @override
  Future<bool> uploadRoutine(FoodRoutineEvent foodRoutineEvent) async {
    foodRoutinesApi.uploadRoutine(foodRoutineEvent).catchError((error) {
      syncQueue.enqueue('/food-routines', foodRoutineEvent);
      return <String, dynamic>{};
    });
    return true;
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

  @override
  Future<List<FoodRoutineEvent>> getRoutines() async {
    try {
      final foodRoutinesEntity = await localStorageRepository.getFoodRoutine();
      return foodRoutinesEntity.map((sportEntity) => mapFoodRoutineEntityToEvent(sportEntity as FoodRoutineEntity)).toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> removeFoodRoutine(FoodRoutineEvent foodRoutineEvent) async {
    try {
      final foodRoutineEntity = mapToFoodRoutineEntity(foodRoutineEvent);
      await localStorageRepository.removeFoodRoutine(foodRoutineEntity);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteFoodRoutine(FoodRoutineEvent foodRoutineEvent) async {
    foodRoutinesApi.deleteRoutine(foodRoutineEvent).catchError((error) {
      syncQueue.enqueueDelete('/food-routines', {'userId': foodRoutineEvent.userId, 'eventId': foodRoutineEvent.eventId});
      return <String, dynamic>{};
    });
  }
}