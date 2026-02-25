import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/floating_menu_controller.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/routinestabs/bloc/routines_tab_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/routinestabs/view/meal_routines_tab.dart';
import 'package:nutrenaissance_flutter/presentation/routinestabs/view/physical_activity_routines_tab.dart';
import 'package:nutrenaissance_flutter/presentation/routinestabs/view/supplement_routines_tab.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/view/supplements_screen.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../widgets/general_button.dart';
import '../../widgets/header_add_item_card_section.dart';
import '../../../infrastructure/utils/constants.dart';

class RoutinesTabHolder extends StatefulWidget {
  static const routeName = '/routines_tab_holder';
  const RoutinesTabHolder({super.key});

  @override
  State<RoutinesTabHolder> createState() => _RoutinesTabHolderState();
}

class _RoutinesTabHolderState extends State<RoutinesTabHolder> with SingleTickerProviderStateMixin {
  String? title;
  late TabController _tabController;
  int _selectedTab = 0;
  List<String> _tabs = ['', '', ''];
  late RoutinesTabBloc routinesTabsBloc;

  @override
  void didChangeDependencies() {
    _tabs = [AppLocalizations.of(context)!.meal.toUpperCase(), AppLocalizations.of(context)!.physical_activity.toUpperCase(), AppLocalizations.of(context)!.supplements.toUpperCase()];
    super.didChangeDependencies();
  }

  @override
  void initState() {
    routinesTabsBloc = BlocProvider.of<RoutinesTabBloc>(context);
    routinesTabsBloc.add(InitializeRoutinesTabEvent());
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFabPressed() {
    switch (_selectedTab) {
      case 0: // Meal tab - show overlay with meal time options
        FloatingMenuController().show(
          context,
          _getMealTimeMenuItems(context),
          showFavoritesRoutinesButtons: false,
          centered: true,
        );
        break;
      case 1: // Physical Activity tab - direct navigation
        Navigator.pushNamed(
          context,
          AddSportEventScreen.routeName,
          arguments: SportArgumentsModel(
            selectedDateTime: DateTime.now(),
            preSelectRoutine: true, // Pre-select routine option
          ),
        );
        break;
      case 2: // Supplements tab - direct navigation
        Navigator.pushNamed(
          context,
          SupplementsScreen.routeName,
          arguments: {'preSelectRoutine': true},
        );
        break;
    }
  }

  List<Map<String, dynamic>> _getMealTimeMenuItems(BuildContext context) {
    return MealTime.getAllMealTimes().map((e) => {
      'label': e.name,
      'id': e.id,
      'icon': 'assets/images/meal_time_${e.id.orZero()}.png',
      'onTap': () => Navigator.pushNamed(
        context,
        AddFoodEventScreen.routeName,
        arguments: FoodArgumentsModel(
          mealTime: e,
          selectedDateTime: DateTime.now(),
          preSelectRoutine: true, // Pre-select routine option
        ),
      ),
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: routinesTabsBloc,
      child: BlocConsumer<RoutinesTabBloc, RoutinesTabState>(
        listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }
          if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
        },
        builder: (context, state) => Stack(
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
              body: SafeArea(child: Container(
                padding: const EdgeInsets.all(Dimens.paddingLarge),
                child: Column(children: [
                  HeaderAddItemCardSection(title: AppLocalizations.of(context)!.routines, onBackTap: () => Navigator.pop(context),),
                  const SizedBox(height: Dimens.height12),
                  TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(Dimens.border15),
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: Dimens.padding6),
                    labelColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: AppColors.yellowishGreen,
                    tabs: List.generate(_tabs.length, (index) {
                      final isSelected = _tabController.index == index;
                      return Container(
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimens.border15),
                          color: isSelected ? AppColors.yellowishGreen59 : AppColors.butter59,
                        ),
                        child: Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.margin6), child: Text(_tabs[index], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize11), textAlign: TextAlign.center)),
                      );
                    }),
                  ),
                  const SizedBox(height: Dimens.height5),
                  const Divider(color: AppColors.yellowishGreen, height: 2, thickness: 2,),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children:  const [
                        MealRoutinesTab(),
                        PhysicalActivityRoutinesTab(),
                        SupplementRoutinesTab(),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: Dimens.marginSmall, left: Dimens.marginLarge, right: Dimens.marginLarge),
                    child: GeneralButton(
                      title: AppLocalizations.of(context)!.add,
                      onTap: _onFabPressed,
                    ),
                  ),
                ],
                ),
              ),),
            ),
          ],
        ),
      ),
    );
  }
}