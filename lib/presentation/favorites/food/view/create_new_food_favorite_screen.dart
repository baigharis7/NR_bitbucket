import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/add_food_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../../domain/models/favorites/food/food_favorite.dart';
import '../../../../domain/models/favorites/food/meal_time.dart';
import '../../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../../infrastructure/helpers/remove_diac.dart';
import '../../../widgets/add_item_name_dialog.dart';
import '../../../widgets/box_type_radio_text_widget.dart';
import '../../../widgets/food_event_foods_cluster.dart';
import '../../../widgets/meal_type_selection_widget.dart';
import '../../../widgets/custom_bottom_navi_bar_widget.dart';
import 'food_fav_item.dart';

class CreateNewFoodFavoriteScreen extends StatefulWidget {
  static const routeName = '/create_new_food_favorite';

  const CreateNewFoodFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateNewFoodFavoriteScreenState();

}

class _CreateNewFoodFavoriteScreenState extends State<CreateNewFoodFavoriteScreen> {
  TextEditingController _foodInputController = TextEditingController();
  late CreateNewFoodFavoriteBloc bloc;
  late Object? arguments;
  late FocusNode _focusInputController;
  int filteredListLength = 0;

  void _showConfirmationDialog(BuildContext context, Function onFinish) {
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));

    showDialog(context: context, builder: (ctx) => ConfirmationDialog(
      message: AppLocalizations.of(context)!.favorite_saved,
      iconData: Icons.star_rounded,
      hint: AppLocalizations.of(context)!.confirmation_edit_hint_favorites,
    ),).then((value) {
      Navigator.pop(context);
      onFinish.call();
    }
    );
  }

  Future<void> showAddFoodFavoriteDialog(
      Widget widget,
      String foodName,
      ) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AddFoodDialog(widget: widget, foodName: foodName);
      },
    ).then((foodInFavorite) {
      if (foodInFavorite != null) {
        bloc.add(AddFoodFromFavoriteAction(foodInFavorite: foodInFavorite));
      }
      setState(() => _foodInputController.text = '');
    });
  }

  Future<void> showAddFavoriteDialog({
    required BuildContext context,
    required Function onFinish,
    required Function onNameChange,
    required Function onMealTimeChange,
  }) async {
    await showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (ctx) => AddFavoriteDialog(
        onNameChange: (String foodName) => onNameChange.call(foodName),
        onMealTimeChange: (int mealTime) => onMealTimeChange.call(mealTime),
        onFinish: () => onFinish.call(),
        onPop: () => Navigator.pop(context),
      ),
    );
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
        onSave: () => onFinish.call(),
        onCancel: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
  }

  @override
  void initState() {
    bloc = BlocProvider.of<CreateNewFoodFavoriteBloc>(context);
    bloc.add(InitializeStateAction());

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is FoodFavorite?) {
            bloc.add(SetFavFoodFromFavoriteDetailNavigation(foodFavorite: infoReceived as FoodFavorite));
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
    String currentLanguage = Localizations.localeOf(context).languageCode;
    final eventHelper = EventsHelper();

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
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
                  AppLocalizations.of(context)!.add_favorite,
                  style: const TextStyle(fontSize: Dimens.fontSizeXXLarge,),
                ),
              ),
            ),
          ),
          // AppBar(
          //   backgroundColor: Colors.transparent,
          //   elevation: 0,
          //   leading: IconButton(
          //     icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
          //     onPressed: () => Navigator.pop(context),
          //   ),
          // ),
          body: BlocConsumer<CreateNewFoodFavoriteBloc, CreateNewFoodFavoriteState>(
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
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXXLarge, vertical: Dimens.marginLarge),
                child: (state.mealTime ?? -1) <= -1 ? MealTypeSelectionWidget(onSaveMealType: (mealType) => bloc.add(AddMealTimeAction(mealTime: mealType))) : Column(
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
                              onPressed: () => setState(() {
                                textEditingController.text = '';
                              }),
                            ),
                          ),
                          controller: textEditingController,
                          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => _foodInputController.text.isNotEmptyOrNull() && _foodInputController.text.length > 2 ? Container(margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal), child: Text('$filteredListLength: ' '${filteredListLength > 1 ? AppLocalizations.of(context)!.items_found : AppLocalizations.of(context)!.item_found}',)) : Container(),
                          focusNode: focusNode,
                          onChanged: (value) {
                            setState(() {
                              textEditingController;
                            });
                          },
                        );
                      },
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '' || textEditingValue.text.length < 3) return const Iterable<String>.empty();
                        final filteredList =  state.foodNames!.foodsAndDrinksNames!.foodNames!
                            .map((item) => item.translate(context))
                            .where((String option) => removeDiacritics(option).toLowerCase().contains(removeDiacritics(textEditingValue.text.toLowerCase())));
                        filteredListLength = filteredList.length;
                        return filteredList;
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - Dimens.margin_60, maxHeight: Dimens.heightXXLarge), // Adjust the width as needed
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: ListView(
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
                      onSelected: (option) {
                        final currentLanguage = Localizations.localeOf(context).languageCode;
                        final food = eventHelper.findFoodIdToFavorite(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                        if (food == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.food_not_found_in_catalog)),
                          );
                          return;
                        }
                        bloc.add(AddFoodFromFavoriteAction(foodInFavorite: food));
                        _foodInputController.text = '';
                        // showAddFoodFavoriteDialog(
                        //   AddFoodFavoriteDialog(
                        //       foodInFavorite: food!,
                        //       foodGroup: foodGroup.orEmpty(),
                        //       cookingMethodsMaster: state.cookingMethodsMaster!,
                        //       cookingMethodsInfoMaster: state.cookingMethodsInfoMaster!,
                        //       unitsInfoMaster: state.unitsInfoMaster!,
                        //       unitsFoodsMaster: state.unitsFoodsMaster!,
                        //   ),
                        //   option,
                        // );
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge),
                        child: Column(
                          children: [
                            _foodInputController.text == '' && state.foodsInFavorite != null && state.foodsInFavorite!.isEmpty
                            // TODO: aquí saldrían los FAVORITOS.
                                ? Container(child: state.foodsInFavorite.orEmpty().isNotEmpty ? Container()
                                : Column(
                              children: [
                                if (bloc.getFoodListByType(MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.mealTime ?? -1))).isNotEmpty) FoodEventFoodsCluster(
                                  clusterName: '${MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.mealTime ?? -1)).name}s :',
                                  selectedFoodName: state.favoriteName,
                                  onSelect: (food) => bloc.add(AddFavFoodFromFrequent(frequentFood: food)),
                                  foodList: bloc.getFoodListByType(MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.mealTime ?? -1))),
                                ),
                              ],
                            ),
                            )
                                : Column(
                              children: [
                                ...state.foodsInFavorite.orEmpty().map((foodInFavorite) {
                                  final option = eventHelper.findFoodNameFromId(foodInFavorite.id, context, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                  final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                  return FoodFavItem(
                                      foodInFavorite: foodInFavorite,
                                      foodGroup: foodGroup,
                                      cookingMethodsMaster: state.cookingMethodsMaster!,
                                      cookingMethodsInfoMaster: state.cookingMethodsInfoMaster!,
                                      unitsInfoMaster: state.unitsInfoMaster!,
                                      unitsFoodsMaster: state.unitsFoodsMaster!,
                                      options: option,
                                      conversionFactors: state.conversionFactors,
                                      oilTypes: state.oilTypes,
                                      onRemove: () => bloc.add(RemoveFoodFromFavoriteAction(foodInFavorite: foodInFavorite)),
                                      onQtyChange: (foodFav) => bloc.add(UpdateQuantityAction(foodInFavorite: foodFav)),
                                      onUnitChange: (foodFav) => bloc.add(UpdateUnitAction(foodInFavorite: foodFav)),
                                      onCookingMethodChange: (foodFav) => bloc.add(UpdateCookingMethodAction(foodInFavorite: foodFav)),
                                    onConversionFactorChange: (foodFav) => bloc.add(UpdateConversionFactorEventAction(foodInFavorite: foodFav)),
                                    onOilUsedChange: (foodFav) => bloc.add(UpdateUsedOilEventAction(foodInFavorite: foodFav)),
                                  );
                                }
                                    // FoodCard(
                                    //   foodName: state.foodNames!.foodsAndDrinksNames!.foodNames!
                                    //       .firstWhere((foodItemMaster) => foodItemMaster.id == foodInFavorite.id)
                                    //       .translate(context),
                                    //   cookingMethod: eventHelper.findCookingMethodName(context, foodInFavorite.cookingMethod, state.cookingMethodsInfoMaster!.cookingMethodsInfo!),
                                    //   quantity: foodInFavorite.qty.toString(),
                                    //   unit: eventHelper.findUnitName(foodInFavorite.unit, state.unitsInfoMaster!.unitsInfoMaster).translate(context),
                                    //   removeFood: () => context.read<CreateNewFoodFavoriteBloc>().add(RemoveFoodFromFavoriteAction(foodInFavorite: foodInFavorite)),
                                    //   editFood: () {
                                    //     final option = eventHelper.findFoodNameFromId(foodInFavorite.id, context, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                    //     final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                    //     showAddFoodFavoriteDialog(
                                    //       AddFoodFavoriteDialog(
                                    //         foodInFavorite: foodInFavorite,
                                    //         foodGroup: foodGroup.orEmpty(),
                                    //         cookingMethodsMaster: state.cookingMethodsMaster!,
                                    //         cookingMethodsInfoMaster: state.cookingMethodsInfoMaster!,
                                    //         unitsInfoMaster: state.unitsInfoMaster!,
                                    //         unitsFoodsMaster: state.unitsFoodsMaster!,
                                    //       ),
                                    //       option,
                                    //     );
                                    //   },
                                    // ),
                                ).toList(),
                                if (state.foodsInFavorite.orEmpty().isNotEmpty) IconButton(
                                  onPressed: () => _focusInputController.requestFocus(),
                                  icon: const Icon(Icons.add_circle, color: Colors.teal, size: 28),
                                ),
                                if (state.foodsInFavorite.orEmpty().isNotEmpty) BoxTypeRadioTextWidget(onPressed: () => bloc.add(UpdateCreateDishAction()), isSelected: state.isCreateDish ?? false, title: AppLocalizations.of(context)!.create_dish),
                              ],
                            ),
                            RoundedCustomButton(
                              onPressed: () {
                                if(state.foodsInFavorite.orEmpty().isEmpty) {
                                  if (state.foodsFromFrequent.orEmpty().isNotEmpty) {
                                    bloc.add(FinishFrequentFoodToAddFavorite(onFinish: () => _showConfirmationDialog(context, (){}),),);
                                  }
                                }
                                else {
                                if (bloc.isFoodFavValidateList()) return;

                                if (state.isCreateDish ?? false) {
                                  showAddFoodNameDialog(
                                    context: context,
                                    onFinish: () {
                                      bloc.add(FinishFoodFavoriteAction(
                                        onFinish: () =>
                                            _showConfirmationDialog(context, () {}),
                                      ),);
                                    },
                                    onNameChange: (foodName) {
                                      bloc.add(AddFoodNameAction(
                                        name: foodName,),);
                                    },
                                  );
                                }
                                else {
                                  // state.favoriteName = state.foodsInFavorite!.map((e) => eventHelper.findFoodNameFromId(e.id, context, state.foodNames!.foodsAndDrinksNames!.foodNames!)).toString();
                                  // bloc.add(FinishFoodFavoriteAction(onFinish: () => _showConfirmationDialog(context, () {})));
                                  bloc.add(FinishFavoriteFoodWithoutCreateDishAction(onFinish: () => _showConfirmationDialog(context, () {}), context: context));
                                }
                                }

                                // if (!bloc.isFoodFavValidateList()) {
                                //   state.foodsInFavorite!.isEmpty
                                //     ? ToastHelper().showToast(text: AppLocalizations.of(context)!.no_foods_in_event)
                                //     : showAddFavoriteDialog(
                                //   context: context,
                                //   onNameChange: (String foodName) => bloc.add(AddFoodNameAction(name: foodName)),
                                //   onMealTimeChange: (int mealTime) => bloc.add(AddMealTimeAction(mealTime: mealTime)),
                                //   onFinish: () => bloc.add(FinishFoodFavoriteAction(onFinish: () => _showConfirmationDialog(context, () => Navigator.pop(context)))),
                                // );
                                // }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

}