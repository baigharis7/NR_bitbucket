import 'package:flutter/cupertino.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/week_widget.dart';

import '../../infrastructure/helpers/date_time_helper.dart';

class WeekCalendarWidget extends StatelessWidget {
  final Function callGetAllEvents;
  const WeekCalendarWidget({super.key, required this.callGetAllEvents});

  @override
  Widget build(BuildContext context) {
    final weekDates = DateTimeHelper.getCurrentWeekDates();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...weekDates.map((date) => SizedBox(width: Dimens.width55, height: Dimens.height70, child: WeekWidget(dateTime: date, events: callGetAllEvents.call(date)))),
        ],
      ),
    );
  }

}