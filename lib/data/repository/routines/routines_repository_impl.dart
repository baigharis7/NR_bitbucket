import 'package:nutrenaissance_flutter/data/api/routines/routines_api.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';
import 'package:nutrenaissance_flutter/domain/repository/routines/routines_repository.dart';

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
    return <SportRoutineCompleted>[SportRoutineCompleted(sportName: 'Hi'), SportRoutineCompleted(sportName: 'Ameer'), SportRoutineCompleted(sportName: 'Hamza')];
  }
}