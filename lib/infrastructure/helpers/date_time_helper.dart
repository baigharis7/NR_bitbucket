import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

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
    DateTime monday = currentDate.subtract(Duration(days: currentDate.weekday - 1));
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
    if (timeOfDay != null) {
    //   var df = DateFormat('hh:mm');
    //   timeOfDay?.minute;
    //   var dt = df.parse(timeOfDay?.format(context) ?? '00:00');
    // var finalTime = DateFormat.Hm().format(dt);
      // var finalTime =  DateFormat('h:mm aa').format(dt);
      return '${timeOfDay.hour}:${timeOfDay.minute}';
    }
    else {
      return null;
    }
  }

  static String? formatDateTimeToDay (DateTime? dateTime, {String? currentLanguage}) {
    if (dateTime != null) {
      var date = currentLanguage == 'es' ? DateFormat('EEE', Constants.LOCALE_ES).format(dateTime) : DateFormat('EEE').format(dateTime);
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

  static int calculateMidNightMillisecondsFromDateTime(DateTime? dateTim) {
    final dateTime = dateTim ?? DateTime.now();
    DateTime dateWithoutTime = DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0);
    return dateWithoutTime.millisecondsSinceEpoch;
  }

  static int calculateMidNightMillisecondsFromInt(int milliSeconds) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliSeconds);
    dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0);
    return dateTime.millisecondsSinceEpoch;
  }

  String formatDayMonthYearDate2(int date) => DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(date));

  static List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  static List<DateTime> getWeekDays({DateTime? dateTime}) {
    final now = dateTime ?? DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isPastDate(DateTime inputDate) {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final inputDateOnly = DateTime(inputDate.year, inputDate.month, inputDate.day);

    return inputDateOnly.isBefore(todayDateOnly);
  }

  static bool isFutureDate(DateTime inputDate) {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final inputDateOnly = DateTime(inputDate.year, inputDate.month, inputDate.day);

    return inputDateOnly.isAfter(todayDateOnly);
  }

  static double calculateDifferenceHours(start, end) {
    final startTime = dateTimeFromMilliseconds(start);
    final endTime = dateTimeFromMilliseconds(end);
    Duration diff = endTime!.difference(startTime!);
    double hours = diff.inMinutes / 60.0;
    return hours;
  }

  static Future<String> getDeviceIANATimeZone() async {
    try {
      final String timeZone = await FlutterTimezone.getLocalTimezone(); // e.g. "Asia/Karachi"
      return timeZone;
    } catch (e) {
      print("Failed to get time zone: $e");
      return 'UTC';
    }
  }

  static DateTime getDateDaysAgo({int? daysAgo}) {
    return DateTime.now().subtract(Duration(days: daysAgo ?? 14));
  }

  static TimeOfDay timeOfDayFrom24HrString(String? timeString) {
    if(timeString.isEmptyOrNull()) return TimeOfDay.now();
    final parts = timeString!.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String timeOfDayTo24HrString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute'; // e.g., 21:05
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }


}