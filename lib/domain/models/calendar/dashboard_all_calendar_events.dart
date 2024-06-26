import '../../../data/api/fecesurine/models/upload_feces.dart';
import '../../../data/api/supplements/model/upload_supplement_event.dart';
import '../foodevents/food_event_complete.dart';
import '../liquidevents/liquid_event_complete.dart';
import '../sportevents/sport_event_complete.dart';
import '../watervents/water_event_master.dart';

class DashboardAllCalendarEvents {
  final List<FoodEventComplete>? foodEvents;
  final List<SportEventComplete>? sportEvents;
  final List<LiquidEventComplete>? liquidEvents;
  final List<WaterEventMaster>? waterEvents;
  final List<UploadSupplementEvent>? creatineEvent;
  final List<UploadSupplementEvent>? collagenEvent;
  final List<UploadFeces>? faecesEvents;
  final List<UploadFeces>? urineEvents;

  DashboardAllCalendarEvents({
    this.foodEvents,
    this.sportEvents,
    this.liquidEvents,
    this.waterEvents,
    this.creatineEvent,
    this.collagenEvent,
    this.faecesEvents,
    this.urineEvents,
  });

  DashboardAllCalendarEvents.empty({
    this.foodEvents = const [],
    this.liquidEvents = const [],
    this.sportEvents = const [],
    this.waterEvents = const [],
    this.creatineEvent = const [],
    this.collagenEvent = const [],
    this.faecesEvents = const [],
    this.urineEvents = const [],
  });
}
