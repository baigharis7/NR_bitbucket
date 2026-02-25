import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/routine_days_widget.dart';

import '../../domain/models/favorites/food/meal_time.dart';
import '../../infrastructure/helpers/app_text_styles.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventOptionsWidget extends StatefulWidget{
  final String? name;
  final Function(String)? onUpdateName;
  final List<int>? daysOfWeek;
  final Function(int)? onUpdateDayOfWeek;
  final TimeOfDay? scheduleTime;
  final Function(TimeOfDay)? onUpdateTime;
  final int? mealTime;
  final Function(int)? onUpdateMealTime;

  const EventOptionsWidget({
    super.key,
    this.name,
    this.onUpdateName,
    this.daysOfWeek,
    this.onUpdateDayOfWeek,
    this.scheduleTime,
    this.onUpdateTime,
    this.mealTime,
    this.onUpdateMealTime,
  });

  @override
  State<EventOptionsWidget> createState() => _EventOptionsWidgetState();
}

class _EventOptionsWidgetState extends State<EventOptionsWidget> {
  final _itemNameController = TextEditingController();
  late List<int> _daysOfWeek;
  late TimeOfDay _selectedTime;
  late int? _mealTime;

  @override
  void initState() {
    _itemNameController.text = widget.name.orEmpty();
    _daysOfWeek = widget.daysOfWeek.orEmpty();
    _selectedTime = widget.scheduleTime ?? TimeOfDay.now();
    _mealTime = widget.mealTime;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant EventOptionsWidget oldWidget) {
    _itemNameController.text = widget.name.orEmpty();
    _daysOfWeek = widget.daysOfWeek.orEmpty();
    _selectedTime = widget.scheduleTime ?? TimeOfDay.now();
    _mealTime = widget.mealTime;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    super.dispose();
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(useMaterial3: true),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      widget.onUpdateTime?.call(picked);
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.paddingLarge),
      decoration: const BoxDecoration(color: AppColors.floralWhite, borderRadius: BorderRadius.all(Radius.circular(Dimens.border11))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.onUpdateName != null) Container(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.name,
              style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen),
            ),
          ),
          if (widget.onUpdateName != null) Container(
            alignment: Alignment.centerLeft,
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.write_here_hint,
              ),
              controller: _itemNameController,
              onChanged: (eventName) => widget.onUpdateName?.call(eventName),
            ),
          ),
          if (widget.onUpdateMealTime != null) const SizedBox(height: Dimens.height25),
          if (widget.onUpdateMealTime != null) Text(AppLocalizations.of(context)!.category, style: const TextStyle(color: AppColors.yellowishGreen, fontWeight: FontWeight.w500, fontSize: Dimens.fontSize17)),
          if (widget.onUpdateMealTime != null) const SizedBox(height: Dimens.height12),
          if (widget.onUpdateMealTime != null) Container(
            decoration: const BoxDecoration(
                borderRadius:
                BorderRadius.all(Radius.circular(11)),
                border: Border.fromBorderSide(
                    BorderSide(color: AppColors.silver, width: 1))),
            child: DropdownButton<int>(
              isExpanded: true,
              borderRadius: BorderRadius.circular(Dimens.border11),
              alignment: Alignment.center,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.silver),
              value: _mealTime,
              onChanged: (int? mealType) {
                _mealTime = mealType ?? 0;
                widget.onUpdateMealTime?.call(_mealTime!);
                setState(() {});
              },
              items: MealTime.getAllMealTimes()
                  .map<DropdownMenuItem<int>>(
                    (item) => DropdownMenuItem(
                  value: item.id,
                  child: ListTile(
                    leading: Image.asset('assets/images/meal_time_${item.id.orZero()}.png', height: Dimens.height32, width: Dimens.width32),
                    title: Text(item.name!),
                  ),
                ),
              )
                  .toList(),
            ),
          ),
          // const SizedBox(height: Dimens.height12,),
          // ListTile(
          //   contentPadding: EdgeInsets.zero,
          //   horizontalTitleGap: 2,
          //   title: Text(AppLocalizations.of(context)!.save_as_favorite),
          //   leading: Switch.adaptive(value: _isFavorite, onChanged: (value) {
          //     _isFavorite = !_isFavorite;
          //     if(_isFavorite) _isCreateRoutine = false;
          //     setState(() {});
          //     widget.onFavoriteChange?.call(value);
          //   },),
          //   trailing: Image.asset('assets/icon/un_favorite_outlined.png', height: Dimens.heightXSmall, width: Dimens.width20),
          // ),
          // ListTile(
          //   contentPadding: EdgeInsets.zero,
          //   horizontalTitleGap: 2,
          //   title: Text(AppLocalizations.of(context)!.create_routine),
          //   leading: Switch.adaptive(value: _isCreateRoutine, onChanged: (value) {
          //     _isCreateRoutine = !_isCreateRoutine;
          //     if(_isCreateRoutine) _isFavorite = false;
          //     setState(() {});
          //     widget.onChangeCreateRoutine?.call(value);
          //   },),
          //   trailing: Image.asset('assets/icon/routine_icon.png', height: 25, width: 25),
          // ),
          if (widget.onUpdateTime != null) const SizedBox(height: Dimens.height12),
          if (widget.onUpdateTime != null) Text(AppLocalizations.of(context)!.hour, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: Dimens.fontSize17, color: AppColors.yellowishGreen)),
          if (widget.onUpdateTime != null) const SizedBox(height: Dimens.height5),
          if (widget.onUpdateTime != null) InkWell(
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
          if (widget.onUpdateDayOfWeek != null) const SizedBox(height: Dimens.height15),
          if (widget.onUpdateDayOfWeek != null) RoutineDaysWidget(title: AppLocalizations.of(context)!.days_of_week, daysOfWeek: _daysOfWeek, onDaySelect: (day) {
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
    );
  }
}