import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

import '../../../../infrastructure/utils/dimens.dart';
import '../../../recommendations/recipes/view/recipes_tab.dart';


class RecipesTabsHolder extends StatefulWidget {
  static const routeName = '/recipes_tab_holder';
  const RecipesTabsHolder({super.key});

  @override
  State<RecipesTabsHolder> createState() => _RecipesTabsHolderState();
}

class _RecipesTabsHolderState extends State<RecipesTabsHolder> with SingleTickerProviderStateMixin {
  String? title;
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // _selectedTab = _tabController.index;
        // _manageTabChange(context);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // void _manageTabChange(BuildContext context) {
  //   setState(() {
  //     if (_selectedTab == 0) {
  //       title = AppLocalizations.of(context)!.discover;
  //     } else if (_selectedTab == 1) {
  //       title = AppLocalizations.of(context)!.my_recipes;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(AppLocalizations.of(context)!.recipes, style: const TextStyle(
              fontSize: Dimens.fontSizeLarge,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              // onTap: (index) => _manageTabChange(context),
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.discover.toUpperCase()),
                Tab(text: AppLocalizations.of(context)!.my_recipes.toUpperCase()),
              ],
            ),
          ),
          body: TabBarView(
            // physics: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal,),

            controller: _tabController,
            children: const [
              RecipesTab(foodItems: []),
              Scaffold(body: Text('Hamza')),
          ],),
          
          bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.RECIPES),
        )
    );
  }
}