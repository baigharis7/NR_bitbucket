import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

import 'dashboard_calendar_widget.dart';

class DatePickerBar extends StatefulWidget {
  DateTime selectedDateTime;
  final Function(DateTime) onChangeDate;
  DatePickerBar({super.key, DateTime? selectedDateTime, required this.onChangeDate}) : selectedDateTime = selectedDateTime ?? DateTime.now();
  @override
  _DatePickerBarState createState() => _DatePickerBarState();
}

class _DatePickerBarState extends State<DatePickerBar> {
  DateTime todayDate = DateTime.now();


  // Future<void> _showCalender() async {
  //   String currentLanguage = Localizations.localeOf(context).languageCode;
  //   await showDialog(context: context, builder: (context) => SimpleDialog(alignment: Alignment.topCenter,
  //     insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.padding5Large +5),
  //     contentPadding: EdgeInsets.zero,
  //     children: [
  //       DashboardCalendarWidget(currentLanguage: currentLanguage, focused: selectedDate, callGetAllEvents: (day) => [], selectedDateForEventsLoading: (date) {
  //         selectedDate = date;
  //         setState(() {
  //
  //         });
  //         // bloc.add(InitializeState(dateTime: date, onFinish: () => Navigator.pop(context)));
  //       },),
  //     ],
  //   ));
  // }

  // void _pickDate() async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime.now(),
  //   );
  //
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //   }
  // }

  void _goToPreviousDay() {
    // setState(() {
    //   selectedDate = selectedDate.subtract(Duration(days: 1));
      widget.onChangeDate.call(widget.selectedDateTime.subtract(const Duration(days: 1)));
    // });
  }

  void _goToNextDay() {
    if (!isToday) {
      // setState(() {
        // selectedDate = selectedDate.add(Duration(days: 1));
        widget.onChangeDate.call(widget.selectedDateTime.add(const Duration(days: 1)));
      // });
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return widget.selectedDateTime.year == now.year &&
        widget.selectedDateTime.month == now.month &&
        widget.selectedDateTime.day == now.day;
  }


  @override
  Widget build(BuildContext context) {
    final displayDate = isToday ? AppLocalizations.of(context)!.today : DateFormat('dd MMM yyyy').format(widget.selectedDateTime ?? todayDate);

    return Container(
      height: Dimens.height34,
      child: Row(
        children: [
          InkWell(
            onTap: _goToPreviousDay,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.yellowishGreen,
                border: Border.all(color: Colors.white, width: Dimens.width1),
                borderRadius: BorderRadius.circular(Dimens.border15),
              ),
              child: const Icon(Icons.arrow_left, color: Colors.white),
            ),
          ),
          const SizedBox(width: Dimens.width12),
          Expanded(
            child: Container(
              height: Dimens.height34,
              // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                border: Border.all(color: AppColors.greenishYellow, width: Dimens.width1),
                borderRadius: BorderRadius.circular(Dimens.border15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayDate,
                      style: const TextStyle(
                        color: AppColors.yellowishGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: Dimens.fontSizeNormal
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: SvgPicture.asset('assets/svg/calendar.svg', color: Colors.black, width: 28, height: 28,),
                  ),
                  const SizedBox(width: Dimens.width12),
                ],
              ),
            ),
          ),
          const SizedBox(width: Dimens.width12),
          InkWell(
            onTap: isToday ? null : _goToNextDay,
            child: Container(
              decoration: BoxDecoration(
                color: isToday ? Colors.black26 : AppColors.yellowishGreen,
                border: Border.all(color: isToday ? Colors.grey : Colors.white, width: Dimens.width1),
                borderRadius: BorderRadius.circular(Dimens.border15),
              ),
              child: Icon(Icons.arrow_right, color: isToday ? Colors.grey : Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
