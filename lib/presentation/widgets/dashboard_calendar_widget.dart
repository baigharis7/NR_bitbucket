import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../infrastructure/helpers/date_time_helper.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';

class DashboardCalendarWidget extends StatefulWidget {
  final Function callGetAllEvents;
  final Function(DateTime) selectedDateForEventsLoading;
  final DateTime? focused;
  final String currentLanguage;
  const DashboardCalendarWidget({
    super.key,
    required this.callGetAllEvents,
    required this.selectedDateForEventsLoading,
    this.focused,
    required this.currentLanguage,
  });

  @override
  State<DashboardCalendarWidget> createState() => _DashboardCalendarWidgetState();
}

class _DashboardCalendarWidgetState extends State<DashboardCalendarWidget> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  bool isFocusedDayDate = false;

  @override
  void initState() {
    _focusedDay = widget.focused == null ? DateTimeHelper().provideCurrentDate() : widget.focused!;
    _selectedDay = widget.focused == null ? DateTimeHelper().provideCurrentDate() : widget.focused!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 400,child:
    TableCalendar(
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: widget.currentLanguage,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(decoration: const BoxDecoration(color: AppColors.mountainMeadow,), weekendStyle: const TextStyle(color: Colors.black, fontSize: Dimens.fontSizeXSmall, overflow: TextOverflow.ellipsis),
        dowTextFormatter: (date, locale) => DateFormat('EEEE', widget.currentLanguage).format(date), weekdayStyle: const TextStyle(color: Colors.black, fontSize: Dimens.fontSizeXSmall, overflow: TextOverflow.ellipsis),),
      daysOfWeekHeight: Dimens.heightSmall-20,
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
      ),
      firstDay: DateTime(DateTime.now().year - 1),
      focusedDay: _focusedDay,
      lastDay: DateTime(DateTime.now().year + 2),
      eventLoader: (day) {
        return widget.callGetAllEvents.call(day);
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          widget.selectedDateForEventsLoading.call(focusedDay);
        });
      },
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, day) => Container(alignment: Alignment.center, child: Text(DateFormat('MMMM yyyy', widget.currentLanguage).format(day))),
        markerBuilder: (context, date, events) {
          isFocusedDayDate = events.isNotEmpty;
          return _focusedDay != date ? Container(
            margin: const EdgeInsets.only(left: Dimens.marginSmall, bottom: Dimens.marginXSmall),
            child: Icon(
              events.isEmpty ? Icons.clear : Icons.done,
              color: events.isEmpty ? Colors.red : Colors.green,
              size: 19,
            ),
          ) : Container();
        },
        todayBuilder: (context, day, focusedDay) => Card(color: isFocusedDayDate ? AppColors.cardGreen_200.withOpacity(0.5) : AppColors.errorRed.withOpacity(0.5),
          shape: const CircleBorder(),
          child: Container(padding: const EdgeInsets.all(Dimens.paddingSmall), child: Text(day.day.toString(), style: const TextStyle(fontSize: Dimens.fontSizeMedium, color: Colors.white),)),),
        selectedBuilder: (context, day, focusedDay) => Card(color: isFocusedDayDate ? AppColors.mountainMeadow : AppColors.errorRed,
          shape: const CircleBorder(),
          child: Container(padding: const EdgeInsets.all(Dimens.paddingSmall), child: Text(day.day.toString(), style: const TextStyle(fontSize: Dimens.fontSizeMedium, color: Colors.white),)),),
      ),
    ),
    );
  }
}