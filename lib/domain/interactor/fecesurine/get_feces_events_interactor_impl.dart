import 'package:nutrenaissance_flutter/data/api/fecesurine/models/upload_feces.dart';
import 'package:nutrenaissance_flutter/domain/interactor/fecesurine/get_feces_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/fecesurine/feces_urine_repository.dart';

class GetFecesEventsInteractorImpl extends GetFecesEventsInteractor {
  final FecesUrineRepository fecesUrineRepository;

  GetFecesEventsInteractorImpl({required this.fecesUrineRepository});

  @override
  Future<List<UploadFeces>> execute() => fecesUrineRepository.getFecesEvents();

}