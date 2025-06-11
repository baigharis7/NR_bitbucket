import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class RoutineDaysWidget extends StatefulWidget {
  final String? title;
  final Function(DateTime) onDaySelect;
  const RoutineDaysWidget({super.key, this.title, required this.onDaySelect});

  @override
  State<RoutineDaysWidget> createState() => _RoutineDaysWidgetState();
}

class _RoutineDaysWidgetState extends State<RoutineDaysWidget> {
  TimeOfDay selectedTime = const TimeOfDay(hour: 0, minute: 0);

  List<String> dayAbbreviations = [];
  List<bool> selectedDays = List.generate(7, (_) => false);

  void _generateWeekdayAbbreviations() {
    // final currentLanguage = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final DateFormat formatter = DateFormat.E('en'); // Spanish short weekday names
    // final weekDates = DateTimeHelper.getCurrentWeekDates();;
    dayAbbreviations = List.generate(7, (i) {
      final day = now.subtract(Duration(days: now.weekday - 1)).add(Duration(days: i));
      return formatter.format(day).substring(0, 2); // e.g., "Lu", "Ma"
    });
    // setState(() {});
  }

  @override
  void initState() {
    _generateWeekdayAbbreviations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title.orEmpty(), style: const TextStyle(color: AppColors.yellowishGreen, fontSize: Dimens.fontSize17, fontWeight: FontWeight.w500)),
        const SizedBox(height: Dimens.heightXXSmall),
        Wrap(
          spacing: 8,
          children: DateTimeHelper.getCurrentWeekDates().map((dateTime) {
            DateTime selectedDate = DateTime.now();
            final locale = Localizations.localeOf(context).languageCode;
            final isSelected = DateTimeHelper.isSameDay(dateTime, selectedDate);
            final dayAbbr = DateFormat.E(locale).format(dateTime); // LUN, MAR, etc.

            return GestureDetector(
              onTap: () {
                setState(() {
                  // selectedDays[index] = !isSelected;
                });
              },
              child: Container(
                height: Dimens.height32,
                width: Dimens.width32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.yellowishGreen : Colors.white,
                  borderRadius: BorderRadius.circular(Dimens.border50),
                  border: Border.all(color: isSelected ? AppColors.yellowishGreen : AppColors.cloudyGrey,),
                ),
                child: Text(
                  dayAbbr.substring(0, 2),
                  style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.yellowishGreen,
                      fontWeight: FontWeight.w500,
                      fontSize: Dimens.fontSizeNormal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}