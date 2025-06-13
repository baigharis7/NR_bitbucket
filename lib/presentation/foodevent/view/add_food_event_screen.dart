import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/add_food_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_state.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_event_item.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/add_item_name_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/dash_title_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/food_actions_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/food_event_foods_cluster.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/meal_time_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/meal_type_selection_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/save_button_widget.dart';

import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../infrastructure/helpers/remove_diac.dart';
import '../../widgets/box_type_radio_text_widget.dart';
// import 'package:remove_diacritic/remove_diacritic.dart';

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
  void _showConfirmationDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: AppLocalizations.of(context)!.food_event_successfully_saved),
    ),).then((value) =>
        Navigator.pop(context),
    );
  }

  Future<void> showAddFoodNameDialog({
    required BuildContext context,
    required Function onFinish,
    required Function onNameChange,
    required Function onFavoriteChange,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AddItemNameDialog(
        title: AppLocalizations.of(context)!.food_name,
        onNameChange: (String foodName) => onNameChange.call(foodName),
        onFinish: () => onFinish.call(),
        onCancel: () => Navigator.pop(context),
      ),
    ).then((_) {});
  }

  @override
  void initState() {
    bloc = BlocProvider.of<AddFoodEventBloc>(context);
    bloc.add(InitializeStateAction());

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is FoodEventSimple?) {
            final foodEventSimple = infoReceived as FoodEventSimple?;
            bloc.add(ReceiveFoodsInEventFromNavigationAction(foodEventSimple: foodEventSimple!));
          } else if (infoReceived is DateTime?) {
            final eventDate = infoReceived as DateTime?;
            bloc.add(ReceiveEventDateAction(dateTime: eventDate!));
          }
          else if (infoReceived is FoodEventComplete) {
            bloc.add(AddFoodEventFromDetailNavigation(infoReceived));
          } else if (infoReceived is int) {
            bloc.add(AddFoodMealTypeEventAction(mealType: infoReceived));
          }
        }
      }
    });
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
      child: SafeArea(
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          // extendBody: true,
          // extendBodyBehindAppBar: true,
          // appBar: AppBar(automaticallyImplyLeading: false, backgroundColor: Colors.transparent, elevation: 0),
          body: BlocConsumer<AddFoodEventBloc, AddFoodEventState>(
            listener: (ctx, state) {
              if (state.isLoading) {
                LoadingScreen.instance().show(
                  context: ctx,
                  text: AppLocalizations.of(ctx)!.loading,
                );
              } else {
                LoadingScreen.instance().hide();
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
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLarge),
                    child: (state.mealType ?? -1) <= -1 ? MealTypeSelectionWidget(onSaveMealType: (mealType) => bloc.add(AddFoodMealTypeEventAction(mealType: mealType))) : Column(
                      children: [
                        HeaderAddItemCardSection(
                          title: MealTime.getAllMealTimes().firstWhere((element) => element.id == state.mealType).name,
                          image: 'assets/images/meal_time_${state.mealType}.png',
                          onBackTap: () => Navigator.pop(context),
                          items: state.foodNames?.foodsAndDrinksNames?.foodNames.orEmpty().map((item) => item.translate(context)).toList(),
                          onItemSelect: (option, focus) {
                            _focusInputController = focus;
                            final food = eventHelper.findFoodByFoodName(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                            final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                            bloc.add(AddFoodFromEventAction(foodInEvent: food!));
                          },
                        ),
                        (state.foodsInEvent.orEmpty().isNotEmpty) ?
                          Column(children: [
                          ...state.foodsInEvent.orEmpty().map((foodInEvent) {
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
                          Row(children: [
                            Expanded(child: FoodActionsWidget(
                              title: AppLocalizations.of(context)!.add_more,
                              rightSideWidget: const Icon(Icons.add_circle),
                              onTap: () => _focusInputController.requestFocus(),
                            )),
                            Expanded(child: FoodActionsWidget(
                              title: AppLocalizations.of(context)!.create_dish,
                              rightSideWidget: Container(
                                height: 21,
                                width: 21,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: Dimens.borderSmall,
                                  ),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: state.isCreateDish ?? false ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                              onTap: () => bloc.add(UpdateCreteDishEventAction()),
                              backgroundColor: AppColors.butter,
                            )),
                          ]),
                          SaveButton(onPressed: () {
                            if(state.foodsInEvent!.isEmpty) {
                              if (state.foodsFromFavorite!.isNotEmpty) {
                                bloc.add(FinishFoodFavouriteEventAction(onFinish: () => _showConfirmationDialog(context),),);
                              }
                            }
                            else {
                              if (bloc.validateList() ?? true) return;

                              if (state.isCreateDish ?? false) {
                                showAddFoodNameDialog(
                                  context: context,
                                  onFinish: () {
                                    bloc.add(FinishFoodEventAction(
                                      onFinish: () =>
                                          _showConfirmationDialog(context),
                                    ),);
                                  },
                                  onNameChange: (foodName) {
                                    bloc.add(AddFoodNameEventAction(
                                      foodName: foodName,),);
                                  },
                                  onFavoriteChange: () {},
                                );
                              }
                              else {
                                bloc.add(FinishFoodWithoutCreateDishEventAction(context: context, onFinish: () => _showConfirmationDialog(context)));
                              }
                            }
                          }),
                        ],) :
                        Column(children: [
                          // DashTitleWidget(title: MealTime.getAllMealTimes().firstWhere((element) => element.id == state.mealType).name.orEmpty()+ ' favorites'),
                        ]),
                      ],
                    ),
                  ),
                ],
              );
              },
          ),
        ),
      ),
    );
  }
}
