import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_routine_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class RemoveSupplementRoutineInteractorImpl extends RemoveSupplementRoutineInteractor {
  final SupplementsRepository supplementsRepository;

  RemoveSupplementRoutineInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(SupplementSimple supplement) => supplementsRepository.removeSupplementRoutine(supplement);

}