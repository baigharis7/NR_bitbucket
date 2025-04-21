import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class WeekWidget extends StatelessWidget {
  final DateTime dateTime;
  final List<dynamic> events;
  WeekWidget({super.key, required this.dateTime, required this.events});

  final todayDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;
    final isToday = DateTimeHelper.isSameDay(dateTime, DateTime.now());
    final isSelected = DateTimeHelper.isSameDay(dateTime, selectedDate);
    final dayNum = DateFormat('d').format(dateTime);
    final dayAbbr = DateFormat.E(locale).format(dateTime); // LUN, MAR, etc.



    return GestureDetector(
      onTap: () {},
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: Dimens.widthSmall,
            height: Dimens.width80,
            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXSmall),
            decoration: BoxDecoration( // Replace with your background
              borderRadius: BorderRadius.circular(Dimens.border20),
              border: Border.all(color: Colors.white, width: Dimens.width1),
              color: isToday ? Colors.white : events.orEmpty().isNotEmpty ? AppColors.darkJungleGreen : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNum,
                  style: TextStyle(
                    fontSize: Dimens.fontSizeXLarge,
                    color: isToday ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dayAbbr,
                  style: TextStyle(
                    fontSize: Dimens.fontSizeNormal,
                    color: isToday ? Colors.black : Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          if (dateTime.isBefore(todayDate) && events.isEmpty) Positioned(
            top: 2,
            right: 4,
            child: Container(
              width: Dimens.width12,
              height: Dimens.height12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}