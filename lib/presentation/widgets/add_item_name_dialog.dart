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
  final Function onFinish;
  final Function onCancel;
  const AddItemNameDialog({super.key, required this.title, required this.onNameChange, required this.onFinish, required this.onCancel});

  @override
  State<AddItemNameDialog> createState() => _AddItemNameDialogState();
}

class _AddItemNameDialogState extends State<AddItemNameDialog> {
  late AddFoodEventBloc bloc;
  final _itemNameController = TextEditingController();

  @override
  void initState() {
    bloc = BlocProvider.of<AddFoodEventBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
      child: BlocProvider.value(value: bloc,
          child: BlocConsumer<AddFoodEventBloc, AddFoodEventState>(
        listener: (context, state) {},
        builder: (context, state) =>
            Column(
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
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 2,
                    title: Text(AppLocalizations.of(context)!.save_as_favorite),
                    leading: Switch.adaptive(value: state.isFavorite ?? false, onChanged: (value) { bloc.add(UpdateIsFavoriteEventAction()); },),
                    trailing: Image.asset('assets/icon/un_favorite_outlined.png', height: Dimens.heightXSmall, width: Dimens.width20),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 2,
                    title: Text(AppLocalizations.of(context)!.create_routine),
                    leading: Switch.adaptive(value: state.isCreateRoutine ?? false, onChanged: (value) { bloc.add(UpdateIsCreateRoutineEventAction()); },),
                    trailing: Image.asset('assets/icon/routine_icon.png', height: 25, width: 25),
                  ),
                  if (state.isCreateRoutine ?? false)  Text(AppLocalizations.of(context)!.schedule, style: const TextStyle(color: AppColors.yellowishGreen, fontWeight: FontWeight.w500, fontSize: Dimens.fontSize17)),
                  if (state.isCreateRoutine ?? false)  const SizedBox(height: Dimens.height12),
                  if (state.isCreateRoutine ?? false) Container(
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
                      value: state.mealType,
                      onChanged: (int? mealType) {
                        bloc.add(AddFoodMealTypeEventAction(mealType: mealType!));
                      },
                      items: MealTime.getAllMealTimes()
                          .map<DropdownMenuItem<int>>(
                            (item) => DropdownMenuItem(
                          value: item.id,
                          child: Column(
                            children: [
                              SizedBox(height: 4,),
                              Row(children: [
                                Image.asset('assets/images/meal_time_${item.id.orZero()}.png', height: Dimens.height32, width: Dimens.width32),
                                Text(item.name!),
                              ],),
                              // SizedBox(height: Dimens.height12,),
                              Divider(height: 1, thickness: 1, color: Colors.black,),
                              // ListTile(
                              //   leading: Image.asset('assets/images/meal_time_${item.id.orZero()}.png', height: Dimens.height32, width: Dimens.width32),
                              //   title: Text(item.name!),
                              // ),
                            ],
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                  if (state.isCreateRoutine ?? false) const SizedBox(height: Dimens.height12,),
                  if (state.isCreateRoutine ?? false) RoutineDaysWidget(title: AppLocalizations.of(context)!.days_of_week, daysOfWeek: state.daysOfWeek, onDaySelect: (day) {
                    final dateMilliseconds = DateTimeHelper.calculateMidNightMillisecondsFromDateTime(day);
                    bloc.add(UpdateDaysOfWeekEventAction(day: dateMilliseconds));
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
                if (_itemNameController.text == '') {
                  ToastHelper().showToast(text: AppLocalizations.of(context)!.favorite_name_required);
                } else {
                  widget.onFinish.call();
                }
              },
            ),
          ),
        ],
      ),
          ),
      ),

    );
  }
}