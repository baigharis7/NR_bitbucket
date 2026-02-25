import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/routine_days_widget.dart';

import '../../domain/models/favorites/food/meal_time.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';

class ItemTitleCard extends StatefulWidget {
  final String? name;
  final Function(String) onUpdateName;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final bool isRoutine;
  final VoidCallback onToggleRoutine;
  final int itemCount;
  // Routine settings
  final int? mealTime;
  final Function(int)? onUpdateMealTime;
  final TimeOfDay? scheduleTime;
  final Function(TimeOfDay)? onUpdateTime;
  final List<int>? daysOfWeek;
  final Function(int)? onUpdateDayOfWeek;
  final Function(List<int>)? onBulkDaySelect;
  final bool showTimePicker;

  const ItemTitleCard({
    super.key,
    this.name,
    required this.onUpdateName,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.isRoutine,
    required this.onToggleRoutine,
    required this.itemCount,
    this.mealTime,
    this.onUpdateMealTime,
    this.scheduleTime,
    this.onUpdateTime,
    this.daysOfWeek,
    this.onUpdateDayOfWeek,
    this.onBulkDaySelect,
    this.showTimePicker = true,
  });

  @override
  State<ItemTitleCard> createState() => _ItemTitleCardState();
}

class _ItemTitleCardState extends State<ItemTitleCard> {
  final _titleController = TextEditingController();
  late List<int> _daysOfWeek;
  late TimeOfDay _selectedTime;
  late int? _mealTime;

  @override
  void initState() {
    _titleController.text = widget.name.orEmpty();
    _daysOfWeek = widget.daysOfWeek.orEmpty();
    _selectedTime = widget.scheduleTime ?? TimeOfDay.now();
    _mealTime = widget.mealTime;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ItemTitleCard oldWidget) {
    if (widget.name != oldWidget.name && widget.name != _titleController.text) {
      _titleController.text = widget.name.orEmpty();
    }
    _daysOfWeek = widget.daysOfWeek.orEmpty();
    _selectedTime = widget.scheduleTime ?? TimeOfDay.now();
    _mealTime = widget.mealTime;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            useMaterial3: true,
            timePickerTheme: TimePickerThemeData(
              hourMinuteTextStyle: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
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
    final showComboError = widget.itemCount > 1 && widget.name.isEmptyOrNull();

    return Container(
      padding: const EdgeInsets.all(Dimens.paddingLarge),
      decoration: const BoxDecoration(
        color: AppColors.floralWhite,
        borderRadius: BorderRadius.all(Radius.circular(Dimens.border11)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with toggle icons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.item_title,
                      style: TextStyle(
                        fontSize: Dimens.fontSizeSmall,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeLarge,
                        fontWeight: FontWeight.w500,
                        color: AppColors.yellowishGreen,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.item_title,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w400,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.only(top: 4, bottom: 6),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.yellowishGreen),
                        ),
                      ),
                      onChanged: (value) => widget.onUpdateName(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Toggle icons – no outline, bigger, top-aligned with Title label
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: widget.onToggleFavorite,
                    child: Icon(
                      widget.isFavorite ? Icons.star : Icons.star_outline,
                      size: 28,
                      color: widget.isFavorite ? AppColors.yellowishGreen : AppColors.yellowishGreen50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: widget.onToggleRoutine,
                    child: Icon(
                      Icons.schedule,
                      size: 28,
                      color: widget.isRoutine ? AppColors.yellowishGreen : AppColors.yellowishGreen50,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Favorite callout
          if (widget.isFavorite) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.yellowishGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 16, color: AppColors.yellowishGreen),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.item_saved_as_favorite,
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeSmall,
                        color: AppColors.yellowishGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Routine callout
          if (widget.isRoutine && !widget.isFavorite) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.yellowishGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppColors.yellowishGreen),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.item_saved_as_routine,
                      style: const TextStyle(
                        fontSize: Dimens.fontSizeSmall,
                        color: AppColors.yellowishGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Combo name required error
          if (showComboError) ...[
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.combo_name_required,
              style: const TextStyle(
                fontSize: Dimens.fontSizeSmall,
                color: AppColors.errorRed,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          // Routine settings (expandable)
          if (widget.isRoutine) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Meal time dropdown (food screens only)
            if (widget.onUpdateMealTime != null) ...[
              Text(
                AppLocalizations.of(context)!.category,
                style: const TextStyle(
                  color: AppColors.yellowishGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: Dimens.fontSize17,
                ),
              ),
              const SizedBox(height: Dimens.height12),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.silver, width: 1),
                  ),
                ),
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
                        leading: Image.asset(
                          'assets/images/meal_time_${item.id.orZero()}.png',
                          height: Dimens.height32,
                          width: Dimens.width32,
                        ),
                        title: Text(item.name!),
                      ),
                    ),
                  ).toList(),
                ),
              ),
              const SizedBox(height: Dimens.height12),
            ],
            // Time picker (hidden for food routines via showTimePicker flag)
            if (widget.onUpdateTime != null && widget.showTimePicker) ...[
              Text(
                AppLocalizations.of(context)!.hour,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: Dimens.fontSize17,
                  color: AppColors.yellowishGreen,
                ),
              ),
              const SizedBox(height: Dimens.height5),
              InkWell(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.all(Dimens.padding10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(Dimens.border11),
                  ),
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: Dimens.fontSize17,
                      color: AppColors.yellowishGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimens.height15),
            ],
            // Days of week
            if (widget.onUpdateDayOfWeek != null)
              RoutineDaysWidget(
                title: AppLocalizations.of(context)!.days_of_week,
                daysOfWeek: _daysOfWeek,
                onDaySelect: (day) {
                  final dayNumber = day.weekday;
                  _daysOfWeek.contains(dayNumber)
                      ? _daysOfWeek.remove(dayNumber)
                      : _daysOfWeek.add(dayNumber);
                  setState(() {});
                },
                onBulkDaySelect: (days) {
                  final allSelected = days.every((d) => _daysOfWeek.contains(d));
                  if (allSelected) {
                    _daysOfWeek.removeWhere((d) => days.contains(d));
                  } else {
                    for (final d in days) {
                      if (!_daysOfWeek.contains(d)) _daysOfWeek.add(d);
                    }
                  }
                  setState(() {});
                },
              ),
          ],
        ],
      ),
    );
  }
}
