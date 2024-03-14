import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_urine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class UploadUrineInteractorImpl extends UploadUrineInteractor {
  final FecesUrineRepository fecesUrineRepository;

  UploadUrineInteractorImpl({required this.fecesUrineRepository});

  @override
  Future<void> execute(UploadFeces uploadUrine) => fecesUrineRepository.uploadUrine(uploadUrine);

}