import 'package:nutrenaissance_flutter/domain/models/calendar/calendar_events.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class CalendarState {
  bool isLoading;
  ErrorTypes? onError;
  CalendarEvents? allCalendarEvents;
  CalendarEvents? eventsOfDate;
  List<dynamic>? dayEvents;
  DateTime? firstDay;
  DateTime? focusedDay;
  DateTime? lastDay;


  CalendarState({
    required this.isLoading,
    this.onError,
    this.allCalendarEvents,
    this.eventsOfDate,
    this.dayEvents,
    this.firstDay,
    this.focusedDay,
    this.lastDay,
  });

  CalendarState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    CalendarEvents? allCalendarEvents,
    CalendarEvents? eventsOfDate,
    List<dynamic>? dayEvents,
    DateTime? firstDay,
    DateTime? focusedDay,
    DateTime? lastDay,
  }) {
    return CalendarState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      allCalendarEvents: allCalendarEvents ?? this.allCalendarEvents,
      eventsOfDate: eventsOfDate ?? this.eventsOfDate,
      dayEvents: dayEvents ?? this.dayEvents,
      firstDay: firstDay ?? this.firstDay,
      focusedDay: focusedDay ?? this.focusedDay,
      lastDay: lastDay ?? this.lastDay,
    );
  }

}