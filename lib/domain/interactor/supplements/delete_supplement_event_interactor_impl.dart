import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class DeleteSupplementEventInteractorImpl extends DeleteSupplementEventInteractor {
  final SupplementsRepository supplementsRepository;

  DeleteSupplementEventInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(SupplementSimple supplementEvent) => supplementsRepository.deleteSupplementEvent(supplementEvent);

}