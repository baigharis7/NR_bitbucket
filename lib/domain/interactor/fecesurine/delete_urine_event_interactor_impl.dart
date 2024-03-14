import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/delete_urine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class DeleteUrineEventInteractorImpl extends DeleteUrineEventInteractor {
  final FecesUrineRepository fecesUrineRepository;

  DeleteUrineEventInteractorImpl({required this.fecesUrineRepository});
  @override
  Future<void> execute(String userId, int eventId) => fecesUrineRepository.deleteUrineEvent(userId, eventId);

}