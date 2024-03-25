import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class SaveCollagenEventInteractorImpl extends SaveCollagenEventInteractor {
  final SupplementsRepository supplementsRepository;

  SaveCollagenEventInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(UploadSupplementEvent uploadSupplementCollagenEvent, bool isEdit) => supplementsRepository.saveCollagenEvent(uploadSupplementCollagenEvent, isEdit);
  
}