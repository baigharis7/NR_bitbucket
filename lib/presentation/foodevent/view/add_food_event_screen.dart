import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/add_food_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_state.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_event_item.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/add_item_name_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/dash_title_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/date_picker_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/food_actions_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/food_event_foods_cluster.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/generic_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/meal_time_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/meal_type_selection_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/save_button_widget.dart';

import '../../../domain/models/favorites/food/food_favorite.dart';
import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../domain/models/foodevents/food_arguments_model.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/foodroutine/food_routine_event.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/remove_diac.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/mappers/food_event_mappers.dart';
import '../../mealtimedetails/view/meal_time_details_screen.dart';
import '../../updatemeal/view/update_meal_screen.dart';
import '../../widgets/box_type_radio_text_widget.dart';
import '../../widgets/item_info_card.dart';
// import 'package:remove_diacritic/remove_diacritic.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';

// TODO: tengo que poner lo de las bebidas en algún sitio.
class AddFoodEventScreen extends StatefulWidget {
  static const routeName = '/add_food_event';

  const AddFoodEventScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFoodEventState();
}

class _AddFoodEventState extends State<AddFoodEventScreen> {
  late AddFoodEventBloc bloc;
  TextEditingController _foodInputController = TextEditingController();
  late FocusNode _focusInputController;
  int filteredListLength = 0;


