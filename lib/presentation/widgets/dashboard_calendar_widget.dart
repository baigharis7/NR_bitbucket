import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../infrastructure/helpers/date_time_helper.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';

class DashboardCalendarWidget extends StatefulWidget {
  final Function callGetAllEvents;
  const DashboardCalendarWidget({
    super.key,
    required this.callGetAllEvents,
  });

  @override
  State<DashboardCalendarWidget> createState() => _DashboardCalendarWidgetState();
}

class _DashboardCalendarWidgetState extends State<DashboardCalendarWidget> {
  DateTime _selectedDay = DateTimeHelper().provideCurrentDate();
  DateTime _focusedDay = DateTimeHelper().provideCurrentDate();
  bool isFocusedDayDate = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 400,child:
    TableCalendar(
      headerVisible: false,
      daysOfWeekStyle: DaysOfWeekStyle(decoration: const BoxDecoration(color: AppColors.mountainMeadow,), weekendStyle: const TextStyle(color: Colors.black, fontSize: Dimens.fontSizeXSmall, overflow: TextOverflow.ellipsis),
        dowTextFormatter: (date, locale) => DateFormat('EEEE').format(date), weekdayStyle: const TextStyle(color: Colors.black, fontSize: Dimens.fontSizeXSmall, overflow: TextOverflow.ellipsis),),
      daysOfWeekHeight: Dimens.heightSmall-20,
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
      ),
      firstDay: DateTime(DateTime.now().year-1),
      focusedDay: _focusedDay,
      lastDay: DateTime.now(),
      eventLoader: (day) {
        return widget.callGetAllEvents.call(day);
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          // bloc.add(SelectDayEventsActions(selectedDay: _selectedDay));
        });
      },
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, day) => Container(alignment: Alignment.center, child: Text(DateFormat('MMMM yyyy').format(day))),
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
        todayBuilder: (context, day, focusedDay) => Card(color: isFocusedDayDate ? AppColors.cardGreen_200 : AppColors.errorRed,
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