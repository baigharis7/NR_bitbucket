import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/presentation/itemupdate/bloc/item_update_bloc.dart';

import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/events_helper.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../foodevent/view/food_event_item.dart';
import '../../widgets/date_picker_bar.dart';
import '../../widgets/general_button.dart';
import '../../widgets/header_add_item_card_section.dart';

class ItemUpdateScreen extends StatefulWidget {
  static const routeName = '/item_update_screen';

  const ItemUpdateScreen({super.key});

  @override
  State<ItemUpdateScreen> createState() => _ItemUpdateScreenState();
}

class _ItemUpdateScreenState extends State<ItemUpdateScreen> {
  late ItemUpdateBloc itemUpdateBloc;
  TextEditingController _foodInputController = TextEditingController();
  late FocusNode _focusInputController;

  @override
  void initState() {
    itemUpdateBloc = BlocProvider.of<ItemUpdateBloc>(context);
    itemUpdateBloc.add(InitializeItemUpdateEvent());

    final widgetBinding = WidgetsBinding.instance;
    widgetBinding.addPostFrameCallback((timeStamp) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is FoodEventComplete) {
            itemUpdateBloc.add(UpdateFoodFromLoggedItemUpdateEvent(foodEventComplete: infoReceived));
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
      value: itemUpdateBloc,
      child: BlocConsumer<ItemUpdateBloc, ItemUpdateState>(
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
        builder: (context, state) => Stack(
          children: [
            // Background image or gradient
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  // Your image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color:
                    Colors.black.withOpacity(0), // Needed to activate the blur
              ),
            ),

            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.paddingSmall,
                    vertical: Dimens.paddingLarge),
                child: Column(children: [
                  DatePickerBar(
                    selectedDateTime: DateTimeHelper.dateTimeFromMilliseconds(state.foodEvent?.eventDate),
                    onChangeDate: (dateTime) => itemUpdateBloc.add(UpdateEventDateItemUpdateEvent(dateTime: dateTime)),
                  ),
                  const SizedBox(height: Dimens.height12),
                  HeaderAddItemCardSection(
                    onBackTap: () => Navigator.pop(context),
                    title: AppLocalizations.of(context)!.edit +' '+ (MealTime.getAllMealTimes().firstWhere((element) => element.id == (state.foodEvent?.mealTime ?? 0)).name ?? ''),
                    image: 'assets/images/meal_time_${state.foodEvent?.mealTime ?? 0}.png',
                    items: state.foodNames?.foodsAndDrinksNames?.foodNames.orEmpty().map((item) => item.translate(context)).toList(),
                    onItemSelect: (option, focus) {
                      _focusInputController = focus;
                      final food = eventHelper.findFoodByFoodName(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                      final foodGroup = eventHelper.findFoodGroup(option, currentLanguage, state.foodNames!.foodsAndDrinksNames!.foodNames!);
                      itemUpdateBloc.add(AddFoodItemUpdateEvent(foodInEvent: food!));
                    },
                  ),
                  const SizedBox(height: Dimens.height12),
                  ListView.builder(
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.foodEvent?.ingredients.length ?? 0,
                    itemBuilder: (context, index) {
                      final foodInEvent = state.foodEvent!.ingredients.orEmpty()[index];
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
                        onRemove: () => itemUpdateBloc.add(RemoveFoodItemUpdateEvent(foodInEvent: foodInEvent, isGoBack: () => Navigator.pop(context))),
                        onQtyChange: (changedFood) => itemUpdateBloc.add(UpdateQuantityItemUpdateEvent(foodInEvent: changedFood)),
                        onUnitChange: (changedFood) => itemUpdateBloc.add(UpdateUnitItemUpdateEvent(foodInEvent: changedFood)),
                        onCookingMethodChange: (changedFood) => itemUpdateBloc.add(UpdateCookingMethodItemUpdateEvent(foodInEvent: changedFood)),
                        onConversionFactorChange: (changedFood) => itemUpdateBloc.add(UpdateConversionFactorItemUpdateEvent(foodInEvent: changedFood)),
                        onOilUsedChange: (changedFood) => itemUpdateBloc.add(UpdateOilItemUpdateEvent(foodInEvent: changedFood)),
                      );
                  },),
                  if (state.foodEvent?.ingredients.isNotEmpty == true) Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimens.marginSmall),
                    child: GeneralButton(onTap: () {
                      if (itemUpdateBloc.validateList() ?? true) return;
                      itemUpdateBloc.add(FinishUpdateFoodEventAction(onFinish: ()=> Navigator.pop(context)));
                    },
                    ),
                  ),
                ]),
              )),
            )
          ],
        ),
      ),
    );
  }
}
