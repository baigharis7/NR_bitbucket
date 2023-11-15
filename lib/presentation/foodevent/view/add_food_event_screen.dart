import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/add_food_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_state.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../../../domain/models/masterfiles/food_names_master.dart';
import '../common/add_food_name_dialog.dart';

// TODO: tengo que poner lo de las bebidas en algún sitio.
class AddFoodEventScreen extends StatefulWidget {
  static const routeName = '/add_food_event';

  const AddFoodEventScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFoodEventState();
}

class _AddFoodEventState extends State<AddFoodEventScreen> {
  TextEditingController _foodInputController = TextEditingController();

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
      builder: (ctx) => AddFoodNameDialog(
        title: AppLocalizations.of(context)!.food_name,
        onNameChange: (String foodName) => onNameChange.call(foodName),
        onFinish: () => onFinish.call(),
        onPop: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<AddFoodEventBloc>(context);
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
    final bloc = BlocProvider.of<AddFoodEventBloc>(context);
    final currentLanguage = Localizations.localeOf(context).languageCode;
    final eventHelper = EventsHelper();
    final infoReceived = ModalRoute.of(context)!.settings.arguments;
    if (infoReceived != null) {
      if (infoReceived is FoodEventSimple?) {
        final foodEventSimple = infoReceived as FoodEventSimple?;
        bloc.add(ReceiveFoodsInEventFromNavigationAction(foodEventSimple: foodEventSimple!));
      } else if (infoReceived is DateTime?) {
        final eventDate = infoReceived as DateTime?;
        bloc.add(ReceiveEventDateAction(dateTime: eventDate!));
      }
      else if (infoReceived is FoodItemMaster) {
        print(infoReceived.en.toString());
      }
    }

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: Scaffold(
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
              return WillPopScope(
                onWillPop: () async {
                  bloc.add(ResetFoodEventInfoAction());
                  return true;
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: Dimens.marginNormal),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                bloc.add(ResetFoodEventInfoAction());
                                Navigator.pop(context);
                                },
                              icon: const Icon(Icons.arrow_back_ios, size: 24),
                            ),
                            Text(
                              AppLocalizations.of(context)!.journal,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: Dimens.fontSizeXXLarge,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              height: 28,
                              margin: const EdgeInsets.only(left: Dimens.marginNormal),
                              child: Image.asset('assets/icon/journal_icon.png'),)
                          ],
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge,),
                          child: Text(
                            AppLocalizations.of(context)!.add_food,
                            style: const TextStyle(fontSize: Dimens.fontSizeXXLarge,),
                          ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: Dimens.marginNormal),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal, vertical: Dimens.paddingSmall),
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
                                    onPressed: () => setState(() => textEditingController.text = ''),
                                  ),
                                ),
                                controller: textEditingController,
                                focusNode: focusNode,
                                onChanged: (value) => setState(() {
                                  textEditingController;
                                }),
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
                              final food = eventHelper.findFoodByFoodName(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                              final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                              showAddFoodEventDialog(
                                AddFoodEventDialog(
                                  unitsFoodsMaster: state.unitsFoodsMaster!,
                                  unitsInfoMaster: state.unitsInfoMaster!,
                                  foodInEvent: food!,
                                  currentLanguage: Localizations.localeOf(context).languageCode,
                                  foodGroup: foodGroup.orEmpty(),
                                  cookingMethodsInfoMaster: state.cookingMethodsInfoMaster!,
                                  cookingMethodsMaster: state.cookingMethodsMaster!,
                                ),
                                option,
                              );
                            },
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          _foodInputController.text == '' && state.foodsInEvent != null && state.foodsInEvent!.isEmpty
                          // TODO: aquí saldrían los FAVORITOS.
                              ? Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal), child: state.foodFavorites!.isEmpty ? Container() : GridView(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: Dimens.marginNormal,
                              mainAxisExtent: 55.0,
                              childAspectRatio: 3/1,
                            ),
                            shrinkWrap: true,
                            children: [
                              ...state.foodFavorites!.map((food) => Card(
                                elevation: 3.00,
                                shadowColor: Colors.black,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: state.foodName == food.title ? Colors.amber : Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                    onTap: () => bloc.add(AddFoodFromFavouriteEventAction(foodFavorite: food)),
                                    child: Center(
                                      child: Text(
                                        food.title.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: Dimens.fontSizeSmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ),
                            ],
                          ),)
                              : Column(
                                  children: [
                                    ...state.foodsInEvent.orEmpty().map((foodInEvent) =>
                                        FoodCard(
                                          foodName: eventHelper.findFoodNameFromId(foodInEvent.id, context, state.foodNames!.foodsAndDrinksNames!.foodNames!),
                                          cookingMethod: eventHelper.findCookingMethodName(context, foodInEvent.cookingMethod, state.cookingMethodsInfoMaster!.cookingMethodsInfo!),
                                          quantity: foodInEvent.qty.toString(),
                                          unit: eventHelper.findUnitName(foodInEvent.unit, state.unitsInfoMaster!.unitsInfoMaster).translate(context),
                                          removeFood: () => context.read<AddFoodEventBloc>().add(RemoveFoodFromEventAction(foodInEvent: foodInEvent)),
                                          editFood: () {
                                            final option = eventHelper.findFoodNameFromId(foodInEvent.id, context, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                            final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                                            showAddFoodEventDialog(
                                              AddFoodEventDialog(
                                                unitsFoodsMaster: state.unitsFoodsMaster!,
                                                unitsInfoMaster: state.unitsInfoMaster!,
                                                foodInEvent: foodInEvent,
                                                currentLanguage: Localizations.localeOf(context).languageCode,
                                                foodGroup: foodGroup.orEmpty(),
                                                cookingMethodsInfoMaster: state.cookingMethodsInfoMaster!,
                                                cookingMethodsMaster: state.cookingMethodsMaster!,
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
                      child: RoundedCustomButton(onPressed: () {
                        bloc.add(ValidateListEventAction());

                        if(state.foodsFromFavorite!.isEmpty) {
                          if (state.foodsInEvent!.isNotEmpty) {
                            if (!(bloc.validateList() ?? true)) {
                              showAddFoodNameDialog(
                                  context: context,
                                  onFinish: (){
                                    context
                                        .read<AddFoodEventBloc>()
                                        .add(FinishFoodEventAction(
                                      onFinish: () =>
                                          _showConfirmationDialog(context),
                                    ),);},
                                  onNameChange: (foodName) {
                                    bloc.add(AddFoodNameEventAction(
                                        foodName: foodName,),);
                                  },);
                            }
                          } else {
                            ToastHelper().showToast(text: AppLocalizations.of(context)!.must_complete_field);
                          }
                        }
                        else {
                          context.read<AddFoodEventBloc>().add(FinishFoodFavouriteEventAction(onFinish: () => _showConfirmationDialog(context),),);
                        }
                        },
                      ),
                    )],
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
