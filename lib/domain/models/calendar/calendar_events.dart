import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';

class CalendarEvents {
  final List<FoodEventComplete>? foodEvents;
  final List<SportEventComplete>? sportEvents;
  final List<LiquidEventComplete>? liquidEvents;
  final List<WaterEventMaster>? waterEvents;

  CalendarEvents({
    this.foodEvents,
    this.sportEvents,
    this.liquidEvents,
    this.waterEvents,
  });

  CalendarEvents.empty({
    this.foodEvents = const [],
    this.sportEvents = const [],
    this.liquidEvents = const [],
    this.waterEvents = const [],
  });
}