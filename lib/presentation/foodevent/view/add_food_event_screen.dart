import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_state.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_event_item.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/dash_title_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/favorites_recent_toggle.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/date_picker_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_title_card.dart';

import '../../../domain/models/favorites/food/food_favorite.dart';
import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../domain/models/foodevents/food_arguments_model.dart';
import '../../../domain/models/foodroutine/food_routine_event.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/mappers/food_event_mappers.dart';
import '../../mealtimedetails/view/meal_time_details_screen.dart';
import '../../updatemeal/view/update_meal_screen.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/item_info_card.dart';

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
  final ScrollController _scrollController = ScrollController();
  int filteredListLength = 0;
  bool _showValidation = false;
  bool _showRoutineValidation = false;

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
    _scrollController.dispose();
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
          final showFavRecent = state.foodEvent!.ingredients.orEmpty().isEmpty &&
              (state.foodFavorites.orEmpty().isNotEmpty || state.recentFoodItems.orEmpty().isNotEmpty);

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
                  bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
                  body: SafeArea(
                    child: showFavRecent
                      // ---- Fixed header + scrollable fav/recent list ----
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: Dimens.paddingLarge),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
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
                                      searchHintText: AppLocalizations.of(context)!.search_food_hint,
                                      items: state.foodNames?.foodsAndDrinksNames?.foodNames.orEmpty().map((item) => item.translate(context)).toList(),
                                      onItemSelect: (option, focus) {
                                        _focusInputController = focus;
                                        final food = eventHelper.findFoodByFoodName(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                        bloc.add(AddFoodFromEventAction(foodInEvent: food!));
                                        // Auto-scroll to newly added item
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          _scrollController.animateTo(
                                            _scrollController.position.maxScrollExtent,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOut,
                                          );
                                        });
                                        // Auto-title logic
                                        final currentCount = state.foodEvent!.ingredients.orEmpty().length;
                                        if (currentCount == 0) {
                                          // First item being added: set title to item name
                                          bloc.add(AddFoodNameEventAction(foodName: option));
                                        } else if (currentCount == 1) {
                                          // Second item: clear title for combo naming
                                          bloc.add(AddFoodNameEventAction(foodName: ''));
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: Dimens.height12),
                                  if (state.foodEvent?.isRoutine != true && state.foodEvent?.isFavorite != true)
                                  FavoritesRecentToggle(
                                    selectedIndex: state.favRecentTab,
                                    onTap: (index) => bloc.add(SwitchFavRecentTabAction(tabIndex: index)),
                                  ),
                                  const SizedBox(height: Dimens.height5),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Builder(builder: (context) {
                                final isPreselect = state.foodEvent?.isRoutine == true || state.foodEvent?.isFavorite == true;
                                return ListView(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  children: [
                                    if (state.favRecentTab == 0 || state.foodEvent?.isFavorite == true) ...state.recentFoodItems.orEmpty().map((recentFood) => ItemInfoCard(
                                      title: recentFood.title ?? NutritionUtils.findFoodsName(foodNames: state.foodNames?.foodsAndDrinksNames?.foodNames, ingredients: recentFood.ingredients, context: context),
                                      trailingSrc: isPreselect ? null : 'assets/icon/add_icon.png',
                                      trailingIcon: isPreselect ? Icons.arrow_forward_rounded : null,
                                      color: AppColors.floralWhite,
                                      trailingTap: isPreselect
                                        ? () => bloc.add(state.foodEvent?.isRoutine == true
                                            ? PrefillFoodForRoutineAction(foodFavorite: recentFood)
                                            : PrefillFoodForFavoriteAction(foodFavorite: recentFood))
                                        : () {
                                            recentFood.eventId = DateTime.now().millisecondsSinceEpoch;
                                            recentFood.eventDate = bloc.state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
                                            bloc.add(FinishAddFoodEventAction(
                                              foodEventSimple: mapToFoodEventSimpleFromFoodFavorite(recentFood),
                                              onFinish: () => _showConfirmationDialog(
                                                  message: AppLocalizations.of(context)!.food_event_successfully_saved,
                                                  context: context,
                                                  onDismiss: () => Navigator.popAndPushNamed(context, MealTimeDetailScreen.routeName, arguments: FoodArgumentsModel(mealTime: MealTime.getAllMealTimes().firstWhere((element) => element.id == state.foodEvent?.mealTime, orElse: () => Breakfast(),), selectedDateTime: DateTimeHelper.dateTimeFromMilliseconds(state.foodEvent!.eventDate)!)),
                                              ),),
                                            );
                                          },
                                      subtitle: recentFood.ingredients.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.amount}: ${recentFood.ingredients[0].qty} ${NutritionUtils.findUnitNameFavFood(state.unitsInfoMaster?.unitsInfoMaster, recentFood.ingredients, context)}.',
                                      beforeTrailingSrc: isPreselect ? null : 'assets/icon/edit_icon.png',
                                      beforeTrailingTap: isPreselect ? null : () => Navigator.pushNamed(context, UpdateMealScreen.routeName, arguments: recentFood).then((value) => bloc.add(InitializeStateAction())),
                                    ),),
                                    if (state.favRecentTab == 1 && state.foodEvent?.isFavorite != true) ...state.foodFavorites.orEmpty().map((favFood) => ItemInfoCard(
                                      title: favFood.title ?? NutritionUtils.findFoodsName(foodNames: state.foodNames?.foodsAndDrinksNames?.foodNames, ingredients: favFood.ingredients, context: context),
                                      leadingSrc: isPreselect ? null : 'assets/images/favorite_icon.png',
                                      trailingSrc: isPreselect ? null : 'assets/icon/add_icon.png',
                                      trailingIcon: isPreselect ? Icons.arrow_forward_rounded : null,
                                      color: state.foodsFromFavorite == favFood ? AppColors.butter : AppColors.floralWhite,
                                      leadingTap: isPreselect ? null : () => bloc.add(RemoveFavoriteFoodAddFoodEventAction(foodFavorite: favFood, onFinish: () {})),
                                      trailingTap: isPreselect
                                        ? () => bloc.add(state.foodEvent?.isRoutine == true
                                            ? PrefillFoodForRoutineAction(foodFavorite: favFood)
                                            : PrefillFoodForFavoriteAction(foodFavorite: favFood))
                                        : () {
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
                                      beforeTrailingSrc: isPreselect ? null : 'assets/icon/edit_icon.png',
                                      beforeTrailingTap: isPreselect ? null : () => Navigator.pushNamed(context, UpdateMealScreen.routeName, arguments: favFood).then((value) => bloc.add(InitializeStateAction())),
                                    ),),
                                  ],
                                );
                              }),
                            ),
                          ],
                        )
                      // ---- Current layout: ingredients or empty state ----
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge),
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
                                        searchHintText: AppLocalizations.of(context)!.search_food_hint,
                                        items: state.foodNames?.foodsAndDrinksNames?.foodNames.orEmpty().map((item) => item.translate(context)).toList(),
                                        onItemSelect: (option, focus) {
                                          _focusInputController = focus;
                                          final food = eventHelper.findFoodByFoodName(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                          bloc.add(AddFoodFromEventAction(foodInEvent: food!));
                                          // Auto-scroll to newly added item
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            _scrollController.animateTo(
                                              _scrollController.position.maxScrollExtent,
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeOut,
                                            );
                                          });
                                          // Auto-title logic
                                          final currentCount = state.foodEvent!.ingredients.orEmpty().length;
                                          if (currentCount == 0) {
                                            // First item being added: set title to item name
                                            bloc.add(AddFoodNameEventAction(foodName: option));
                                          } else if (currentCount == 1) {
                                            // Second item: clear title for combo naming
                                            bloc.add(AddFoodNameEventAction(foodName: ''));
                                          }
                                        },
                                      ),
                                    ),
                                    if (state.foodEvent!.ingredients.orEmpty().isNotEmpty) Container(
                                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        const SizedBox(height: Dimens.height12),
                                        // Title card with favorite/routine toggles
                                        ItemTitleCard(
                                          name: state.foodEvent?.title,
                                          onUpdateName: (name) => bloc.add(AddFoodNameEventAction(foodName: name)),
                                          isFavorite: state.foodEvent?.isFavorite ?? false,
                                          onToggleFavorite: () {
                                            if (state.foodEvent?.isFavorite != true) {
                                              // Selecting favorite: deselect routine
                                              if (state.foodEvent?.isRoutine == true) bloc.add(UpdateIsCreateRoutineEventAction());
                                              bloc.add(UpdateIsFavoriteEventAction());
                                            } else {
                                              bloc.add(UpdateIsFavoriteEventAction());
                                            }
                                          },
                                          isRoutine: state.foodEvent?.isRoutine ?? false,
                                          onToggleRoutine: () {
                                            if (state.foodEvent?.isRoutine != true) {
                                              // Selecting routine: deselect favorite
                                              if (state.foodEvent?.isFavorite == true) bloc.add(UpdateIsFavoriteEventAction());
                                              bloc.add(UpdateIsCreateRoutineEventAction());
                                            } else {
                                              bloc.add(UpdateIsCreateRoutineEventAction());
                                            }
                                          },
                                          itemCount: state.foodEvent!.ingredients.orEmpty().length,
                                          mealTime: state.foodEvent?.mealTime,
                                          onUpdateMealTime: state.foodEvent?.mealTime == 3 ? null : (mealTime) => bloc.add(AddFoodMealTypeEventAction(mealType: mealTime)),
                                          scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.foodEvent?.time),
                                          onUpdateTime: (scheduleTime) => bloc.add(UpdateScheduleTimeAddFoodEventActions(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))),
                                          daysOfWeek: state.foodEvent?.daysOfWeek,
                                          onUpdateDayOfWeek: (dayOfWeek) {},
                                          showTimePicker: state.foodEvent?.mealTime == 3,
                                          showRoutineValidation: _showRoutineValidation,
                                        ),
                                        // Item cards with connector lines
                                        ...state.foodEvent!.ingredients.orEmpty().asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final foodInEvent = entry.value;
                                          final option = eventHelper.findFoodNameFromId(foodInEvent.id, context, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                          final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                          return Column(
                                            children: [
                                              FoodEventItem(
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
                                                showValidation: _showValidation,
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                        // Add More button
                                        const SizedBox(height: Dimens.marginSmall),
                                        Center(
                                          child: SizedBox(
                                            width: Dimens.widthLarge,
                                            height: Dimens.height55,
                                            child: ListTile(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.border15)),
                                              tileColor: AppColors.floralWhite,
                                              onTap: () {
                                                if (bloc.validateList() ?? false) {
                                                  setState(() { _showValidation = true; });
                                                  return;
                                                }
                                                setState(() { _showValidation = false; });
                                                _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                                _focusInputController.requestFocus();
                                              },
                                              title: Text(AppLocalizations.of(context)!.add_more),
                                              trailing: const Icon(Icons.add_circle, color: AppColors.yellowishGreen),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: Dimens.paddingXLarge),
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (state.foodEvent!.ingredients.orEmpty().isNotEmpty) Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginSmall),
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
                                        if (bloc.validateList() ?? true) {
                                          setState(() { _showValidation = true; });
                                          _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                          return;
                                        }

                                        // Auto-set title for single items
                                        if (state.foodEvent!.ingredients.orEmpty().length == 1 && (state.foodEvent?.title.isEmptyOrNull() == true)) {
                                          final foodName = NutritionUtils.findFoodsName(foodNames: state.foodNames?.foodsAndDrinksNames?.foodNames, ingredients: [state.foodEvent?.ingredients.orEmpty()[0]], context: context);
                                          state.foodEvent?.title = foodName;
                                        }

                                        // Block save if combo has no name (inline error is shown in the title card)
                                        if (state.foodEvent!.ingredients.orEmpty().length > 1 && (state.foodEvent?.title.isEmptyOrNull() == true)) {
                                          _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                          return;
                                        }

                                        if (state.foodEvent!.title.isNotEmptyOrNull()) {
                                        //   bloc.add(FinishFoodAsFavoriteEventAction(onFinish: () => _showConfirmationDialog(context)));
                                        // } else {
                                        //   bloc.add(FinishFoodEventAddFoodEventActions(onFinish: () => _showConfirmationDialog(context, () {
                                        //     Navigator.popAndPushNamed(context, MealTimeDetailScreen.routeName, arguments: FoodArgumentsModel(mealTime: MealTime.getAllMealTimes().firstWhere((element) => element.id == state.foodEvent?.mealTime, orElse: () => Breakfast(),), selectedDateTime: DateTimeHelper.dateTimeFromMilliseconds(state.foodEvent!.eventDate)!));
                                        //   })));

                                          if (state.foodEvent?.isFavorite ?? false) {
                                            bloc.add(FinishFoodAsFavoriteEventAction(foodFavorite: state.foodEvent!, onFinish: () => _showConfirmationDialog(
                                              message: '${AppLocalizations.of(context)!.food_event_successfully_saved}\n${AppLocalizations.of(context)!.and}\n${AppLocalizations.of(context)!.food_favorite_successfully_saved}',
                                                context: context,
                                                onDismiss: () => Navigator.popAndPushNamed(context, MealTimeDetailScreen.routeName, arguments: FoodArgumentsModel(mealTime: MealTime.getAllMealTimes().firstWhere((element) => element.id == state.foodEvent?.mealTime, orElse: () => Breakfast(),), selectedDateTime: DateTimeHelper.dateTimeFromMilliseconds(state.foodEvent!.eventDate)!)),
                                            ),),);
                                          }
                                          else if (state.foodEvent?.isRoutine == true && state.foodEvent?.daysOfWeek?.isEmpty == true) {
                                            setState(() { _showRoutineValidation = true; });
                                            _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                            return;
                                          }
                                          else if (state.foodEvent?.isRoutine == true && state.foodEvent?.daysOfWeek?.isNotEmpty == true) {
                                            state.foodEvent?.userId = '';
                                            state.foodEvent?.eventDate = state.foodEvent?.eventDate ?? DateTime.now().millisecondsSinceEpoch;
                                            final foodEventRoutine = mapToFoodRoutineEventFromFoodFavorite(state.foodEvent!);
                                            bloc.add(FinishAddFoodRoutineEventAction(foodRoutineEvent: foodEventRoutine, onFinish: () => _showConfirmationDialog(
                                              message: AppLocalizations.of(context)!.food_routine_successfully_saved,
                                                context: context,
                                                onDismiss: () => Navigator.pop(context),
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
                          ],
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
