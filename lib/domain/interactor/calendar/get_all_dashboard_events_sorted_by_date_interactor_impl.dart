import 'package:nutrenaissance_flutter/domain/interactor/calendar/get_all_dashboard_events_sorted_by_date_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/dashboard_all_calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/repository/calendar/calendar_repository.dart';

class GetAllDashboardEventsSortedByDateInteractorImpl extends GetAllDashboardEventsSortedByDateInteractor {
  final CalendarRepository calendarRepository;

  GetAllDashboardEventsSortedByDateInteractorImpl({required this.calendarRepository});

  @override
  Future<DashboardAllCalendarEvents> execute() => calendarRepository.getAllDashEvents();

}