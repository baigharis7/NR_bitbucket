import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_faeces_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

import '../../../data/api/fecesurine/models/upload_feces.dart';

class GetFaecesByDateInteractorImpl extends GetFaecesByDateInteractor {
  final FecesUrineRepository fecesUrineRepository;

  GetFaecesByDateInteractorImpl({required this.fecesUrineRepository});

  @override
  Future<List<UploadFeces>> execute({DateTime? dateTime, DateTime? endDate, int? days}) => fecesUrineRepository.getFecesEventsByDate(dateTime: dateTime, endDate: endDate, days: days);
}