import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../infrastructure/helpers/i10n_helper.dart';
import '../../../infrastructure/helpers/image_helper.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../common/view/loading_screen.dart';
import '../../recommendations/common/bloc/recommendations_general_actions.dart';
import '../../recommendations/common/bloc/recommendations_general_bloc.dart';
import '../../recommendations/common/bloc/recommendations_general_state.dart';
import '../../widgets/recipe_carousel.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
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
                    // if (state.showRecipesCard != null && state.showRecipesCard!) ExplainingCardsHelper().getExplainingCardWithId(
                    //   context: context,
                    //   explainingCardId: ExplainingCardRefs.recipes.index,
                    //   onHideCard: () => bloc.add(HideRecipeExplainingCardAction()),
                    // ),
                    Container(
                      margin: const EdgeInsets.only(top: Dimens.marginNormal),
                    ),
                    state.recipesList!.isEmpty
                        ? Container(
                      margin: const EdgeInsets.all(Dimens.marginLarge),
                      child: Text(AppLocalizations.of(context)!.no_discovers),
                    )
                        : Container(
                      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                      child: Column(
                        children: [
                          if (bloc.areRecipesForMealTime(0)) RecipeCarousel(
                            mealTime: AppLocalizationsHelper.instance.translate('breakfast'),
                            recipesList: bloc.getRecipesForMealTime(0),
                            imagesList: imagesHelper.getImagesList(bloc.getRecipesForMealTime(0).length),
                            getIngredients: (ingredientsList) => bloc.getIngredientsInfo(ingredientsList),
                            screenToMove: (itemRecipe) {},
                          ),
                          if (bloc.areRecipesForMealTime(1)) RecipeCarousel(
                            mealTime: AppLocalizationsHelper.instance.translate('lunch'),
                            recipesList:bloc.getRecipesForMealTime(1),
                            imagesList: imagesHelper.getImagesList(bloc.getRecipesForMealTime(1).length),
                            getIngredients: (ingredientsList) => bloc.getIngredientsInfo(ingredientsList),
                            screenToMove: (itemRecipe) {},
                          ),
                          if (bloc.areRecipesForMealTime(2)) RecipeCarousel(
                            mealTime: AppLocalizationsHelper.instance.translate('dinner'),
                            recipesList: bloc.getRecipesForMealTime(2),
                            imagesList: imagesHelper.getImagesList(bloc.getRecipesForMealTime(2).length),
                            getIngredients: (ingredientsList) => bloc.getIngredientsInfo(ingredientsList),
                            screenToMove: (itemRecipe) {},
                          ),
                          if (bloc.areRecipesForMealTime(3)) RecipeCarousel(
                            mealTime: AppLocalizationsHelper.instance.translate('snack'),
                            recipesList: bloc.getRecipesForMealTime(3),
                            imagesList: imagesHelper.getImagesList(bloc.getRecipesForMealTime(3).length),
                            getIngredients: (ingredientsList) => bloc.getIngredientsInfo(ingredientsList),
                            screenToMove: (itemRecipe) {},
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