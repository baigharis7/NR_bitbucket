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
import '../../../../infrastructure/helpers/app_text_styles.dart';
import '../../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../../infrastructure/utils/dimens.dart';
import '../../../common/view/loading_screen.dart';
import '../../../dashboard/view/dashboard_screen.dart';
import '../../../recommendations/recipes/view/recipes_tab.dart';
import '../../../widgets/screen_top_bar.dart';

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
    // blocRecipe.add(InitializationRecipeAction());
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
      child: BlocConsumer<RecipeTabBloc, RecipeTabState>(
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
        builder: (context, state) => Stack(
            children: [
              // Background image or gradient
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/recipes_bg.png'), // Your image
                    fit: BoxFit.cover,
                  ),
                ),
              ),


              Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: Dimens.heightSmall),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingSmall),
                          child: ScreenTopBar(
                            selectedDate: null,
                            onBack: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushNamedAndRemoveUntil(context, DashboardScreen.routeName, (route) => false);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: Dimens.heightSmall),
                  Image.asset(
                    'assets/images/logo_name_white.png',
                    fit: BoxFit.cover,
                    height: 106, width: 242,
                  ),
                  const SizedBox(height: Dimens.height70, width: double.infinity),
                  Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.margin_60), child: Text(AppLocalizations.of(context)!.slow_cooking, textAlign: TextAlign.center, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSizeXXLarge, letterSpacing: 0.2),)),
                ],)),
                bottomNavigationBar: const CustomBottomNaviBarWidget(
                  activePosition: Constants.RECIPES,),
              )
            ],
        ),
        /*TabBarView(
            controller: _tabController,
            children: const [
              DiscoverTab(),
              RecipesTab(),
            ],
          ),*/
      ),
    );
  }
}
