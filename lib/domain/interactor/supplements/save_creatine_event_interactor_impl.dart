import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_creatine_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class SaveCreatineEventInteractorImpl extends SaveCreatineEventInteractor {
  final SupplementsRepository supplementsRepository;

  SaveCreatineEventInteractorImpl({required this.supplementsRepository});
  @override
  Future<void> execute(UploadSupplementEvent uploadSupplementCreatineEvent, bool isEdit) => supplementsRepository.saveCreatineEvent(uploadSupplementCreatineEvent, isEdit);

}