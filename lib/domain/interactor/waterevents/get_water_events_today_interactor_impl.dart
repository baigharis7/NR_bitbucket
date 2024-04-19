import 'package:nutrenaissance_flutter/domain/interactor/waterevents/get_water_events_today_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/waterevents/water_events_repository.dart';

class GetWaterEventsTodayInteractorImpl extends GetWaterEventsTodayInteractor {
  final WaterEventsRepository waterEventsRepository;

  GetWaterEventsTodayInteractorImpl({required this.waterEventsRepository});

  @override
  Future<List<WaterEventMaster>> execute({DateTime? dateTime}) async => await waterEventsRepository.getWaterEventsToday(dateTime: dateTime);

}