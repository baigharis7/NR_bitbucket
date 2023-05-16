import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';

abstract class GetAllEventsSortedByDateInteractor {
  Future<CalendarEvents> execute();
}