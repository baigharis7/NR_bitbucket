import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_routine.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/upload_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class UploadSupplementRoutineInteractorImpl extends UploadSupplementRoutineInteractor {
  final SupplementsRepository supplementsRepository;

  UploadSupplementRoutineInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(UploadSupplementRoutine uploadSupplementRoutine) => supplementsRepository.uploadSupplementRoutine(uploadSupplementRoutine);

}