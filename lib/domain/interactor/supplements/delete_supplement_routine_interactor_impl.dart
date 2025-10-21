import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class DeleteSupplementRoutineInteractorImpl extends DeleteSupplementRoutineInteractor {
  final SupplementsRepository supplementsRepository;


  DeleteSupplementRoutineInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(SupplementSimple supplement) => supplementsRepository.deleteSupplementRoutine(supplement);

}