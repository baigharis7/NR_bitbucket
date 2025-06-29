import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/routine_days_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/save_button_widget.dart';

import '../../infrastructure/helpers/date_time_helper.dart';

class ItemRoutineWidget extends StatefulWidget {
  final Function(TimeOfDay) onTimeChange;
  final Function(int)? onChangeWeekDays;
  final List<int>? daysOfWeek;
  final TimeOfDay? scheduleTime;
  const ItemRoutineWidget({super.key, required this.onTimeChange, required this.onChangeWeekDays, required this.daysOfWeek, required this.scheduleTime});

  @override
  State<ItemRoutineWidget> createState() => _ItemRoutineWidgetState();
}

class _ItemRoutineWidgetState extends State<ItemRoutineWidget> {
  late TimeOfDay _selectedTime;
  late List<int> _daysOfWeek;

  @override
  void initState() {
    _daysOfWeek = widget.daysOfWeek ?? [];
    _selectedTime = widget.scheduleTime ?? TimeOfDay.now();
    super.initState();
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // 👈 enables 24-hour picker UI
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.onTimeChange.call(picked);
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;

    return SimpleDialog(
      backgroundColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(Dimens.paddingXLarge),
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
      children: [
        Column(
          children: [
            SizedBox(
              width: mediaQuerySize.width,
              // height: mediaQuerySize.height/2.5,
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
                child: Container(
                  padding: const EdgeInsets.all(Dimens.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.create_routine,
                            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
                          ),
                          const Icon(Icons.access_time, color: AppColors.yellowishGreen),
                        ],
                      ),
                      const SizedBox(height: Dimens.height12),
                      Text(AppLocalizations.of(context)!.hour, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen)),
                      const SizedBox(height: Dimens.height5),
                      InkWell(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.all(Dimens.padding10,),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(Dimens.border11),
                          ),
                          child: Text(
                            _selectedTime.format(context),
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimens.height15),
                      RoutineDaysWidget(title: AppLocalizations.of(context)!.days_of_week, daysOfWeek: _daysOfWeek, onDaySelect: (day) {
                        final dayNumber = day.weekday;
                        _daysOfWeek.contains(dayNumber) ? _daysOfWeek.remove(dayNumber) : _daysOfWeek.add(dayNumber);
                        setState(() {});
                        // widget.onChangeWeekDays?.call(dayNumber);
                      },),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimens.height32),
        GeneralButton(
          title: AppLocalizations.of(context)!.save,
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}