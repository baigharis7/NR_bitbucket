import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';

abstract class SportEventsRepository {
  Future<SportEventComplete> uploadSportEvent(SportEventSimple sportEventSimple);
  Future<void> saveSportEvent(SportEventComplete sportEventComplete, bool isEdit);
  Future<List<SportEventComplete>> getTodaySportEvents();
  Future<List<SportEventComplete>> getWeeklySportEvents();
  Future<List<SportEventComplete>> getAllSportEvents();
  Future<int?> getDayCalories();
}