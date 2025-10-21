import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_day_supplement_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/repository/supplements/supplements_repository.dart';

class GetDaySupplementEventsInteractorImpl extends GetDaySupplementEventsInteractor {
  final SupplementsRepository supplementsRepository;

  GetDaySupplementEventsInteractorImpl({required this.supplementsRepository});

  @override
  Future<List<SupplementSimple>> execute({DateTime? dateTime}) => supplementsRepository.getSupplementEventsDay(dateTime: dateTime);

}