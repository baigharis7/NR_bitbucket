import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';

abstract class SportEventsRepository {
  Future<SportEventComplete> uploadSportEvent(SportEventSimple sportEventSimple);
  Future<void> saveSportEvent(SportEventComplete sportEventComplete);
}