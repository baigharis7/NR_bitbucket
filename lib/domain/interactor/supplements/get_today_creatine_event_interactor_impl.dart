import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

import 'get_today_creatine_event_interactor.dart';

class GetTodayCreatineEventInteractorImpl extends GetTodayCreatineEventInteractor {
  final SupplementsRepository supplementsRepository;

  GetTodayCreatineEventInteractorImpl({required this.supplementsRepository});
  @override
  Future<UploadSupplementEvent> execute() => supplementsRepository.getTodayCreatineEvent();
}