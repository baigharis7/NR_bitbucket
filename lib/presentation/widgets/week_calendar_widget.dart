import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/week_widget.dart';

import '../../infrastructure/helpers/date_time_helper.dart';

class WeekCalendarWidget extends StatelessWidget {
  final Function callGetAllEvents;
  const WeekCalendarWidget({super.key, required this.callGetAllEvents});

  @override
  Widget build(BuildContext context) {
    final weekDates = DateTimeHelper.getCurrentWeekDates();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...weekDates.map((date) => Expanded(child: WeekWidget(dateTime: date, events: callGetAllEvents.call(date)))),
      ],
    );
  }

}