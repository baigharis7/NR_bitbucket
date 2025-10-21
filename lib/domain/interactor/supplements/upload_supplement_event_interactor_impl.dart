import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplements_ev.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class UploadSupplementEventInteractorImpl extends UploadSupplementEventInteractor {
  SupplementsRepository supplementsRepository;

  UploadSupplementEventInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(UploadSupplementsEv uploadSupplementsEv) => supplementsRepository.uploadSupplementEvent(uploadSupplementsEv);

}