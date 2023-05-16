class CalendarActions {
  CalendarActions();
}

class InitializeStateAction extends CalendarActions {
  InitializeStateAction();
}

class SelectDayEventsActions extends CalendarActions {
  final DateTime selectedDay;

  SelectDayEventsActions({required this.selectedDay});
}

class RefreshEventsAction extends CalendarActions {
  final DateTime selectedDay;

  RefreshEventsAction({required this.selectedDay});
}