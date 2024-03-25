import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class UploadCollagenEventInteractorImpl extends UploadCollagenEventInteractor {
  final SupplementsRepository supplementsRepository;

  UploadCollagenEventInteractorImpl({required this.supplementsRepository});
  @override
  Future<void> execute(UploadSupplementEvent uploadSupplementCollagenEvent,) => supplementsRepository.uploadCollagenEvent(uploadSupplementCollagenEvent);

}