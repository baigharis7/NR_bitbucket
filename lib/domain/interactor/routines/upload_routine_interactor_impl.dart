import 'package:nutrenaissance_flutter/domain/interactor/routines/upload_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';

import '../../repository/routines/routines_repository.dart';

class UploadRoutineInteractorImpl extends UploadRoutineInteractor {
  final RoutinesRepository routinesRepository;

  UploadRoutineInteractorImpl({required this.routinesRepository});

  @override
  Future<bool> execute(SportRoutineCompleted sportRoutineCompleted) => routinesRepository.uploadRoutine(sportRoutineCompleted);
}