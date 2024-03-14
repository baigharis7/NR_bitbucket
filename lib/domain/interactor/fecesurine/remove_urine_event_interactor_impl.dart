import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/remove_urine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class RemoveUrineEventInteractorImpl extends RemoveUrineEventInteractor {
  final FecesUrineRepository fecesUrineRepository;

  RemoveUrineEventInteractorImpl({required this.fecesUrineRepository});

  @override
  Future<void> execute(UploadFeces uploadUrine) => fecesUrineRepository.removeUrineEvent(uploadUrine);

}