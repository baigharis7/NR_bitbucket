import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';

abstract class SaveWaterEventInteractor {
  Future<void> execute(WaterEventMaster waterEventMaster);
}