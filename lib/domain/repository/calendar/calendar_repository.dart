import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';

abstract class CalendarRepository {
  Future<CalendarEvents> getAllEvents();
}