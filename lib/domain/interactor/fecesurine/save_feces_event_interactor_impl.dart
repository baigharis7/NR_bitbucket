import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_feces_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class SaveFecesEventInteractorImpl extends SaveFecesEventInteractor {
  final FecesUrineRepository fecesUrineRepository;

  SaveFecesEventInteractorImpl({required this.fecesUrineRepository});

  @override
  Future<void> execute(UploadFeces uploadFeces) => fecesUrineRepository.saveFecesEvent(uploadFeces);
}