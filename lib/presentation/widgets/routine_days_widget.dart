import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class RoutineDaysWidget extends StatefulWidget {
  final String? title;
  final List<int>? daysOfWeek;
  final Function(DateTime) onDaySelect;
  final Function(List<int>)? onBulkDaySelect;
  final bool showError;
  const RoutineDaysWidget({super.key, this.title, required this.onDaySelect, this.daysOfWeek, this.onBulkDaySelect, this.showError = false});

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
            final isSelected = widget.daysOfWeek.orEmpty().contains(dateTime.weekday);
            final dayAbbr = DateFormat.E(locale).format(dateTime); // LUN, MAR, etc.

            return GestureDetector(
              onTap: () {
                // setState(() {
                //   // selectedDays[index] = !isSelected;
                // });
                widget.onDaySelect.call(dateTime);
              },
              child: Container(
                height: Dimens.height32,
                width: Dimens.width32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.yellowishGreen : Colors.white,
                  borderRadius: BorderRadius.circular(Dimens.border50),
                  border: Border.all(color: isSelected ? AppColors.yellowishGreen : (widget.showError ? AppColors.errorRed : AppColors.cloudyGrey),),
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
        const SizedBox(height: 8),
        Row(
          children: [
            _buildQuickSelectButton(
              label: AppLocalizations.of(context)!.weekdays,
              days: const [1, 2, 3, 4, 5],
            ),
            const SizedBox(width: 8),
            _buildQuickSelectButton(
              label: AppLocalizations.of(context)!.weekend,
              days: const [6, 7],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickSelectButton({required String label, required List<int> days}) {
    final selectedDays = widget.daysOfWeek.orEmpty();
    final allSelected = days.every((d) => selectedDays.contains(d));

    return GestureDetector(
      onTap: () => widget.onBulkDaySelect?.call(days),
      child: Container(
        height: Dimens.height32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: allSelected ? AppColors.yellowishGreen : Colors.white,
          borderRadius: BorderRadius.circular(Dimens.border50),
          border: Border.all(color: allSelected ? AppColors.yellowishGreen : (widget.showError ? AppColors.errorRed : AppColors.cloudyGrey)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: allSelected ? Colors.white : AppColors.yellowishGreen,
            fontWeight: FontWeight.w500,
            fontSize: Dimens.fontSizeNormal,
          ),
        ),
      ),
    );
  }
}