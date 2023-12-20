import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/add_food_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/create_new_food_favorite_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/add_food_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import 'food_fav_item.dart';

class CreateNewFoodFavoriteScreen extends StatefulWidget {
  static const routeName = '/create_new_food_favorite';

  const CreateNewFoodFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateNewFoodFavoriteScreenState();

}

class _CreateNewFoodFavoriteScreenState extends State<CreateNewFoodFavoriteScreen> {
  TextEditingController _foodInputController = TextEditingController();

  void _showConfirmationDialog(BuildContext context, Function onFinish) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: AppLocalizations.of(context)!.favorite_saved),
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
    final bloc = BlocProvider.of<CreateNewFoodFavoriteBloc>(context);

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

  @override
  void initState() {
    final bloc = BlocProvider.of<CreateNewFoodFavoriteBloc>(context);
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
    final bloc = BlocProvider.of<CreateNewFoodFavoriteBloc>(context);
    String currentLanguage = Localizations.localeOf(context).languageCode;
    final eventHelper = EventsHelper();

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
              onPressed: () => Navigator.pop(context),
            ),
          ),
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
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context)!.add_favorite,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeXXLarge,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingSmall),
                        child: Autocomplete<String>(
                          fieldViewBuilder: (
                              BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted,
                              ) {
                            _foodInputController = textEditingController;
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
                            return state.foodNames!.foodsAndDrinksNames!.foodNames!
                                .map((item) => item.translate(context))
                                .where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (option) {
                            // TODO: manage possible errors
                            final currentLanguage = Localizations.localeOf(context).languageCode;
                            final food = eventHelper.findFoodIdToFavorite(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                            final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                            bloc.add(AddFoodFromFavoriteAction(foodInFavorite: food!));
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
                      ),
                    ),
                    Column(
                      children: [
                        _foodInputController.text == '' && state.foodsInFavorite != null && state.foodsInFavorite!.isEmpty
                        // TODO: aquí saldrían los FAVORITOS.
                            ? Container()
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
                                  onRemove: () => bloc.add(RemoveFoodFromFavoriteAction(foodInFavorite: foodInFavorite)),
                                  onQtyChange: (foodFav) => bloc.add(UpdateQuantityAction(foodInFavorite: foodFav)),
                                  onUnitChange: (foodFav) => bloc.add(UpdateUnitAction(foodInFavorite: foodFav)),
                                  onCookingMethodChange: (foodFav) => bloc.add(UpdateCookingMethodAction(foodInFavorite: foodFav)),
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
                            ).toList()
                          ],
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      child: RoundedCustomButton(
                        buttonText: AppLocalizations.of(context)!.save_favorite,
                        onPressed: () {
                          if (!bloc.isFoodFavValidateList()) {
                            state.foodsInFavorite!.isEmpty
                              ? ToastHelper().showToast(text: AppLocalizations.of(context)!.no_foods_in_event)
                              : showAddFavoriteDialog(
                            context: context,
                            onNameChange: (String foodName) => bloc.add(AddFoodNameAction(name: foodName)),
                            onMealTimeChange: (int mealTime) => bloc.add(AddMealTimeAction(mealTime: mealTime)),
                            onFinish: () => bloc.add(FinishFoodFavoriteAction(onFinish: () => _showConfirmationDialog(context, () => Navigator.pop(context)))),
                          );
                          }
                        },
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