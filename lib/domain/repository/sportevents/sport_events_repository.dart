import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';

abstract class SportEventsRepository {
  Future<SportEventComplete> uploadSportEvent(SportEventSimple sportEventSimple);
  Future<void> saveSportEvent(SportEventComplete sportEventComplete, bool isEdit);
  void syncToBackend(SportEventComplete sportEventComplete);
  Future<void> removeSportEvent(SportEventComplete sportEventComplete);
  Future<void> deleteSportEvent(String userId, int eventId);
  Future<List<SportEventComplete>> getTodaySportEvents({DateTime? dateTime});
  Future<List<SportEventComplete>> getWeeklySportEvents();
  Future<List<SportEventComplete>> getRecentSportEvents();
  Future<List<SportEventComplete>> getAllSportEvents();
  Future<int?> getDayCalories({DateTime? dateTime});
}