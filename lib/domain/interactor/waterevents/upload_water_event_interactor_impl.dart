import 'package:nutrenaissance_flutter/domain/interactor/waterevents/upload_water_event_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/domain/repository/waterevents/water_events_repository.dart';

class UploadWaterEventInteractorImpl extends UploadWaterEventInteractor {
  final WaterEventsRepository waterEventsRepository;

  UploadWaterEventInteractorImpl({required this.waterEventsRepository});

  @override
  Future<bool> execute(WaterEventMaster waterEventMaster) async => waterEventsRepository.uploadWaterEvent(waterEventMaster);

}