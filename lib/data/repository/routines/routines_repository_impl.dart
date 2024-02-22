import 'package:nutrenaissance_flutter/data/api/routines/routines_api.dart';
import 'package:nutrenaissance_flutter/data/local/models/routines/sport_routine_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/repository/routines/routines_repository.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/sport_routine_mappers.dart';

import '../../../domain/repository/localstorage/local_storage.dart';

class RoutinesRepositoryImpl extends RoutinesRepository {
  final RoutinesApi routinesApi;
  final LocalStorageRepository localStorageRepository;


  RoutinesRepositoryImpl({required this.routinesApi, required this.localStorageRepository});

  @override
  Future<bool> uploadRoutine(SportRoutineCompleted sportRoutineCompleted) async {
    try {
      final result = await routinesApi.uploadRoutine(sportRoutineCompleted);
      return true;
    } catch (_) {
      return false;
    }
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
}