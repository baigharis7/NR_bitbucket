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
import 'package:nutrenaissance_flutter/presentation/widgets/food_event_foods_cluster.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/meal_type_selection_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

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

  Future<void> showAddFoodEventDialog(
      Widget widget,
      String foodName,
  ) async {
    final bloc = BlocProvider.of<AddFoodEventBloc>(context);

    await showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AddFoodDialog(
          widget: widget,
          foodName: foodName,
        );
      },
    ).then((foodInEvent) {
      if (foodInEvent != null) {
        bloc.add(AddFoodFromEventAction(foodInEvent: foodInEvent));
      }
      setState(() => _foodInputController.text = '');
    });
  }

  Future<void> showAddFoodNameDialog({
    required BuildContext context,
    required Function onFinish,
    required Function onNameChange,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddItemNameDialog(
        title: '${AppLocalizations.of(context)!.food_name}:',
        onNameChange: (String foodName) => onNameChange.call(foodName),
        onFinish: () => onFinish.call(),
        onCancel: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            leading: IconButton(
              onPressed: () {
                bloc.add(ResetFoodEventInfoAction());
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios, size: 24),
            ),
            title: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.journal,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimens.fontSizeXXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal), child: Image.asset('assets/icon/journal_icon.png', height: 28)),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(Dimens.heightSmall),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge,),
                child: Text(
                  AppLocalizations.of(context)!.add_food,
                  style: const TextStyle(fontSize: Dimens.fontSizeXXLarge,),
                ),
              ),
            ),
          ),
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
              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXXLarge),
                  padding: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge),
                  child: (state.mealType ?? -1) <= -1 ? MealTypeSelectionWidget(onSaveMealType: (mealType) => bloc.add(AddFoodMealTypeEventAction(mealType: mealType))) : Column(
                    children: [
                      // if (state.mealType.isNull()) MealTypeSelectionWidget(onSaveMealType: (mealType) => bloc.add(AddFoodMealTypeEventAction(mealType: mealType))) else
                        Column(
                        children: [
                          Autocomplete<String>(
                            fieldViewBuilder: (
                                BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted,
                                ) {
                              _foodInputController = textEditingController;
                              _focusInputController = focusNode;
                              return TextField(
                                decoration: InputDecoration(
                                  fillColor: Colors.black,
                                  labelText: AppLocalizations.of(context)!.write_here_hint,
                                    suffixIcon: IconButton(
                                    icon: textEditingController.text != ''
                                        ? const Icon(
                                          Icons.highlight_remove,
                                          color: Colors.black,
                                        )
                                        : Container(),
                                    onPressed: () => setState(() => textEditingController.text = ''),
                                  ),
                                ),
                                controller: textEditingController,
                                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => _foodInputController.text.isNotEmptyOrNull() && _foodInputController.text.length > 2 ? Container(margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal), child: Text('$filteredListLength: ' '${filteredListLength > 1 ? AppLocalizations.of(context)!.items_found : AppLocalizations.of(context)!.item_found}',)) : Container(),
                                focusNode: focusNode,
                                onChanged: (value) => setState(() {
                                  textEditingController;
                                }),
                              );
                            },
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '' || textEditingValue.text.length < 3) return const Iterable<String>.empty();
                              final filteredList =  state.foodNames!.foodsAndDrinksNames!.foodNames!
                                  .map((item) => item.translate(context))
                                  // .where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                              // remove spanish accent to simple english
                                  .where((String option) => removeDiacritics(option).toLowerCase().contains(removeDiacritics(textEditingValue.text.toLowerCase())));
                              filteredListLength = filteredList.length;
                              return filteredList;
                            },
                            onSelected: (option) {
                              // TODO: manage possible errors
                              final food = eventHelper.findFoodByFoodName(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                              final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                              bloc.add(AddFoodFromEventAction(foodInEvent: food!));
                              _foodInputController.text = '';
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              final screenSpace = MediaQuery.of(context).size.height/3.1;
                              final screenSpaceRequired = filteredListLength * Dimens.height60;
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 30.0,
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - Dimens.margin_60, maxHeight: screenSpace < screenSpaceRequired ? screenSpace : screenSpaceRequired), // Adjust the width as needed
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView(
                                        padding: EdgeInsets.zero,
                                        children: ListTile.divideTiles(
                                          context: context,
                                          tiles: options.map((String option) {
                                            return ListTile(
                                              title: Text(option),
                                              onTap: () {
                                                onSelected(option);
                                              },
                                            );
                                          }),
                                        ).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Column(
                            children: [
                              _foodInputController.text == '' && state.foodsInEvent != null && state.foodsInEvent!.isEmpty
                              // TODO: aquí saldrían los FAVORITOS.
                                  ? Container(child: state.foodFavorites!.isEmpty ? Container()
                                  : Column(
                                  children: [
                                    if (bloc.getFoodListByType(MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.mealType ?? -1))).isNotEmpty) FoodEventFoodsCluster(
                                      clusterName: '${MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.mealType ?? -1)).name}s :',
                                      selectedFoodName: state.foodName,
                                      onSelect: (food) => bloc.add(AddFoodFromFavouriteEventAction(foodFavorite: food)),
                                      foodList: bloc.getFoodListByType(MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.mealType ?? -1))),
                                    ),
                                    // if (bloc.getFoodListByType(Lunch()).isNotEmpty) FoodEventFoodsCluster(
                                    //   clusterName: '${AppLocalizationsHelper.instance.translate('lunch')}s :',
                                    //   selectedFoodName: state.foodName,
                                    //   onSelect: (food) => bloc.add(AddFoodFromFavouriteEventAction(foodFavorite: food)),
                                    //   foodList: bloc.getFoodListByType(Lunch()),
                                    // ),
                                  ],
                              ),
                              )
                                  : Column(
                                children: [
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
                                  }
                                  ).toList(),
                                  IconButton(
                                    onPressed: () { _focusInputController.requestFocus(); },
                                    icon: const Icon(Icons.add_circle, color: Colors.teal, size: 28),
                                  ),
                                  BoxTypeRadioTextWidget(onPressed: () => bloc.add(UpdateCreteDishEventAction()), isSelected: state.isCreateDish ?? false, title: AppLocalizations.of(context)!.create_dish),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    RoundedCustomButton(onPressed: () {
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
                            );
                        }
                        else {
                          bloc.add(FinishFoodWithoutCreateDishEventAction(context: context, onFinish: () => _showConfirmationDialog(context)));
                        }
                      }
                      },
                    ),
                    ],
                  ),
                ),
              );
              },
          ),
        ),
      ),
    );
  }
}
