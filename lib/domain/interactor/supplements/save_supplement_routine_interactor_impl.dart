import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_routine.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class SaveSupplementRoutineInteractorImpl extends SaveSupplementRoutineInteractor {
  final SupplementsRepository supplementsRepository;

  SaveSupplementRoutineInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(UploadSupplementRoutine supplementRoutine, bool isEdit) => supplementsRepository.saveSupplementRoutine(supplementRoutine, isEdit);
  
}