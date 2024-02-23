import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

class DateTimeHelper {
  DateTime provideCurrentDate() {
    return DateTime.now();
  }

  DateTime provideTodayAtMidnightDate() {
    DateTime currentDate = provideCurrentDate();
    return DateTime(currentDate.year, currentDate.month, currentDate.day, 0, 0, 0, 0, 0);
  }

  DateTime provideMondayAtMidnightDate() {
    DateTime currentDate = provideCurrentDate();
    DateTime monday = currentDate.subtract(Duration(days: currentDate.weekday));
    return DateTime(monday.year, monday.month, monday.day, 0, 0, 0, 0, 0);
  }

  DateTime setDateFromMilliseconds(int milliseconds) => DateTime.fromMillisecondsSinceEpoch(milliseconds);

  List<String> getWeekDaysInitialList(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;
    if (currentLanguage == 'es') {
      return ['L','M','X','J','V','S','D',];
    } else {
      return ['M','T','W','T','F','S','S',];
    }
  }

  DateTime provideFocusedDayForCalendar() {
    final currentDate = provideCurrentDate();
    return DateTime.utc(currentDate.year, currentDate.month, currentDate.day);
  }

  DateTime provideFirstDayForCalendar() {
    return DateTime.utc(2022, 1, 1);
  }

  DateTime provideLastDayForCalendar() => provideFocusedDayForCalendar();

  int getDayFromDate(int? milliseconds) {
    if (milliseconds == null) {
      final providedDay = setDateFromMilliseconds(milliseconds!);
      return providedDay.day;
    } else {
      final currentDate = provideCurrentDate();
      return currentDate.day;
    }
  }

  bool isSameGivenDateAndMillisecondsDate(DateTime date, int milliseconds) {
    final dateFromMillis = setDateFromMilliseconds(milliseconds);
    if (date.day == dateFromMillis.day
        && date.month == dateFromMillis.month
        && date.year == dateFromMillis.year
    ) {
      return true;
    } else {
      return false;
    }
  }

  String formatTimeOfDayToString(int milliseconds) {
    final dateTime = DateTimeHelper().setDateFromMilliseconds(milliseconds);
    return '${dateTime.hour}:${dateTime.minute}';
  }

  TimeOfDay setTimeOfDayFromMillis(int milliseconds) {
    final dateTime = DateTimeHelper().setDateFromMilliseconds(milliseconds);
    final timeOfDay = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    return timeOfDay;
  }

  String formatDashboardTodayMessage(String today, String locale) {
    final dateTime = provideCurrentDate();
    final formatted = DateFormat.MMMMd(locale).format(dateTime);
    return '$today, $formatted, ${dateTime.year}';
  }

  String formatDayMonthYearDate(int date) {
    final dateTime = DateTimeHelper().setDateFromMilliseconds(date);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  static String? formatTimeOfDay(TimeOfDay? timeOfDay, BuildContext context) {
    if (!timeOfDay.isNull()) {
      var df = DateFormat('h:mm a');
      var dt = df.parse(timeOfDay?.format(context) ?? '00:00');
      var finalTime =  DateFormat('HH:mm').format(dt);
      return finalTime;
    }
    else {
      return null;
    }
  }

  static String? formatDateTimeToDay (DateTime? dateTime) {
    if (dateTime != null) {
      var date = DateFormat('EEE').format(dateTime);
      return date;
    } else {
      return null;
    }
  }

  static TimeOfDay? timeOfDayFromMillis (int? milliseconds) {
    if (milliseconds != null) {
      final dateTime = DateTimeHelper().setDateFromMilliseconds(milliseconds);
      final timeOfDay = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      return timeOfDay;
    } else {
      return null;
    }
  }

  static DateTime? dateTimeFromMilliseconds(int? milliseconds) {
    if (milliseconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    } else {
      return null;
    }
  }

  static int? calculateMillisecondsFromTimeOfDayDateTime(TimeOfDay? timeStart, DateTime? dateStart) {
    if (timeStart != null && dateStart != null) {
      DateTime dateTime = DateTime(dateStart.year, dateStart.month, dateStart.day, timeStart.hour, timeStart.minute);
      return dateTime.millisecondsSinceEpoch;
    } else {
      return null;
    }
  }

  String formatDayMonthYearDate2(int date) => DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(date));

}