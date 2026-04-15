import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/updatemeal/bloc/update_meal_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_title_card.dart';

import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/constants.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/confirmation_dialog.dart';
import '../../common/view/loading_screen.dart';
import '../../foodevent/view/food_event_item.dart';
import '../../widgets/general_button.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/screen_top_bar.dart';

class UpdateMealScreen extends StatefulWidget {
  static const routeName = '/update_meal_screen';
  const UpdateMealScreen({super.key});

  @override
  State<UpdateMealScreen> createState() => _UpdateMealScreenState();
}

class _UpdateMealScreenState extends State<UpdateMealScreen> {
  final _scrollController = ScrollController();
  FocusNode _focusInputController = FocusNode();
  bool _showValidation = false;
  final List<GlobalKey> _itemKeys = [];

  String _mealTimeIcon(int? mealTimeId) => 'assets/images/meal_time_${mealTimeId ?? 0}.png';

  String _mealTimeHint(BuildContext context, int? mealTimeId) {
    final l10n = AppLocalizations.of(context)!;
    switch (mealTimeId ?? 0) {
      case 1: return l10n.confirmation_edit_hint_lunch;
      case 2: return l10n.confirmation_edit_hint_dinner;
      case 3: return l10n.confirmation_edit_hint_snack;
      default: return l10n.confirmation_edit_hint_breakfast;
    }
  }

