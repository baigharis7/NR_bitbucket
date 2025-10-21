import 'package:nutrenaissance_flutter/domain/interactor/supplements/save_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class SaveSupplementInteractorImpl extends SaveSupplementEventInteractor {
  final SupplementsRepository supplementsRepository;

  SaveSupplementInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(SupplementSimple supplementSimple, bool isEdit) => supplementsRepository.saveSupplementEvent(supplementSimple, isEdit);
}