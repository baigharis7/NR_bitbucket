import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';

abstract class LiquidEventsRepository {
  Future<UploadLiquidEvent> uploadLiquidEvent(LiquidEventSimple liquidEventSimple);
  Future<void> saveLiquidEvent(UploadLiquidEvent uploadLiquidEvent, bool isEdit);
  Future<List<LiquidEventComplete>> getTodayLiquidEvents({DateTime? dateTime});
  Future<List<LiquidEventComplete>> getWeeklyLiquidEvents();
  Future<List<LiquidEventComplete>> getAllLiquidEvents();
  Future<void> deleteLiquidEvent(String userId, int eventDate);
  Future<void> removeLiquidEvent(LiquidEventComplete liquidEventComplete);
}