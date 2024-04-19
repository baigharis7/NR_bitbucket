import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';

abstract class GetWaterEventsTodayInteractor {
  Future<List<WaterEventMaster>> execute({DateTime? dateTime});
}