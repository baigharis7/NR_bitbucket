import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/midnight_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:nutrenaissance_flutter/presentation/itemupdate/view/item_update_screen.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/bloc/meal_time_details_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_info_card.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/nutrient_row.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_border_box.dart';
import '../../../domain/models/foodevents/food_arguments_model.dart';
import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../foodevent/view/add_food_event_screen.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/screen_top_bar.dart';
import '../../widgets/remove_item_widget.dart';
import '../../../infrastructure/utils/constants.dart';

class MealTimeDetailScreen extends StatefulWidget {
  static const routeName = '/meal_time_details_screen';

  const MealTimeDetailScreen({super.key});

  @override
  State<MealTimeDetailScreen> createState() => _MealTimeDetailScreenState();
}

class _MealTimeDetailScreenState extends State<MealTimeDetailScreen> with MidnightToastMixin {
  late MealTimeDetailsBloc bloc;
  final nutrients = [
    {"label": "Fibra", "value": "12g"},
    {"label": "Azucar libre", "value": "23g"},
  ];

  final micronutrients = [
    {"label": "Vitamina B6", "value": "123g"},
    {"label": "Tipófano B12", "value": "123g"},
    {"label": "Zinc", "value": "123g"},
    {"label": "Vitamina E", "value": "123g"},
    {"label": "Hierro", "value": "123g"},
    {"label": "Calcio", "value": "123g"},
    {"label": "Magnesio", "value": "123g"},
    {"label": "Omega 3", "value": "123g"},
  ];

  @override
  void initState() {
    subscribeMidnight();
    bloc = BlocProvider.of<MealTimeDetailsBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final infoReceived = ModalRoute.of(context)?.settings.arguments;
      if (infoReceived is FoodArgumentsModel) {
        bloc.add(UpdateFoodArgumentsModelEventState(foodArgumentsModel: infoReceived));
      } else {
        bloc.add(InitialMealTimeDetailsEventState());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    unsubscribeMidnight();
    super.dispose();
  }

  // TODO: Remove Item from db
  void _showRemoveDialog({required String description, required VoidCallback onCancel, required VoidCallback onConfirm}) {
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => RemoveItemWidget(
        description: description,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  void _showFoodLabelDialog(BuildContext context, MealTimeDetailsState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(Dimens.paddingLarge),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: RoundedBorderBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: Dimens.height25),
                      ...state.fiberSugar.orEmpty().map((n) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                        child: NutrientRow(label: n.nutrientInfoMaster.translate(context), value: '${n.quantityConsumed} ${n.unit}'),
                      )),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.micronutrientss,
                        style: const TextStyle(
                          fontSize: Dimens.fontSizeLarge,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...state.micronutrients.orEmpty().map((nutrient) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                        child: NutrientRow(label: nutrient.nutrientInfoMaster.translate(context), value: '${nutrient.quantityConsumed} ${nutrient.unit}'),
                      )),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () => Navigator.pop(dialogContext),
                  child: Container(
                    padding: const EdgeInsets.all(Dimens.padding4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<MealTimeDetailsBloc, MealTimeDetailsState>(
        listener: (ctx, state) {
          // if (state.isLoading) {
          //   LoadingScreen.instance().show(
          //     context: ctx,
          //     text: AppLocalizations.of(ctx)!.loading,
          //   );
          // } else {
          //   LoadingScreen.instance().hide();
          // }
          if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
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

              Scaffold(
                backgroundColor: Colors.transparent,
                bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
                body: SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall, vertical: Dimens.paddingLarge),
                            child: Column(
                              children: [
                                ScreenTopBar(
                                  selectedDate: state.selectedDateTime,
                                  onBack: () => Navigator.pop(context),
                                ),
                                const SizedBox(height: Dimens.height12),
                                HeaderAddItemCardSection(
                                  title: '${state.mealTime?.name.orEmpty()} ${AppLocalizations.of(context)!.summary}',
                                  image: 'assets/images/meal_time_${state.mealTime?.id ?? 0}.png',
                                  child: Column(children: [
                                    Text('${NutritionUtils.calculateKcal(foodEvents: state.foodEvents.orEmpty())} Kcal', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize28, color: Colors.white),),
                                    Container(margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),child: const Divider(color: Colors.white, height: 1, thickness: 1)),
                                    Row(children: [
                                      ...state.macronutrients.orEmpty().map((macroNutrient) {
                                        return Expanded(
                                          child: Column(children: [
                                            Text(macroNutrient.nutrientInfoMaster.translate(context), style: const TextStyle(color: Colors.white, fontSize: Dimens.fontSizeSmall, fontWeight: FontWeight.w700)),
                                            Text('${macroNutrient.quantityConsumed.toInt()}${macroNutrient.unit}', style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600, fontSize: Dimens.fontSize21)),
                                          ],),
                                        );
                                      }),
                                    ],),
                                    if (state.foodEvents.orEmpty().isNotEmpty) ...[
                                      const SizedBox(height: Dimens.height12),
                                      InkWell(
                                        onTap: () => _showFoodLabelDialog(context, state),
                                        child: Text(
                                          AppLocalizations.of(context)!.food_label,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: Dimens.fontSizeNormal,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ]),
                                ),
                                ...state.foodEvents.orEmpty().map((food) {
                                  final itemName = food.foodName ?? NutritionUtils.findFoodsName(context: context, foodNames: state.foodNames?.foodsAndDrinksNames?.foodNames, ingredients: food.foodInfo);
                                  return ItemInfoCard(
                                    onItemTap: () /*=> Navigator.pushNamed(context, MealTimeItemScreen.routeName)*/ {},
                                    title: itemName,
                                    subtitle: '${AppLocalizations.of(context)!.energy}: ${food.eventKcals.orZero()} kcal. - ${food.foodInfo.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : food.foodInfo.orEmpty().isNotEmpty ? "${AppLocalizations.of(context)!.amount}: ${food.foodInfo![0].eventInfo?.qty.orZero().toInt()} ${NutritionUtils.findUnitName(state.unitsInfoMaster?.unitsInfoMaster, [food.foodInfo![0]], context)}" : ""}.',
                                    trailingSrc: 'assets/images/delete_icon.png',
                                    beforeTrailingSrc: 'assets/icon/edit_icon.png',
                                    beforeTrailingTap: () => Navigator.pushNamed(context, ItemUpdateScreen.routeName, arguments: food).then((value) => bloc.add(InitialMealTimeDetailsEventState(dateTime: state.selectedDateTime))),
                                    trailingTap: () => _showRemoveDialog(
                                      description: AppLocalizations.of(context)!.remove_item(itemName),
                                      onCancel: () => Navigator.pop(context),
                                      onConfirm: () => bloc.add(DeleteFoodMealTimeDetailsEventAction(foodEventComplete: food, onFinish: () {})),
                                    ),
                                  );
                                },),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: Dimens.marginSmall, left: Dimens.marginLarge, right: Dimens.marginLarge, bottom: Dimens.marginSmall),
                          child: GeneralButton(
                            title: AppLocalizations.of(context)!.add,
                            onTap: () => Navigator.popAndPushNamed(context, AddFoodEventScreen.routeName, arguments: FoodArgumentsModel(mealTime: state.mealTime!, selectedDateTime: state.selectedDateTime!)),
                          ),
                        ),
                      ],
                    )),
              ),
            ],
          );
        },
      ),
    );
  }
}
