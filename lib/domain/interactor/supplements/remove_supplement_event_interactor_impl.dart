import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class RemoveSupplementEventInteractorImpl extends RemoveSupplementEventInteractor {
  final SupplementsRepository supplementsRepository;

  RemoveSupplementEventInteractorImpl({required this.supplementsRepository});

  @override
  Future<void> execute(SupplementSimple supplementEvent) => supplementsRepository.removeSupplementEvent(supplementEvent);



}