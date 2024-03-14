import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/save_urine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class SaveUrineInteractorImpl extends SaveUrineInteractor {
  final FecesUrineRepository fecesUrineRepository;

  SaveUrineInteractorImpl({required this.fecesUrineRepository});

  @override
  Future<void> execute(UploadFeces uploadUrine) => fecesUrineRepository.saveUrineEvent(uploadUrine);

}