import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrients_detail/bloc/micro_nutrients_detail_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/micronutrientsweekly/view/micro_nutrients_weekly_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../domain/models/favorites/food/meal_time.dart';
import '../../common/view/floating_menu_controller.dart';
import '../../common/view/loading_screen.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../fecesurine/view/feces_urine_tab_holder.dart';
import '../../foodevent/view/add_food_event_screen.dart';
import '../../profile/profile/view/profile_screen.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../widgets/micro_nutrient_detail_widget.dart';
import '../../widgets/weekly_nutrient_graphic.dart';

class MicroNutrientsDetailScreen extends StatefulWidget {
  static const routeName = '/micro_nutrients_detail_screen';

  const MicroNutrientsDetailScreen({super.key});

  @override
  State<MicroNutrientsDetailScreen> createState() =>
      _MicroNutrientsDetailScreenState();
}


class _MicroNutrientsDetailScreenState
    extends State<MicroNutrientsDetailScreen> with SingleTickerProviderStateMixin {
  late final MicroNutrientsDetailBloc bloc;
  bool isOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    bloc = BlocProvider.of<MicroNutrientsDetailBloc>(context);
    bloc.add(InitializationEventAction());
    super.initState();

    _controller = AnimationController(duration: Duration(milliseconds: 250), vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);

    final widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final infoReceived = ModalRoute.of(context)?.settings.arguments;
        if (infoReceived != null) {
          if (infoReceived is List<NutrientsModel>?) {
            final micronutrientsList = infoReceived as List<NutrientsModel>?;
            bloc.add(LoadMicroNutrientsDetails(micronutrientsList: micronutrientsList ?? []));
          }
        }
      }
    });
  }

  List<Map<String, dynamic>> getMenuItems(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      ...MealTime.getAllMealTimes().map((e) => {'label': e.name, 'id': e.id, 'icon': 'assets/images/meal_time_${e.id.orZero()}.png', 'onTap': () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: e.id)}),
      // {'label': 'Actividad física', 'icon': Icons.fitness_center},
      {'label': AppLocalizations.of(context)!.faeces_urine, 'icon': 'assets/images/feces_urine.png', 'onTap': () => Navigator.pushNamed(context, FecesUrineTabHolder.routeName)},
      {'label': AppLocalizations.of(context)!.supplements, 'icon': 'assets/images/supplement.png', 'onTap': () {}},
    ];

    return menuItems;
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider.value(value: bloc,
      child: SafeArea(
        child: BlocConsumer<MicroNutrientsDetailBloc, MicroNutrientsDetailState>(listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }
          // if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
        }, builder: (context, state) => Scaffold(
            resizeToAvoidBottomInset: false,
          body: Stack(
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

              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingNormal, vertical: Dimens.paddingLarge),
                child: Column(
                  children: [
                    HeaderAddItemCardSection(
                      title: AppLocalizations.of(context)!.micronutrientss,
                      onBackTap: () => Navigator.pop(context),
                    ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: Dimens.marginLarge),
                          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingLarge),
                          decoration: const BoxDecoration(color: AppColors.floralWhite, borderRadius: BorderRadius.all(Radius.circular(15))),
                          child: Column(children: [
                            Row(children: [
                              Image.asset('assets/images/goal_objectives.png', height: 40, width: 40),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal,),
                                  child: Text(AppLocalizations.of(context)!.micronutrients, style: const TextStyle(
                                      color: AppColors.peacockBlue, fontWeight: FontWeight.w900, fontSize: Dimens.fontSizeMedium, decoration: TextDecoration.underline
                                  ),),
                                ),
                              ),
                              InkWell(onTap: () => Navigator.pushNamed(context, MicroNutrientsWeeklyScreen.routeName, arguments: state.micronutrientsWeekly), child: Image.asset('assets/images/nutrient_graph.png', height: 30, width: 30)),
                            ],),
                              ...state.microNutrients.orEmpty().where((element) => element.nutrientInfoMaster.translateDescription(context).isNotEmptyOrNull()).map((item) =>
                          MicroNutrientDetailWidget(nutrientsModel: item,))
                          ]),

                        ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
          floatingActionButton: FloatingActionButton(
            onPressed: () => FloatingMenuController().show(context, getMenuItems(context)),
            backgroundColor: Colors.transparent,
            clipBehavior: Clip.hardEdge,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.greenCyan, AppColors.bluishGreen], begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: [0.0, 0.7])),
              child: RotationTransition(
                turns: _animation,
                child: const Icon(Icons.add),
              ),
            ),
          ),
          // CustomBottomAppBar(initStateCallback: () => null),
          // resizeToAvoidBottomInset: true,
          // floatingActionButton: FloatingActionButton(
          //   elevation: 2.0,
          //   backgroundColor: Colors.white,
          //   onPressed: () => Navigator.popAndPushNamed(context, DashboardScreen.routeName),
          //   child: Container(
          //     padding: const EdgeInsets.all(Dimens.paddingSmall),
          //     child: Image.asset(
          //       'assets/images/logo_black.png',
          //       fit: BoxFit.cover,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),),
      ),);
  }
}
