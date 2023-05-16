import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';

abstract class WaterEventsRepository {
  Future<bool> uploadWaterEvent(WaterEventMaster waterEventMaster);
  Future<void> saveWaterEvent(WaterEventMaster waterEventMaster);
  Future<List<WaterEventMaster>> getWaterEventsToday();
  Future<List<WaterEventMaster>> getAllWaterEvents();
}