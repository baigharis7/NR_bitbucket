import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';

import '../../models/calendar/dashboard_all_calendar_events.dart';

abstract class CalendarRepository {
  Future<CalendarEvents> getAllEvents();
  Future<DashboardAllCalendarEvents> getAllDashEvents();
}