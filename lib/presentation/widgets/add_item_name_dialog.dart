import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/routine_days_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/save_button_widget.dart';

import '../../infrastructure/helpers/toast_helper.dart';
import '../../infrastructure/utils/app_color.dart';
import '../../infrastructure/utils/dimens.dart';
import '../foodevent/bloc/add_food_event_bloc.dart';
import '../foodevent/bloc/add_food_event_state.dart';

class AddItemNameDialog extends StatefulWidget {
  final String title;
  final Function(String) onNameChange;
  final Function onSave;
  final Function onCancel;
  final bool? isFavorite;
  final Function(bool)? onFavoriteChange;
  final bool? isCreateRoutine;
  final Function(bool)? onChangeCreateRoutine;
  final Function(int)? onChangeWeekDays;
  final Function(int?)? onMealTieChange;
  final List<int>? daysOfWeek;
  final int? mealTime;
  const AddItemNameDialog({super.key,
    required this.title,
    required this.onNameChange,
    required this.onSave,
    required this.onCancel,
    this.isFavorite,
    this.onFavoriteChange,
    this.isCreateRoutine,
    this.onChangeWeekDays,
    this.onMealTieChange,
    this.daysOfWeek,
    this.onChangeCreateRoutine,
    this.mealTime,
  });

  @override
  State<AddItemNameDialog> createState() => _AddItemNameDialogState();
}

class _AddItemNameDialogState extends State<AddItemNameDialog> {
  late AddFoodEventBloc bloc;
  final _itemNameController = TextEditingController();
  late bool _isFavorite;
  late bool _isCreateRoutine;
  late int _mealTime;
  late List<int> _daysOfWeek;

  @override
  void initState() {
    bloc = BlocProvider.of<AddFoodEventBloc>(context);
    _isFavorite = widget.isFavorite ?? false;
    _isCreateRoutine = widget.isCreateRoutine ?? false;
    _mealTime = widget.mealTime ?? 0;
    _daysOfWeek = widget.daysOfWeek ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              margin: const EdgeInsets.all(Dimens.marginXXLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(
                  //   alignment: Alignment.centerRight,
                  //   child: IconButton(
                  //     onPressed: () => widget.onCancel.call(),
                  //     icon: const Icon(Icons.clear,),
                  //   ),
                  // ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.yellowishGreen,
                        fontSize: Dimens.fontSize17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.write_here_hint,
                      ),
                      controller: _itemNameController,
                      onChanged: (foodName) => widget.onNameChange.call(foodName),
                    ),
                  ),
                  const SizedBox(height: Dimens.height12,),
                  if (widget.onFavoriteChange != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 2,
                    title: Text(AppLocalizations.of(context)!.save_as_favorite),
                    leading: Switch.adaptive(value: _isFavorite, onChanged: (value) {
                      _isFavorite = !_isFavorite;
                      setState(() {});
                      widget.onFavoriteChange?.call(value);
                      },),
                    trailing: Image.asset('assets/icon/un_favorite_outlined.png', height: Dimens.heightXSmall, width: Dimens.width20),
                  ),
                  if (widget.onChangeCreateRoutine != null) ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 2,
                    title: Text(AppLocalizations.of(context)!.create_routine),
                    leading: Switch.adaptive(value: _isCreateRoutine, onChanged: (value) {
                      _isCreateRoutine = !_isCreateRoutine;
                      setState(() {});
                      widget.onChangeCreateRoutine?.call(value);
                      },),
                    trailing: Image.asset('assets/icon/routine_icon.png', height: 25, width: 25),
                  ),
                  if (_isCreateRoutine)  Text(AppLocalizations.of(context)!.schedule, style: const TextStyle(color: AppColors.yellowishGreen, fontWeight: FontWeight.w500, fontSize: Dimens.fontSize17)),
                  if (_isCreateRoutine)  const SizedBox(height: Dimens.height12),
                  if (_isCreateRoutine) Container(
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
                        setState(() {});
                        widget.onMealTieChange?.call(mealType);
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
                  if (_isCreateRoutine) const SizedBox(height: Dimens.height12,),
                  if (_isCreateRoutine) RoutineDaysWidget(title: AppLocalizations.of(context)!.days_of_week, daysOfWeek: _daysOfWeek, onDaySelect: (day) {
                    // final dateMilliseconds = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(day);
                    // _daysOfWeek.contains(dateMilliseconds) ? _daysOfWeek.remove(dateMilliseconds) : _daysOfWeek.add(dateMilliseconds);
                    final dayNumber = day.weekday - 1;
                    _daysOfWeek.contains(dayNumber) ? _daysOfWeek.remove(dayNumber) : _daysOfWeek.add(dayNumber);
                    setState(() {});
                    widget.onChangeWeekDays?.call(dayNumber);
                  },),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
            child: SaveButton(
              text: AppLocalizations.of(context)!.save,
              onPressed: () {
                // if (_itemNameController.text == '') {
                //   ToastHelper().showToast(text: AppLocalizations.of(context)!.favorite_name_required);
                // } else {
                widget.onSave.call();
                // }
              },
            ),
          ),
        ],
      ),

    );
  }
}