
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';

abstract class UploadWaterEventInteractor {
  Future<bool> execute(WaterEventMaster waterEventMaster);
}