  // TODO: si esto permanece se puede convertir en un widget en un momento.
  void _showConfirmationDialog({String? message, required BuildContext context, Function? onDismiss}) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: message ?? AppLocalizations.of(context)!.food_event_successfully_saved),
    ),).then((value) {
      onDismiss?.call();
    }
    );
  }

  Future<void> showAddFoodNameDialog({
    required BuildContext context,
    required Function onFinish,
    required Function(String) onNameChange,
    required Function(TimeOfDay) onTimeChange,
    bool? isFavorite,
    bool? isCreateRoutine,
    int? mealTime,
    List<int>? daysOfWeek,
    String? eventName,
    TimeOfDay? scheduleTime,
    required Function(bool) onFavoriteChange,
    required Function(bool) onChangeCreateRoutine,
    required Function(int) onMealTieChange,
    required int ingredientLength,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AddItemNameDialog(
        title: AppLocalizations.of(context)!.food_name,
        onNameChange: (String foodName) => onNameChange.call(foodName),
        onSave: () => Navigator.pop(context),
        onCancel: () => Navigator.pop(context),
        isFavorite: isFavorite,
        onFavoriteChange: (value) => onFavoriteChange.call(value),
        isCreateRoutine: isCreateRoutine,
        onChangeCreateRoutine: (routine) => onChangeCreateRoutine.call(routine),
        onMealTieChange: (mealTime) => onMealTieChange.call(mealTime ?? 0),
        onChangeWeekDays: (weekDay) {},
        daysOfWeek: daysOfWeek,
        eventName: eventName,
        mealTime: mealTime,
        itemsLength: ingredientLength,
        onChangeScheduleTime: (scheduleTime) => onTimeChange.call(scheduleTime),
        scheduleTime: scheduleTime,
      ),
    );
  }

  @override
  void initState() {
    bloc = BlocProvider.of<AddFoodEventBloc>(context);

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is FoodArgumentsModel) {
            bloc.add(AddFoodArgumentModelEventAction(foodArgumentsModel: infoReceived));
          } else if (infoReceived is FoodFavorite) {
            bloc.add(UpdateFoodDataFromFavoritesAddFoodEventActions(foodFavorite: infoReceived));
          } else if (infoReceived is FoodRoutineEvent) {
            bloc.add(UpdateFoodRoutineFromRoutines(foodRoutineEvent: infoReceived));
          }
        }
      }
    });
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  void dispose() {
    _foodInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final eventHelper = EventsHelper();


    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<AddFoodEventBloc, AddFoodEventState>(
        listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }

          if (state.onError != null) {
            showErrorSnackBar(ctx, resolveError(context, state.onError!));
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Background image or gradient
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'), // Your image
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Blur effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0), // Needed to activate the blur
                ),
              ),

              // Foreground content for the user interaction
              GestureDetector(
                onTap: () => _focusInputController.unfocus(),
                behavior: HitTestBehavior.opaque,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge),
                      // child: (state.mealType ?? -1) <= -1 ? MealTypeSelectionWidget(onSaveMealType: (mealType) => bloc.add(AddFoodMealTypeEventAction(mealType: mealType))) : Column(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                            child: DatePickerBar(selectedDateTime: DateTimeHelper.dateTimeFromMilliseconds(state.foodEvent!.eventDate), onChangeDate: (dateTime) {
                              bloc.add(UpdateEventDateEventAction(dateTime: dateTime));
                            },),
                          ),
                          const SizedBox(height: Dimens.height12),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                            child: HeaderAddItemCardSection(
                              title: '${AppLocalizations.of(context)!.add} ${MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.foodEvent?.mealTime ?? 0)).name}',
                              image: 'assets/images/meal_time_${state.foodEvent?.mealTime}.png',
                              onBackTap: () => Navigator.pop(context),
                              items: state.foodNames?.foodsAndDrinksNames?.foodNames.orEmpty().map((item) => item.translate(context)).toList(),
                              onItemSelect: (option, focus) {
                                _focusInputController = focus;
                                final food = eventHelper.findFoodByFoodName(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                bloc.add(AddFoodFromEventAction(foodInEvent: food!));
                              },
                            ),
                          ),
                          // (state.foodsInEvent.orEmpty().isNotEmpty)
                          Column(children: [
                            if (state.foodEvent!.ingredients.orEmpty().isNotEmpty) Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                ...state.foodEvent!.ingredients.orEmpty().map((foodInEvent) {
                                  final option = eventHelper.findFoodNameFromId(foodInEvent.id, context, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                  final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                  return FoodEventItem(
                                    options: option,
                                    unitsFoodsMaster: state.unitsFoodsMaster!,
                                    unitsInfoMaster: state.unitsInfoMaster!,
                                    oilTypes: state.oilTypes,
                                    conversionFactors: state.conversionFactors,
                                    foodInEvent: foodInEvent,
                                    foodGroup: foodGroup.orEmpty(),
                                    cookingMethodsInfoMaster: state.cookingMethodsInfoMaster!,
                                    cookingMethodsMaster: state.cookingMethodsMaster!,
                                    onRemove: () => context.read<AddFoodEventBloc>().add(RemoveFoodFromEventAction(foodInEvent: foodInEvent)),
                                    onQtyChange: (changedFood) { bloc.add(UpdateFoodQuantityEventAction(foodInEvent: changedFood));},
                                    onUnitChange: (changedFood) => bloc.add(UpdateFoodUnitEventAction(foodInEvent: changedFood)),
                                    onCookingMethodChange: (changedFood) => bloc.add(UpdateFoodCookingMethodEventAction(foodInEvent: changedFood)),
                                    onConversionFactorChange: (changedFood) => bloc.add(UpdateFoodConversionFactor(foodInEvent: changedFood)),
                                    onOilUsedChange: (changedFood) => bloc.add(UpdateOilUsedEventAction(foodInEvent: changedFood)),
                                  );
                                }).toList(),
                                SizedBox(
                                  width: Dimens.widthLarge,
                                  child: Row(children: [
                                    Expanded(child: FoodActionsWidget(
                                      title: AppLocalizations.of(context)!.add_more_options,
                                      rightSideWidget: const Icon(Icons.radio_button_checked, color: AppColors.yellowishGreen),
                                      onTap: () => showAddFoodNameDialog(
                                        context: context,
                                        isFavorite: state.foodEvent?.isFavorite,
                                        isCreateRoutine: state.foodEvent!.isRoutine,
                                        mealTime: state.foodEvent?.mealTime,
                                        daysOfWeek: state.foodEvent?.daysOfWeek,
                                        eventName: state.foodEvent?.title,
                                        onFinish: () => Navigator.pop(context),
                                        onNameChange: (foodName) => bloc.add(AddFoodNameEventAction(foodName: foodName,),),
                                        onFavoriteChange: (value) => bloc.add(UpdateIsFavoriteEventAction()),
                                        onMealTieChange: (mealTime) => bloc.add(AddFoodMealTypeEventAction(mealType: mealTime)),
                                        onChangeCreateRoutine: (value) => bloc.add(UpdateIsCreateRoutineEventAction()),
                                        ingredientLength: state.foodEvent?.ingredients.length ?? 0,
                                        onTimeChange: (scheduleTime) => bloc.add(UpdateScheduleTimeAddFoodEventActions(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))),
                                        scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.foodEvent?.time),
                                      ),
                                    ))
                                  ],),
                                ),
                                // Row(children: [
                                //   Expanded(child: FoodActionsWidget(
                                //     title: AppLocalizations.of(context)!.add_more,
                                //     rightSideWidget: const Icon(Icons.add_circle),
                                //     onTap: () => _focusInputController.requestFocus(),
                                //   )),
                                //   Expanded(child: FoodActionsWidget(
                                //     title: AppLocalizations.of(context)!.create_dish,
                                //     rightSideWidget: Container(
                                //       height: 21,
                                //       width: 21,
                                //       decoration: BoxDecoration(
                                //         shape: BoxShape.circle,
                                //         color: Colors.white,
                                //         border: Border.all(
                                //           color: Colors.black,
                                //           width: Dimens.borderSmall,
                                //         ),
                                //       ),
                                //       child: Container(
                                //         margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                //         decoration: BoxDecoration(
                                //           shape: BoxShape.circle,
                                //           color: state.isCreateDish ?? false ? Colors.black : Colors.white,
                                //         ),
                                //       ),
                                //     ),
                                //     onTap: () => bloc.add(UpdateCreteDishEventAction()),
                                //     backgroundColor: AppColors.butter,
                                //   )),
                                // ]),
                              ]),
                            ),

                            if (state.foodEvent!.ingredients.orEmpty().isEmpty && state.foodFavorites.orEmpty().isNotEmpty) Column(children: [
                              const SizedBox(height: Dimens.height12),
                              DashTitleWidget(title: AppLocalizations.of(context)!.favorites + ' - ' + MealTime.getAllMealTimes().firstWhere((element) => element.id == state.foodEvent?.mealTime).name.orEmpty()),
                              ...state.foodFavorites.orEmpty().map((favFood) => ItemInfoCard(
                                title: favFood.title ?? NutritionUtils.findFoodsName(foodNames: state.foodNames?.foodsAndDrinksNames?.foodNames, ingredients: favFood.ingredients, context: context),
                                leadingSrc: 'assets/images/favorite_icon.png',
                                trailingSrc: 'assets/icon/add_icon.png',
                                color: state.foodsFromFavorite == favFood ? AppColors.butter : AppColors.floralWhite,
                                leadingTap: () => bloc.add(RemoveFavoriteFoodAddFoodEventAction(foodFavorite: favFood, onFinish: () {})),
                                trailingTap: () {
                                  favFood.eventId = DateTime.now().millisecondsSinceEpoch;
                                  favFood.eventDate = bloc.state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
                                  bloc.add(FinishAddFoodEventAction(
                                    foodEventSimple: mapToFoodEventSimpleFromFoodFavorite(favFood),
                                    onFinish: () => _showConfirmationDialog(
                                        message: AppLocalizations.of(context)!.food_event_successfully_saved,
                                        context: context,
                                        onDismiss: () => Navigator.popAndPushNamed(context, MealTimeDetailScreen.routeName, arguments: FoodArgumentsModel(mealTime: MealTime.getAllMealTimes().firstWhere((element) => element.id == state.foodEvent?.mealTime, orElse: () => Breakfast(),), selectedDateTime: DateTimeHelper.dateTimeFromMilliseconds(state.foodEvent!.eventDate)!)),
                                    ),),
                                  );
                                  },
                                subtitle: favFood.ingredients.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.amount}: ${favFood.ingredients[0].qty} ${NutritionUtils.findUnitNameFavFood(state.unitsInfoMaster?.unitsInfoMaster, favFood.ingredients, context)}.',
                                beforeTrailingSrc: 'assets/icon/edit_icon.png',
                                beforeTrailingTap: () => Navigator.pushNamed(context, UpdateMealScreen.routeName, arguments: favFood).then((value) => bloc.add(InitializeStateAction())),
                              ),
                              ),
                            ],),

                            if (state.foodEvent!.ingredients.orEmpty().isNotEmpty) Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                              child: GeneralButton(onTap: () {
                                if(state.foodEvent!.ingredients.isEmpty) {
                                  if (!state.foodsFromFavorite.isNull()) {
                                    bloc.add(FinishFoodFavouriteEventAction(onFinish: () => _showConfirmationDialog(
                                        context: context,
                                        onDismiss: () {},
                                    ),),);
                                  }
                                }
                                else {
                                  if (bloc.validateList() ?? true) return;

                                  if (state.foodEvent!.ingredients.orEmpty().length == 1 && (state.foodEvent?.title.isEmptyOrNull() == true)) {
                                    final foodName = NutritionUtils.findFoodsName(foodNames: state.foodNames?.foodsAndDrinksNames?.foodNames, ingredients: [state.foodEvent?.ingredients.orEmpty()[0]], context: context);
                                    // bloc.add(AddFoodNameEventAction(foodName: foodName,),);
                                    state.foodEvent?.title = foodName;
                                  }

                                  if (state.foodEvent!.ingredients.orEmpty().length > 1 && (state.foodEvent?.title.isEmptyOrNull() == true)) {
                                    showAddFoodNameDialog(
                                      context: context,
                                      isFavorite: state.foodEvent?.isFavorite,
                                      isCreateRoutine: state.foodEvent!.isRoutine,
                                      mealTime: state.foodEvent?.mealTime,
                                      daysOfWeek: state.foodEvent?.daysOfWeek,
                                      eventName: state.foodEvent?.title,
                                      onFinish: () => Navigator.pop(context),
                                      onNameChange: (foodName) => bloc.add(AddFoodNameEventAction(foodName: foodName,),),
                                      onFavoriteChange: (value) => bloc.add(UpdateIsFavoriteEventAction()),
                                      onMealTieChange: (mealTime) => bloc.add(AddFoodMealTypeEventAction(mealType: mealTime)),
                                      onChangeCreateRoutine: (value) => bloc.add(UpdateIsCreateRoutineEventAction()),
                                      ingredientLength: state.foodEvent?.ingredients.length ?? 0,
                                      onTimeChange: (scheduleTime) => bloc.add(UpdateScheduleTimeAddFoodEventActions(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))),
                                      scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.foodEvent?.time),
                                    );
                                  }

                                  if (state.foodEvent!.title.isNotEmptyOrNull()) {
                                  //   bloc.add(FinishFoodAsFavoriteEventAction(onFinish: () => _showConfirmationDialog(context)));
                                  // } else {
                                  //   bloc.add(FinishFoodEventAddFoodEventActions(onFinish: () => _showConfirmationDialog(context, () {
                                  //     Navigator.popAndPushNamed(context, MealTimeDetailScreen.routeName, arguments: FoodArgumentsModel(mealTime: MealTime.getAllMealTimes().firstWhere((element) => element.id == state.foodEvent?.mealTime, orElse: () => Breakfast(),), selectedDateTime: DateTimeHelper.dateTimeFromMilliseconds(state.foodEvent!.eventDate)!));
                                  //   })));

                                    if (state.foodEvent?.isFavorite ?? false) {
                                      bloc.add(FinishFoodAsFavoriteEventAction(foodFavorite: state.foodEvent!, onFinish: () => _showConfirmationDialog(
                                        message: AppLocalizations.of(context)!.food_favorite_successfully_saved,
                                          context: context,
                                          onDismiss: () {},
                                      ),),);
                                    }
                                    else if (state.foodEvent?.isRoutine == true && state.foodEvent?.daysOfWeek?.isNotEmpty == true) {
                                      state.foodEvent?.userId = '';
                                      state.foodEvent?.eventDate = state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
                                      final foodEventRoutine = mapToFoodRoutineEventFromFoodFavorite(state.foodEvent!);
                                      bloc.add(FinishAddFoodRoutineEventAction(foodRoutineEvent: foodEventRoutine, onFinish: () => _showConfirmationDialog(
                                        message: AppLocalizations.of(context)!.food_routine_successfully_saved,
                                          context: context,
                                          onDismiss: () {},
                                      ),),);
                                    } else {
                                      state.foodEvent?.userId = '';
                                      state.foodEvent?.eventDate = state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
                                      final foodEventSimple = mapToFoodEventSimpleFromFoodFavorite(state.foodEvent!);
                                      bloc.add(FinishAddFoodEventAction(foodEventSimple: foodEventSimple, onFinish: () => _showConfirmationDialog(
                                        message: AppLocalizations.of(context)!.food_event_successfully_saved,
                                          context: context,
                                          onDismiss: () => Navigator.popAndPushNamed(context, MealTimeDetailScreen.routeName, arguments: FoodArgumentsModel(mealTime: MealTime.getAllMealTimes().firstWhere((element) => element.id == state.foodEvent?.mealTime, orElse: () => Breakfast(),), selectedDateTime: DateTimeHelper.dateTimeFromMilliseconds(state.foodEvent!.eventDate)!)),
                                      ),),);
                                    }
                                  }
                                  // bloc.add(FinishFoodWithoutCreateDishEventAction(context: context, onFinish: () => _showConfirmationDialog(context)));
                                }
                              },
                              ),
                            ),
                          ],),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
