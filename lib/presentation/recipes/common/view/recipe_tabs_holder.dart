import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/common/bloc/recipe_tab_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recipes/discover/discover_tab.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';

import '../../../../infrastructure/errors/error_resolver.dart';
import '../../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../../infrastructure/utils/dimens.dart';
import '../../../common/view/loading_screen.dart';
import '../../../recommendations/recipes/view/recipes_tab.dart';

class RecipesTabsHolder extends StatefulWidget {
  static const routeName = '/recipes_tab_holder';

  const RecipesTabsHolder({super.key});

  @override
  State<RecipesTabsHolder> createState() => _RecipesTabsHolderState();
}

class _RecipesTabsHolderState extends State<RecipesTabsHolder>
    with SingleTickerProviderStateMixin {
  String? title;
  late TabController _tabController;
  late RecipeTabBloc blocRecipe;
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
    blocRecipe = BlocProvider.of<RecipeTabBloc>(context);
    blocRecipe.add(InitializationRecipeAction());
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
    return BlocProvider.value(
      value: blocRecipe,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              AppLocalizations.of(context)!.recipes,
              style: const TextStyle(
                fontSize: Dimens.fontSizeLarge,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            // bottom: TabBar(
            //   controller: _tabController,
            //   // onTap: (index) => _manageTabChange(context),
            //   labelColor: Colors.black,
            //   indicatorColor: Colors.black,
            //   tabs: [
            //     Tab(text: AppLocalizations.of(context)!.discover.toUpperCase()),
            //     Tab(text: AppLocalizations.of(context)!.my_recipes.toUpperCase()),
            //   ],
            // ),
          ),
          body: BlocConsumer<RecipeTabBloc, RecipeTabState>(
            listener: (ctx, state) {
              if (state.isLoading) {
                LoadingScreen.instance().show(
                  context: ctx,
                  text: AppLocalizations.of(ctx)!.loading,
                );
              } else {
                LoadingScreen.instance().hide();
              }
              if (!state.onError.isNull()) showErrorSnackBar(ctx, resolveError(context, state.onError!));
            },
            builder: (context, state) => Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0,), color: Colors.black,), child: Center(child: Text(AppLocalizations.of(context)!.coming_soon, style: const TextStyle(color: Colors.white),),)),
            /*TabBarView(
              controller: _tabController,
              children: const [
                DiscoverTab(),
                RecipesTab(),
              ],
            ),*/
          ),
          bottomNavigationBar: const CustomBottomNaviBarWidget(
              activePosition: Constants.RECIPES,),
        ),
      ),
    );
  }
}
