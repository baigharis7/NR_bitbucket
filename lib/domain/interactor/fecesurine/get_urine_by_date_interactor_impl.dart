import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_urine_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class GetUrineByDateInteractorImpl extends GetUrineByDateInteractor {
  final FecesUrineRepository fecesUrineRepository;

  GetUrineByDateInteractorImpl({required this.fecesUrineRepository});
  @override
  Future<List<UploadFeces>> execute({DateTime? dateTime}) => fecesUrineRepository.getUrineEventsByDate(dateTime: dateTime);

}