  void _showConfirmationDialog(BuildContext context, {required int? mealTimeId}) {
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));

    showDialog(context: context, builder: (ctx) => ConfirmationDialog(
      title: AppLocalizations.of(context)!.updated_title,
      message: AppLocalizations.of(context)!.food_event_successfully_updated,
      iconAsset: _mealTimeIcon(mealTimeId),
      hint: _mealTimeHint(context, mealTimeId),
    ),).then((value) => Navigator.pop(context));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final eventHelper = EventsHelper();

    final updateMealBloc = BlocProvider.of<UpdateMealBloc>(context);
    updateMealBloc.add(InitializationUpdateMealEvent());

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is FoodFavorite) {
            updateMealBloc.add(MealFromArgumentUpdateMealEvent(foodFavorite: infoReceived));
          }
        }
      }
    });

    return BlocProvider.value(
      value: updateMealBloc,
      child: BlocConsumer<UpdateMealBloc, UpdateMealState>(
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
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
                  body: SafeArea(
                    child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge, horizontal: Dimens.paddingSmall),
                      child: Column(
                        children: [
                          ScreenTopBar(
                            selectedDate: null,
                            onBack: () => Navigator.pop(context),
                          ),
                          const SizedBox(height: Dimens.height12),
                          HeaderAddItemCardSection(
                            title: '${AppLocalizations.of(context)!.update} ${MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.foodEvent?.mealTime ?? 0)).name}',
                            image: 'assets/images/meal_time_${state.foodEvent?.mealTime}.png',
                            searchHintText: AppLocalizations.of(context)!.search_food_hint,
                            onFocusNodeCreated: (node) => _focusInputController = node,
                            items: state.foodNames?.foodsAndDrinksNames?.foodNames.orEmpty().map((item) => item.translate(context)).toList(),
                            onItemSelect: (option, focus) {
                              _focusInputController = focus;
                              final food = eventHelper.findFoodByFoodName(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                              updateMealBloc.add(UpdateIngredientsUpdateMealEvent(ingredient: food!));
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              });
                            },
                          ),
                          if (state.foodEvent?.ingredients.isNotEmpty == true) ...[
                            const SizedBox(height: Dimens.height12),
                            // Title card with favorite/routine toggles
                            ItemTitleCard(
                              name: state.foodEvent?.title,
                              onUpdateName: (name) => updateMealBloc.add(UpdateNameUpdateMealEvent(name: name)),
                              isFavorite: state.foodEvent?.isFavorite ?? false,
                              onToggleFavorite: () {
                                if (state.foodEvent?.isFavorite != true) {
                                  if (state.foodEvent?.isRoutine == true) updateMealBloc.add(UpdateIsRoutineUpdateMealEvent(isRoutine: false));
                                  updateMealBloc.add(UpdateIsFavoriteUpdateMealEvent(isFavorite: true));
                                } else {
                                  updateMealBloc.add(UpdateIsFavoriteUpdateMealEvent(isFavorite: false));
                                }
                              },
                              isRoutine: state.foodEvent?.isRoutine ?? false,
                              onToggleRoutine: () {
                                if (state.foodEvent?.isRoutine != true) {
                                  if (state.foodEvent?.isFavorite == true) updateMealBloc.add(UpdateIsFavoriteUpdateMealEvent(isFavorite: false));
                                  updateMealBloc.add(UpdateIsRoutineUpdateMealEvent(isRoutine: true));
                                } else {
                                  updateMealBloc.add(UpdateIsRoutineUpdateMealEvent(isRoutine: false));
                                }
                              },
                              itemCount: state.foodEvent?.ingredients.length ?? 0,
                              mealTime: state.foodEvent?.mealTime,
                              onUpdateMealTime: state.foodEvent?.mealTime == 3 ? null : (mealTime) => updateMealBloc.add(UpdateMealTimeUpdateMealEvent(mealTime: mealTime)),
                              scheduleTime: DateTimeHelper.timeOfDayFrom24HrString(state.foodEvent?.time),
                              onUpdateTime: (scheduleTime) => updateMealBloc.add(UpdateScheduleTimeUpdateMealEvent(scheduleTime: DateTimeHelper.timeOfDayTo24HrString(scheduleTime))),
                              daysOfWeek: state.foodEvent?.daysOfWeek,
                              onUpdateDayOfWeek: (dayOfWeek) {},
                              showTimePicker: state.foodEvent?.mealTime == 3,
                              isEdit: true,
                            ),
                            ...state.foodEvent!.ingredients.asMap().entries.map((entry) {
                              final index = entry.key;
                              final ingredient = entry.value;
                              while (_itemKeys.length <= index) { _itemKeys.add(GlobalKey()); }
                              final option = eventHelper.resolveIngredientName(ingredient, context, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                              final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                              return FoodEventItem(
                                    key: _itemKeys[index],
                                    options: option,
                                    unitsFoodsMaster: state.unitsFoodsMaster ?? UnitsFoodsMaster(unitsFoodsMaster: []),
                                    unitsInfoMaster: state.unitsInfoMaster ?? UnitsInfoMaster(unitsInfoMaster: []),
                                    oilTypes: state.oilTypes,
                                    conversionFactors: state.conversionFactors,
                                    foodInEvent: ingredient,
                                    foodGroup: foodGroup.orEmpty(),
                                    cookingMethodsInfoMaster: state.cookingMethodsInfoMaster ?? CookingMethodsInfoMaster(cookingMethodsInfo: []),
                                    cookingMethodsMaster: state.cookingMethodsMaster ?? CookingMethodsMaster(cookingMethods: []),
                                    onRemove: () => updateMealBloc.add(RemoveIngredientUpdateMealEvent(ingredient: ingredient, isGoBack: () => Navigator.pop(context))),
                                    onQtyChange: (ingredient) => updateMealBloc.add(UpdateIngredientAmountUpdateMealEvent(ingredient: ingredient)),
                                    onUnitChange: (ingredient) => updateMealBloc.add(UpdateIngredientUnitUpdateMealEvent(ingredient: ingredient)),
                                    onCookingMethodChange: (ingredient) => updateMealBloc.add(UpdateIngredientCookingMethodUpdateMealEvent(ingredient: ingredient)),
                                    onConversionFactorChange: (ingredient) => updateMealBloc.add(UpdateIngredientPreparationUpdateMealEvent(ingredient: ingredient)),
                                    onOilUsedChange: (ingredient) => updateMealBloc.add(UpdateIngredientOilUpdateMealEvent(ingredient: ingredient)),
                                    showValidation: _showValidation,
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
                                    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                    _focusInputController.requestFocus();
                                  },
                                  title: Text(AppLocalizations.of(context)!.add_more),
                                  trailing: Stack(alignment: Alignment.center, children: [Container(width: 26 * 0.85, height: 26 * 0.85, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)), const Icon(Icons.add_circle, color: AppColors.yellowishGreen)]),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.foodEvent?.ingredients.isNotEmpty == true) Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall, vertical: Dimens.marginSmall),
                    child: GeneralButton(onTap: () {
                      final hasErrors = state.foodEvent?.ingredients.any((food) => food.qty <= 0 || food.unit == -1) ?? false;
                      if (hasErrors) {
                        setState(() { _showValidation = true; });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final items = state.foodEvent?.ingredients ?? [];
                          for (int i = 0; i < items.length; i++) {
                            if (items[i].qty <= 0 || items[i].unit == -1) {
                              if (i < _itemKeys.length && _itemKeys[i].currentContext != null) {
                                Scrollable.ensureVisible(_itemKeys[i].currentContext!, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                              }
                              break;
                            }
                          }
                        });
                        return;
                      }
                      setState(() { _showValidation = false; });
                      if (state.foodEvent?.title.isNotEmptyOrNull() == true) {
                        updateMealBloc.add(SaveUpdateMealUpdateMealEvent(onFinish: () => _showConfirmationDialog(context, mealTimeId: state.foodEvent?.mealTime)));
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