import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/week_widget.dart';

import '../../infrastructure/helpers/date_time_helper.dart';

class WeekCalendarWidget extends StatelessWidget {
  final Function callGetAllEvents;
  final Function(DateTime) onDateClick;
  final DateTime? selectedDateTime;
  const WeekCalendarWidget({super.key, required this.callGetAllEvents, required this.onDateClick, this.selectedDateTime});

  static const double _cellSpacing = 9.0;

  @override
  Widget build(BuildContext context) {
    final weekDates = DateTimeHelper.getWeekDays(dateTime: selectedDateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
      child: Row(
        children: [
          for (int i = 0; i < weekDates.length; i++) ...[
            Expanded(
              child: InkWell(
                onTap: () => onDateClick.call(weekDates[i]),
                child: SizedBox(
                  height: Dimens.height70,
                  child: WeekWidget(
                    dateTime: weekDates[i],
                    selectedDateTime: selectedDateTime,
                    events: callGetAllEvents.call(weekDates[i]),
                  ),
                ),
              ),
            ),
            if (i < weekDates.length - 1) const SizedBox(width: _cellSpacing),
          ],
        ],
      ),
    );
  }

}