import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/routine_days_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/save_button_widget.dart';

import '../../infrastructure/helpers/date_time_helper.dart';

class ItemRoutineWidget extends StatefulWidget {
  final Function(String)? onNameChange;
  final Function(TimeOfDay) onTimeChange;
  final Function(int)? onChangeWeekDays;
  final String? name;
  final List<int>? daysOfWeek;
  final TimeOfDay? scheduleTime;
  final bool? isFavorite;
  final bool? isCreateRoutine;
  final Function(bool)? onFavoriteChange;
  final Function(bool)? onChangeCreateRoutine;
  final int itemsLength;
  const ItemRoutineWidget({super.key, this.onNameChange, required this.onTimeChange, required this.onChangeWeekDays, this.name, required this.daysOfWeek, required this.scheduleTime, this.isFavorite, this.isCreateRoutine, this.onFavoriteChange, this.onChangeCreateRoutine, this.itemsLength = 0});

  @override
  State<ItemRoutineWidget> createState() => _ItemRoutineWidgetState();
}

class _ItemRoutineWidgetState extends State<ItemRoutineWidget> {
  final _itemNameController = TextEditingController();
  late TimeOfDay _selectedTime;
  late List<int> _daysOfWeek;
  late bool _isFavorite;
  late bool _isCreateRoutine;

  @override
  void initState() {
    _daysOfWeek = widget.daysOfWeek ?? [];
    _selectedTime = widget.scheduleTime ?? TimeOfDay.now();
    _isFavorite = widget.isFavorite ?? false;
    _isCreateRoutine = widget.isCreateRoutine ?? false;
    _itemNameController.text = widget.name.orEmpty();

    super.initState();
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), //  enables 24-hour picker UI
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
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
                child: Container(
                  padding: const EdgeInsets.all(Dimens.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.name,
                          style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.provide_name,
                          ),
                          controller: _itemNameController,
                          onChanged: (eventName) => widget.onNameChange?.call(eventName),
                        ),
                      ),
                      const SizedBox(height: Dimens.height12,),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 2,
                        title: Text(AppLocalizations.of(context)!.save_as_favorite),
                        leading: Switch.adaptive(value: _isFavorite, onChanged: (value) {
                          _isFavorite = !_isFavorite;
                          if(_isFavorite) _isCreateRoutine = false;
                          setState(() {});
                          widget.onFavoriteChange?.call(value);
                        },),
                        trailing: Image.asset('assets/icon/un_favorite_outlined.png', height: Dimens.heightXSmall, width: Dimens.width20),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 2,
                        title: Text(AppLocalizations.of(context)!.create_routine),
                        leading: Switch.adaptive(value: _isCreateRoutine, onChanged: (value) {
                          _isCreateRoutine = !_isCreateRoutine;
                          if(_isCreateRoutine) _isFavorite = false;
                          setState(() {});
                          widget.onChangeCreateRoutine?.call(value);
                        },),
                        trailing: Image.asset('assets/icon/routine_icon.png', height: 25, width: 25),
                      ),
                      const SizedBox(height: Dimens.height12),
                      if (_isCreateRoutine) Text(AppLocalizations.of(context)!.hour, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen)),
                      if (_isCreateRoutine) const SizedBox(height: Dimens.height5),
                      if (_isCreateRoutine) InkWell(
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
                      if (_isCreateRoutine) const SizedBox(height: Dimens.height15),
                      if (_isCreateRoutine) RoutineDaysWidget(title: AppLocalizations.of(context)!.days_of_week, daysOfWeek: _daysOfWeek, onDaySelect: (day) {
                        final dayNumber = day.weekday;
                        _daysOfWeek.contains(dayNumber) ? _daysOfWeek.remove(dayNumber) : _daysOfWeek.add(dayNumber);
                        setState(() {});
                        // widget.onChangeWeekDays?.call(dayNumber);
                      }, onBulkDaySelect: (days) {
                        final allSelected = days.every((d) => _daysOfWeek.contains(d));
                        if (allSelected) {
                          _daysOfWeek.removeWhere((d) => days.contains(d));
                        } else {
                          for (final d in days) {
                            if (!_daysOfWeek.contains(d)) _daysOfWeek.add(d);
                          }
                        }
                        setState(() {});
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
          title: AppLocalizations.of(context)!.ok,
          onTap: () {
            if (widget.itemsLength > 1 && _itemNameController.text.isEmptyOrNull()) {
              ToastHelper().showToast(text: AppLocalizations.of(context)!.provide_name);
              return;
            }

            if (_isCreateRoutine && _daysOfWeek.isEmpty) {
              ToastHelper().showToast(text: AppLocalizations.of(context)!.routine_time_day_error);
              return;
            }

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}