import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_event.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_today_collagen_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class GetTodayCollagenEventInteractorImpl extends GetTodayCollagenEventInteractor {
  final SupplementsRepository supplementsRepository;

  GetTodayCollagenEventInteractorImpl({required this.supplementsRepository});

  @override
  Future<UploadSupplementEvent?> execute() => supplementsRepository.getTodayCollagenEvent();

}