import '../../models/calendar/dashboard_all_calendar_events.dart';

abstract class GetAllDashboardEventsSortedByDateInteractor {
  Future<DashboardAllCalendarEvents> execute();
}