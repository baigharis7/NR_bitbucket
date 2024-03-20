import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class UploadCreatineEventInteractorImpl extends UploadCreatineEventInteractor {
  final SupplementsRepository supplementsRepository;

  UploadCreatineEventInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(UploadSupplementEvent uploadSupplementEvent) => supplementsRepository.uploadCreatineEvent(uploadSupplementEvent);

}