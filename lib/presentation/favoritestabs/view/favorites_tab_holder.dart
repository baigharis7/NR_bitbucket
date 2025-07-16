import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/bloc/favorites_tabs_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/view/meal_tab.dart';
import 'package:nutrenaissance_flutter/presentation/favoritestabs/view/physical_activity_tab.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/header_add_item_card_section.dart';

class FavoritesTabHolder extends StatefulWidget {
  static const routeName = '/favorites_tab_holder';
  const FavoritesTabHolder({super.key});

  @override
  State<FavoritesTabHolder> createState() => _FavoritesTabHolderState();
}

class _FavoritesTabHolderState extends State<FavoritesTabHolder> with SingleTickerProviderStateMixin {
  String? title;
  late TabController _tabController;
  int _selectedTab = 0;
  List<String> _tabs = ['', ''];
  late FavoritesTabsBloc favoritesTabsBloc;

  @override
  void didChangeDependencies() {
    _tabs = [AppLocalizations.of(context)!.meal.toUpperCase(), AppLocalizations.of(context)!.physical_activity.toUpperCase(),];
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
      value: favoritesTabsBloc,
      child: BlocConsumer<FavoritesTabsBloc, FavoritesTabsState>(
        listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.recal_nutrients,
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
            body: SafeArea(child: Container(
              padding: const EdgeInsets.all(Dimens.paddingLarge),
              child: Column(children: [
                HeaderAddItemCardSection(title: AppLocalizations.of(context)!.favorites, onBackTap: () => Navigator.pop(context),),
                const SizedBox(height: Dimens.height12),
                TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(Dimens.borderNormal),
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: Dimens.padding10),
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  unselectedLabelColor: AppColors.yellowishGreen,
                  tabs: List.generate(_tabs.length, (index) {
                    final isSelected = _tabController.index == index;
                    return Container(
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimens.borderNormal),
                        color: isSelected ? AppColors.yellowishGreen : AppColors.butter59,
                      ),
                      child: Text(_tabs[index]),
                    );
                  }),
                ),
                const SizedBox(height: Dimens.height5),
                const Divider(color: AppColors.yellowishGreen, height: 2, thickness: 2,),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      MealTab(),
                      PhysicalActivityTab(),
                    ],
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