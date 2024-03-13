import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/upload_feces_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class UploadFecesInteractorImpl extends UploadFecesInteractor {
  final FecesUrineRepository fecesUrineRepository;

  UploadFecesInteractorImpl({required this.fecesUrineRepository});

  @override
  Future<void> execute(UploadFeces uploadFeces) => fecesUrineRepository.uploadFeces(uploadFeces);

}