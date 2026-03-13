import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/bloc/favorites_tabs_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/view/meal_tab.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/view/physical_activity_tab.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/view/supplements_tab.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
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
import '../../widgets/screen_top_bar.dart';
import '../../../infrastructure/utils/constants.dart';

class FavoritesTabHolder extends StatefulWidget {
  static const routeName = '/favorites_tab_holder';
  const FavoritesTabHolder({super.key});

  @override
  State<FavoritesTabHolder> createState() => _FavoritesTabHolderState();
}

class _FavoritesTabHolderState extends State<FavoritesTabHolder> with TickerProviderStateMixin {
  String? title;
  late TabController _tabController;
  int _selectedTab = 0;
  List<String> _tabs = ['', '', ''];
  late FavoritesTabsBloc favoritesTabsBloc;

  late AnimationController _mealMenuAnimController;
  OverlayEntry? _mealScrimEntry;
  OverlayEntry? _mealMenuEntry;
  bool _mealMenuOpen = false;

  @override
  void didChangeDependencies() {
    _tabs = [AppLocalizations.of(context)!.meal.toUpperCase(), AppLocalizations.of(context)!.physical_activity.toUpperCase(), AppLocalizations.of(context)!.supplements.toUpperCase()];
    super.didChangeDependencies();
  }

  @override
  void initState() {
    favoritesTabsBloc = BlocProvider.of<FavoritesTabsBloc>(context);
    favoritesTabsBloc.add(InitializeFavoritesTabsEvent());
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
    _mealMenuAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    super.initState();
  }


  @override
  void dispose() {
    _tabController.dispose();
    _mealMenuAnimController.dispose();
    _mealScrimEntry?.remove();
    _mealMenuEntry?.remove();
    super.dispose();
  }

  void _onFabPressed() {
    switch (_selectedTab) {
      case 0: // Meal tab - show overlay with meal time options
        _toggleMealMenu();
        break;
      case 1: // Physical Activity tab - direct navigation
        Navigator.pushNamed(
          context,
          AddSportEventScreen.routeName,
          arguments: SportArgumentsModel(
            selectedDateTime: DateTime.now(),
            preSelectFavorite: true,
          ),
        );
        break;
      case 2: // Supplements tab - direct navigation
        Navigator.pushNamed(context, SupplementsScreen.routeName, arguments: {'preSelectFavorite': true});
        break;
    }
  }

  List<Map<String, dynamic>> _getMealTimeMenuItems(BuildContext context) {
    return MealTime.getAllMealTimes().map((e) => {
      'label': e.name,
      'icon': 'assets/images/meal_time_${e.id.orZero()}.png',
      'onTap': () => Navigator.pushNamed(
        context,
        AddFoodEventScreen.routeName,
        arguments: FoodArgumentsModel(
          mealTime: e,
          selectedDateTime: DateTime.now(),
          preSelectFavorite: true,
        ),
      ),
    }).toList();
  }

  void _toggleMealMenu() {
    if (_mealMenuOpen) {
      _closeMealMenu();
    } else {
      _openMealMenu();
    }
  }

  void _openMealMenu() {
    final items = _getMealTimeMenuItems(context);

    setState(() {
      _mealMenuOpen = true;
      _mealMenuAnimController.forward();
    });

    _mealScrimEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        onTap: _closeMealMenu,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox.expand(),
      ),
    );

    _mealMenuEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        right: 0,
        bottom: 65 + 8 + MediaQuery.of(context).padding.bottom,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _mealMenuAnimController,
            curve: Curves.easeInOut,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < items.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(bottom: i + 2 < items.length ? 8 : 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _MealMenuItem(
                            label: items[i]['label'] as String,
                            icon: items[i]['icon'] as String,
                            onTap: () {
                              _closeMealMenu();
                              (items[i]['onTap'] as VoidCallback)();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (i + 1 < items.length)
                          Expanded(
                            child: _MealMenuItem(
                              label: items[i + 1]['label'] as String,
                              icon: items[i + 1]['icon'] as String,
                              onTap: () {
                                _closeMealMenu();
                                (items[i + 1]['onTap'] as VoidCallback)();
                              },
                            ),
                          )
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insertAll([_mealScrimEntry!, _mealMenuEntry!]);
  }

  void _closeMealMenu() {
    if (!_mealMenuOpen) return;
    setState(() {
      _mealMenuOpen = false;
    });
    _mealMenuAnimController.reverse().then((_) {
      _mealScrimEntry?.remove();
      _mealScrimEntry = null;
      _mealMenuEntry?.remove();
      _mealMenuEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: favoritesTabsBloc,
      child: BlocConsumer<FavoritesTabsBloc, FavoritesTabsState>(
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
                ScreenTopBar(selectedDate: null, onBack: () => Navigator.pop(context)),
                const SizedBox(height: Dimens.height12),
                HeaderAddItemCardSection(
                  title: AppLocalizations.of(context)!.favorites,
                  icon: Icons.star_rounded,
                ),
                const SizedBox(height: Dimens.height12),
                TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(Dimens.border15),
                  ),
                  dividerColor: Colors.transparent,
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
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      MealTab(),
                      PhysicalActivityTab(),
                      SupplementsTab(),
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

const _kNavColor = Color(0xFF28421D);

class _MealMenuItem extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _MealMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kNavColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.merriWeather.copyWith(
                  color: _kNavColor,
                  fontSize: Dimens.fontSizeSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(icon, width: 32, height: 32),
          ],
        ),
      ),
    );
  }
}