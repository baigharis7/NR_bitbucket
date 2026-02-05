import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/updatemeal/bloc/update_meal_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_options_widget.dart';

import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/constants.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../foodevent/view/food_event_item.dart';
import '../../widgets/general_button.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/header_add_item_card_section.dart';

class UpdateMealScreen extends StatelessWidget {
  static const routeName = '/update_meal_screen';
  const UpdateMealScreen({super.key});

  // late UpdateMealBloc updateMealBloc;

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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge, horizontal: Dimens.paddingSmall),
                      child: Column(
                        children: [
                          HeaderAddItemCardSection(
                            title: '${AppLocalizations.of(context)!.update} ${MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.foodEvent?.mealTime ?? 0)).name}',
                            image: 'assets/images/meal_time_${state.foodEvent?.mealTime}.png',
                            onBackTap: () => Navigator.pop(context),
                            items: state.foodNames?.foodsAndDrinksNames?.foodNames.orEmpty().map((item) => item.translate(context)).toList(),
                            onItemSelect: (option, focus) {
                              // _focusInputController = focus;
                              final food = eventHelper.findFoodByFoodName(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                              updateMealBloc.add(UpdateIngredientsUpdateMealEvent(ingredient: food!));
                            },
                          ),
                          const SizedBox(height: Dimens.height25,),
                          if (state.foodEvent?.ingredients.isNotEmpty == true) EventOptionsWidget(
                            name: state.foodEvent?.title,
                            onUpdateName: (name) => updateMealBloc.add(UpdateNameUpdateMealEvent(name: name)),
                            mealTime: state.foodEvent?.mealTime,
                            onUpdateMealTime: (mealTime) => updateMealBloc.add(UpdateMealTimeUpdateMealEvent(mealTime: mealTime)),
                            daysOfWeek: state.foodEvent?.isRoutine == true ? state.foodEvent?.daysOfWeek : null,
                            onUpdateDayOfWeek: state.foodEvent?.isRoutine == true ? (dayOfWeek) {} : null,
                          ),
                          if (state.foodEvent?.ingredients.isNotEmpty == true) ListView.builder(
                            shrinkWrap: true,
                              primary: false,
                              itemCount: state.foodEvent?.ingredients.length ?? 0,
                              itemBuilder: (context, index) {
                                final ingredient = state.foodEvent!.ingredients[index];
                                final option = eventHelper.findFoodNameFromId(ingredient.id, context, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                return FoodEventItem(
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
                                );
                              },
                          ),
                          if (state.foodEvent?.ingredients.isNotEmpty == true) Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                            child: GeneralButton(onTap: () {
                              if (state.foodEvent?.title.isNotEmptyOrNull() == true) {
                                updateMealBloc.add(SaveUpdateMealUpdateMealEvent(onFinish: () => Navigator.pop(context)));
                              }
                            },
                            ),
                          ),
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