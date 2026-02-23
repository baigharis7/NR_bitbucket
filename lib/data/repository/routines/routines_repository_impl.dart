import 'package:nutrenaissance_flutter/data/api/routines/routines_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/routines/sport_routine_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/repository/routines/routines_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/sport_routine_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sync_queue_service.dart';

import '../../../domain/repository/localstorage/local_storage.dart';

class RoutinesRepositoryImpl extends RoutinesRepository {
  final RoutinesApi routinesApi;
  final LocalStorageRepository localStorageRepository;
  final SyncQueueService syncQueue;

  RoutinesRepositoryImpl({required this.routinesApi, required this.localStorageRepository, required this.syncQueue});

  @override
  Future<bool> uploadRoutine(SportRoutineCompleted sportRoutineCompleted) async {
    routinesApi.uploadRoutine(sportRoutineCompleted).catchError((error) {
      syncQueue.enqueue('/sport-routine/v2', sportRoutineCompleted);
      return <String, dynamic>{};
    });
    return true;
  }

  @override
  Future<List<SportRoutineCompleted>> getRoutines() async {
    final result = await localStorageRepository.getSportRoutines();
    return result.map((sportEntity) => mapToSportRoutineCompleted(sportEntity as SportRoutineEntity)).toList();
  }

  @override
  Future<void> saveRoutine(SportRoutineCompleted sportRoutineCompleted, bool isEdit) async {
    try {
      final result = await localStorageRepository.saveSportRoutine(mapToSportRoutineEntity(sportRoutineCompleted), isEdit: isEdit);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSportRoutine(String userId, int eventId) async {
    routinesApi.deleteSportRoutine(userId, eventId).catchError((error) {
      syncQueue.enqueueDelete('/sport-routine/v2', {'userId': userId, 'eventId': eventId});
      return <String, dynamic>{};
    });
  }

  @override
  Future<void> removeSportRoutine(SportRoutineCompleted sportRoutineCompleted) => localStorageRepository.removeSportRoutines(mapToSportRoutineEntity(sportRoutineCompleted));
}