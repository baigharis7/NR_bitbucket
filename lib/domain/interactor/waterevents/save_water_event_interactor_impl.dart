import 'package:nutrenaissance_flutter/domain/interactor/waterevents/save_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/waterevents/water_events_repository.dart';

class SaveWaterEventInteractorImpl extends SaveWaterEventInteractor {
  final WaterEventsRepository waterEventsRepository;

  SaveWaterEventInteractorImpl({required this.waterEventsRepository});

  @override
  Future<void> execute(WaterEventMaster waterEventMaster) async => waterEventsRepository.saveWaterEvent(waterEventMaster);
}