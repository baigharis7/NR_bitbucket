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
import 'package:nutrenaissance_flutter/presentation/common/view/generic_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/add_food_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/create_new_liquid_favorite_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/create_new_liquid_favorite_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/create_new_liquid_favorite_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/view/add_liquid_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

class CreateNewLiquidFavoriteScreen extends StatefulWidget {
  static const routeName = '/create_new_liquid_favorite';

  const CreateNewLiquidFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateNewLiquidFavoriteScreenState();

}

class _CreateNewLiquidFavoriteScreenState extends State<CreateNewLiquidFavoriteScreen> {
  TextEditingController _liquidInputController = TextEditingController();

  void _showConfirmationDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: AppLocalizations.of(context)!.liquid_event_successfully_saved),
    ),).then((value) =>
        Navigator.pop(context),
    );
  }

  Future<void> showAddLiquidFavoriteDialog(
      Widget widget,
      String liquidName,
      ) async {
    final bloc = BlocProvider.of<CreateNewLiquidFavoriteBloc>(context);

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AddFoodDialog(widget: widget, foodName: liquidName);
      },
    ).then((liquidInFavorite) {
      if (liquidInFavorite != null) {
        bloc.add(AddLiquidFromFavoriteAction(liquidInFavorite: liquidInFavorite));
      }
      setState(() => _liquidInputController.text = '');
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
        onNameChange: (String liquidName) => onNameChange.call(liquidName),
        onMealTimeChange: (int mealTime) => onMealTimeChange.call(mealTime),
        onFinish: () => onFinish.call(),
        onPop: () => Navigator.pop(context),
      ),
    );
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<CreateNewLiquidFavoriteBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  void dispose() {
    _liquidInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CreateNewLiquidFavoriteBloc>(context);
    String currentLanguage = Localizations.localeOf(context).languageCode;
    final eventHelper = EventsHelper();

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            titleSpacing: Dimens.marginNormal,
            title: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                  child: Text(
                    AppLocalizations.of(context)!.add_favorite,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  height: 28,
                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                  child: Image.asset('assets/icon/journal_icon.png'),)
              ],
            ),
          ),
          body: BlocConsumer<CreateNewLiquidFavoriteBloc, CreateNewLiquidFavoriteState>(
            listener: (ctx, state) {
              if (state.isLoading) {
                LoadingScreen.instance().show(
                  context: ctx,
                  text: AppLocalizations.of(ctx)!.loading,
                );
              } else {
                LoadingScreen.instance().hide();
              }
              // display possible errors
              final loginError = state.onError;
              if (loginError != null) {
                showGenericDialog<bool>(
                  context: ctx,
                  title: AppLocalizations.of(ctx)!.errorTitle,
                  content: AppLocalizations.of(ctx)!.errorContent,
                  optionsBuilder: () => {'ok': true},
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal, vertical: Dimens.paddingSmall),
                        child: Autocomplete<String>(
                          fieldViewBuilder: (
                              BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted,
                              ) {
                            _liquidInputController = textEditingController;
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
                                  onPressed: () => textEditingController.text = '',
                                ),
                              ),
                              controller: textEditingController,
                              focusNode: focusNode,
                            );
                          },
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '' || textEditingValue.text.length < 3) return const Iterable<String>.empty();
                            return state.liquidNames!.foodsAndDrinksNames!.drinkNames!
                                .map((item) => item.translate(context))
                                .where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (option) {
                            // TODO: manage possible errors
                            final currentLanguage = Localizations.localeOf(context).languageCode;
                            final food = eventHelper.findFoodIdToFavorite(option, currentLanguage, state.liquidNames!.foodsAndDrinksNames!.drinkNames!);
                            final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.liquidNames!.foodsAndDrinksNames!.drinkNames!);
                            showAddLiquidFavoriteDialog(
                              AddFoodFavoriteDialog(
                                  foodInFavorite: food!,
                                  foodGroup: foodGroup.orEmpty(),
                                  cookingMethodsMaster: state.cookingMethodsMaster!,
                                  cookingMethodsInfoMaster: state.cookingMethodsInfoMaster!,
                                  unitsInfoMaster: state.unitsInfoMaster!,
                                  unitsFoodsMaster: state.unitsLiquidsMaster!,
                              ),
                              option,
                            );
                          },
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        _liquidInputController.text == '' && state.liquidsInFavorite != null && state.liquidsInFavorite!.isEmpty
                        // TODO: aquí saldrían los FAVORITOS.
                            ? Container()
                            : Column(
                          children: [
                            ...state.liquidsInFavorite.orEmpty().map((liquidInFavorite) =>
                                FoodCard(
                                  foodName: state.liquidNames!.foodsAndDrinksNames!.drinkNames!
                                      .firstWhere((liquidItemMaster) => liquidItemMaster.id == liquidInFavorite.id)
                                      .translate(context),
                                  cookingMethod: eventHelper.findCookingMethodName(context, liquidInFavorite.cookingMethod, state.cookingMethodsInfoMaster!.cookingMethodsInfo!),
                                  quantity: liquidInFavorite.qty.toString(),
                                  unit: eventHelper.findUnitName(liquidInFavorite.unit, state.unitsInfoMaster!.unitsInfoMaster).translate(context),
                                  removeFood: () => context.read<CreateNewLiquidFavoriteBloc>().add(RemoveLiquidFromFavoriteAction(liquidInFavorite: liquidInFavorite)),
                                  editFood: () {
                                    final option = eventHelper.findFoodNameFromId(liquidInFavorite.id, context, state.liquidNames!.foodsAndDrinksNames!.drinkNames!);
                                    final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.liquidNames!.foodsAndDrinksNames!.drinkNames!);
                                    showAddLiquidFavoriteDialog(
                                      AddLiquidFavoriteDialog(
                                        foodInFavorite: liquidInFavorite,
                                        foodGroup: foodGroup.orEmpty(),
                                        cookingMethodsMaster: state.cookingMethodsMaster!,
                                        cookingMethodsInfoMaster: state.cookingMethodsInfoMaster!,
                                        unitsInfoMaster: state.unitsInfoMaster!,
                                        unitsLiquidsMaster: state.unitsLiquidsMaster!,
                                      ),
                                      option,
                                    );
                                  },
                                ),
                            ).toList()
                          ],
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge),
                      child: ElevatedButton(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                        onPressed: () {
                          state.liquidsInFavorite!.isEmpty
                              ? ToastHelper().showToast(text: AppLocalizations.of(context)!.no_foods_in_event)
                              : showAddFavoriteDialog(
                                  context: context,
                                  onNameChange: (String liquidName) => bloc.add(AddLiquidNameAction(name: liquidName)),
                                  onMealTimeChange: (int mealTime) => bloc.add(AddMealTimeAction(mealTime: mealTime)),
                                  onFinish: () => bloc.add(FinishLiquidFavoriteAction(onFinish: () => _showConfirmationDialog(context))),
                                );
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