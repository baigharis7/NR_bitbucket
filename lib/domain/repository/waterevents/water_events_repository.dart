import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';

abstract class WaterEventsRepository {
  Future<bool> uploadWaterEvent(WaterEventMaster waterEventMaster);
  Future<void> saveWaterEvent(WaterEventMaster waterEventMaster);
  Future<List<WaterEventMaster>> getWaterEventsToday({DateTime? dateTime});
  Future<List<WaterEventMaster>> getAllWaterEvents();
}