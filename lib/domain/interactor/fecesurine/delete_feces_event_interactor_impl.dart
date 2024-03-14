import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class DeleteFecesEventInteractorImpl extends DeleteFecesEventInteractor {
  final FecesUrineRepository fecesUrineRepository;

  DeleteFecesEventInteractorImpl({required this.fecesUrineRepository});

  @override
  Future<void> execute(String userId, eventId) => fecesUrineRepository.deleteFecesEvent(userId, eventId);

}