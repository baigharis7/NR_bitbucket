import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_supplement_routines_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

import '../../../data/api/supplements/model/upload_supplement_routine.dart';

class GetSupplementRoutinesIntractorImpl extends GetSupplementRoutinesInteractor {
  final SupplementsRepository supplementsRepository;

  GetSupplementRoutinesIntractorImpl({required this.supplementsRepository});

  @override
  Future<List<SupplementSimple>> execute() => supplementsRepository.getSupplementRoutines();

}