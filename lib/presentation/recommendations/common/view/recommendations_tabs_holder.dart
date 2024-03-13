import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/foodslist/view/food_list_tab.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/recipes/view/recipes_tab.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/recommendations/view/recommendations_tab.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

class RecommendationsTabHolder extends StatefulWidget {
  static const routeName = '/recommendations_holder';
  const RecommendationsTabHolder({super.key});

  @override
  State<StatefulWidget> createState() => _RecommendationsTabHolderState();

}

class _RecommendationsTabHolderState extends State<RecommendationsTabHolder> with SingleTickerProviderStateMixin {
  String? title;
  late TabController _tabController;
  late RecommendationsGeneralBloc _recommendationsBloc;
  int _selectedTab = 0;

  void _manageTabChange(BuildContext context) {
    setState(() {
      if (_selectedTab == 0) {
        title = AppLocalizations.of(context)!.recommendations;
      } else if (_selectedTab == 1) {
        // title = AppLocalizations.of(context)!.recipes;
        title = AppLocalizations.of(context)!.foods_list;
      }
      // else if (_selectedTab == 2) {
      //   title = AppLocalizations.of(context)!.foods_list;
      // }
    });
  }

  @override
  void initState() {
    _recommendationsBloc = BlocProvider.of<RecommendationsGeneralBloc>(context);
    _recommendationsBloc.add(InitialStateAction());
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
        setState(() {
          _selectedTab = _tabController.index;
          _manageTabChange(context);
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
    // final recommendationsBloc = BlocProvider.of<RecommendationsGeneralBloc>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: Dimens.marginNormal,
          title: Center(
            child: Text(
              title ?? AppLocalizations.of(context)!.recommendations,
              style: const TextStyle(
                fontSize: Dimens.fontSizeXXLarge,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) => _manageTabChange(context),
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.tips.toUpperCase()),
              // Tab(text: AppLocalizations.of(context)!.recipes.toUpperCase()),
              Tab(text: AppLocalizations.of(context)!.list.toUpperCase()),
            ],
          ),
        ),
        body: TabBarView(
          // physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            const RecommendationsTab(),
            // RecipesTab(foodItems: recommendationsBloc.state.foodItems ?? []),
            FoodListScreen(foodItems: _recommendationsBloc.state.foodItems ?? []),
          ],
        ),
        bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.TIPS),
      ),
    );
  }

}