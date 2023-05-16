import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';

abstract class GetTodayLiquidEventsInteractor {
  Future<List<LiquidEventComplete>> execute();
}