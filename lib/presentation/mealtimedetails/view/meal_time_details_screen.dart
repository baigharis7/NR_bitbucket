import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/bloc/meal_time_details_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/header_add_item_card_section.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_info_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/nutrient_row.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_border_box.dart';
import '../../../domain/models/favorites/food/meal_time.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../foodevent/view/add_food_event_screen.dart';

class MealTimeDetailScreen extends StatefulWidget {
  static const routeName = '/meal_time_details_screen';

  const MealTimeDetailScreen({super.key});

  @override
  State<MealTimeDetailScreen> createState() => _MealTimeDetailScreenState();
}

class _MealTimeDetailScreenState extends State<MealTimeDetailScreen> {
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
    bloc = BlocProvider.of<MealTimeDetailsBloc>(context);
    // bloc.add(InitialMealTimeDetailsEventState());

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        var infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is MealTime) {
            final mealTime = infoReceived;
            bloc.add(UpdateMealTimeDetailsEventState(mealTime: mealTime));
          }
        }
      }
    });
    bloc.add(InitialMealTimeDetailsEventState());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<MealTimeDetailsBloc, MealTimeDetailsState>(
        listener: (context, state) {},
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
                body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingLarge),
                      child: Column(
                        children: [
                          HeaderAddItemCardSection(
                            onBackTap: () => Navigator.pop(context),
                            title: state.mealTime?.name.orEmpty(),
                            image: 'assets/images/meal_time_${state.mealTime?.id ?? 0}.png',
                            child: Column(children: [
                              Text('${NutritionUtils.calculateKcal(foodEvents: state.foodEvents.orEmpty())} Kcal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize28, color: Colors.white),),
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
                            ]),
                          ),
                          ...state.foodEvents.orEmpty().map((food) => ItemInfoCard(title: food.foodInfo![0].translate(context), subtitle: '${food.eventKcals.orZero()} kcal. ${food.foodInfo![0].eventInfo?.qty.orZero().toInt()}', trailingSrc: 'assets/images/delete_icon.png', trailingTap: () {

                          },)),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                            child: ListTile(
                              onTap: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: state.mealTime?.id).then((value) => bloc.add(InitialMealTimeDetailsEventState())),
                              leading: Image.asset('assets/images/add_items.png', height: Dimens.height37, width: Dimens.width37),
                              title: Text(
                                AppLocalizations.of(context)!.add_more,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeLarge, decoration: TextDecoration.underline,),
                              ),
                            ),
                          ),

                          if (state.foodEvents.orEmpty().isNotEmpty) RoundedBorderBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...nutrients.map((n) => Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),child: Column(
                                  children: [
                                    NutrientRow(label: n["label"]!, value: n["value"]!),
                                  ],
                                ))),
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
                                  child: Column(
                                    children: [
                                      NutrientRow(label: nutrient.nutrientInfoMaster.translate(context), value: '${nutrient.quantityConsumed.toInt()} ${nutrient.unit}'),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              )
            ],
          );
        },
      ),
    );
  }
}
