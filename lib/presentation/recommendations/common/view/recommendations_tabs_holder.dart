import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/foodslist/view/food_list_tab.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/recipes/view/recipes_tab.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/recommendations/view/recommendations_tab.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

import '../../../../infrastructure/utils/app_color.dart';
import '../../../dashboard/view/dashboard_screen.dart';
import '../../../widgets/header_add_item_card_section.dart';
import '../../../widgets/screen_top_bar.dart';

class RecommendationsTabHolder extends StatefulWidget {
  static const routeName = '/recommendations_holder';
  const RecommendationsTabHolder({super.key});

  @override
  State<StatefulWidget> createState() => _RecommendationsTabHolderState();

}

class _RecommendationsTabHolderState extends State<RecommendationsTabHolder> with SingleTickerProviderStateMixin {
  late RecommendationsGeneralBloc _recommendationsBloc;
  late TabController _tabController;
  int _selectedTab = 0;
  List<String> _tabs = ['', ''];

  @override
  void didChangeDependencies() {
    _tabs = [AppLocalizations.of(context)!.tips.toUpperCase(), AppLocalizations.of(context)!.list.toUpperCase()];
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _recommendationsBloc = BlocProvider.of<RecommendationsGeneralBloc>(context);
    _recommendationsBloc.add(InitialStateAction());
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

  @override
  Widget build(BuildContext context) {

    return BlocProvider.value(
      value: _recommendationsBloc,
      child: BlocConsumer<RecommendationsGeneralBloc, RecommendationsGeneralState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Stack(children: [
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
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall, vertical: Dimens.paddingSmall),
                      child: Column(children: [
                        ScreenTopBar(selectedDate: null, onBack: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.routeName, (route) => false);
                          }
                        }),
                        const SizedBox(height: Dimens.height12),
                        HeaderAddItemCardSection(title: AppLocalizations.of(context)!.recommendations,),
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
                      ]),
                    ),
                    // const SizedBox(height: Dimens.height12),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          const RecommendationsTab(),
                          // RecipesTab(foodItems: recommendationsBloc.state.foodItems ?? []),
                          FoodListScreen(foodItems: _recommendationsBloc.state.foodItems ?? []),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.TIPS),
            ),
          ],);
        },),);
  }

}