import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/image_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_app_bar.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recipe_carousel.dart';

import '../../../widgets/custom_bottom_navi_bar_widget.dart';

class RecipesTab extends StatefulWidget {
  final List<SimpleItem> foodItems;

  const RecipesTab({
    Key? key,
    required this.foodItems,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RecipesTab();
}

class _RecipesTab extends State<RecipesTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<RecommendationsGeneralBloc>(context);
    final imagesHelper = ImageHelper();
    bloc.add(SetFoodIdsAndGetRecipesAction());

    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<RecommendationsGeneralBloc, RecommendationsGeneralState>(
        listener: (ctx, state) {
          if (state.isLoading) {
            LoadingScreen.instance().show(
              context: ctx,
              text: AppLocalizations.of(ctx)!.loading,
            );
          } else {
            LoadingScreen.instance().hide();
          }
        },
        builder: (ctx, state) {
          return Scaffold(
            backgroundColor: Colors.grey[200],
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(bottom: Dimens.marginNormal),
                child: Column(
                  children: [
                    if (state.showRecipesCard != null && state.showRecipesCard!) ExplainingCardsHelper().getExplainingCardWithId(
                      context: context,
                      explainingCardId: ExplainingCardRefs.recipes.index,
                      onHideCard: () => bloc.add(HideRecipeExplainingCardAction()),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: Dimens.marginNormal),
                    ),
                    // Container(
                    //   margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                    //   padding: const EdgeInsets.only(bottom: Dimens.marginNormal, right: Dimens.marginSmall),
                    //   decoration: const BoxDecoration(
                    //     color: Colors.white,
                    //     shape: BoxShape.rectangle,
                    //     borderRadius: BorderRadius.all(Radius.circular(10)),
                    //   ),
                    //   child: TextField(
                    //     controller: _searchController,
                    //     decoration: InputDecoration(
                    //       // border: OutlineInputBorder(
                    //       //   borderRadius: BorderRadius.circular(20),
                    //       //   borderSide: const BorderSide(width: 1, color: Colors.grey),
                    //       // ),
                    //       labelText: AppLocalizations.of(context)!.search,
                    //       alignLabelWithHint: true,
                    //       icon: Container(
                    //         margin: const EdgeInsets.only(left: Dimens.marginSmall),
                    //         child: const Icon(Icons.search, color: Colors.black,),
                    //       ),
                    //       suffixIcon: IconButton(
                    //         icon: _searchController.text != ''
                    //             ? const Icon(
                    //           Icons.highlight_remove,
                    //           color: Colors.black,
                    //         )
                    //             : Container(),
                    //         onPressed: () => _searchController.text = '',
                    //       ),
                    //     ),
                    //     onChanged: (String foodName) {
                    //       setState(() => _searchController);
                    //       if (foodName.length >= 3) {
                    //
                    //       }
                    //     },
                    //   ),
                    // ),
                    state.recipesList!.isEmpty
                        ? Container(
                          margin: const EdgeInsets.all(Dimens.marginLarge),
                          child: Text(AppLocalizations.of(context)!.no_recipes),
                        )
                        : Container(
                          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                          child: Column(
                              children: [
                                if (bloc.areRecipesForMealTime(0)) RecipeCarousel(
                                  mealTime: AppLocalizationsHelper.instance.translate('breakfast'),
                                  recipesList: bloc.getRecipesForMealTime(0),
                                  ingredientsNames: bloc.getIngredientsNames(bloc.getRecipesForMealTime(0), state.foodItems!.map((e) => e.id).toList()).map((foodItemMasterList) => foodItemMasterList.map((foodItemMaster) => foodItemMaster.translate(context)).toList()).toList(),
                                  imagesList: imagesHelper.getImagesList(bloc.getRecipesForMealTime(0).length),
                                ),
                                if (bloc.areRecipesForMealTime(1)) RecipeCarousel(
                                  mealTime: AppLocalizationsHelper.instance.translate('lunch'),
                                  recipesList:bloc.getRecipesForMealTime(1),
                                  ingredientsNames: bloc.getIngredientsNames(bloc.getRecipesForMealTime(1), state.foodItems!.map((e) => e.id).toList()).map((foodItemMasterList) => foodItemMasterList.map((foodItemMaster) => foodItemMaster.translate(context)).toList()).toList(),
                                  imagesList: imagesHelper.getImagesList(bloc.getRecipesForMealTime(1).length),
                                ),
                                if (bloc.areRecipesForMealTime(2)) RecipeCarousel(
                                  mealTime: AppLocalizationsHelper.instance.translate('dinner'),
                                  recipesList: bloc.getRecipesForMealTime(2),
                                  ingredientsNames: bloc.getIngredientsNames(bloc.getRecipesForMealTime(2), state.foodItems!.map((e) => e.id).toList()).map((foodItemMasterList) => foodItemMasterList.map((foodItemMaster) => foodItemMaster.translate(context)).toList()).toList(),
                                  imagesList: imagesHelper.getImagesList(bloc.getRecipesForMealTime(2).length),
                                ),
                                if (bloc.areRecipesForMealTime(3)) RecipeCarousel(
                                  mealTime: AppLocalizationsHelper.instance.translate('snack'),
                                  recipesList: bloc.getRecipesForMealTime(3),
                                  ingredientsNames: bloc.getIngredientsNames(bloc.getRecipesForMealTime(3), state.foodItems!.map((e) => e.id).toList()).map((foodItemMasterList) => foodItemMasterList.map((foodItemMaster) => foodItemMaster.translate(context)).toList()).toList(),
                                  imagesList: imagesHelper.getImagesList(bloc.getRecipesForMealTime(3).length),
                                ),
                              ],
                    ),
                        )
                  ],
                ),
              ),
            ),
            // bottomNavigationBar: CustomBottomAppBar(initStateCallback: () => initState()),
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
          );
        },
      ),
    );
  }

}
