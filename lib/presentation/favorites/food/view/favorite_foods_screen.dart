import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/explaining_cards_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/undo_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/add_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/create_new_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/favorite_foods_cluster_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/favorites_cluster.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

class FavoriteFoodsScreen extends StatefulWidget {
  static const routeName = '/favorite_foods';

  const FavoriteFoodsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FavoriteFoodsScreenState();
}

class _FavoriteFoodsScreenState extends State<FavoriteFoodsScreen> {

  Future<void> showUndoFavoriteDialog({
    required BuildContext context,
    required String foodTitle,
    required Function onUndoFavorite,
  }) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return UndoFavoriteDialog(
          title: foodTitle,
          onUndoFavorite: () => onUndoFavorite.call(),
        );
      },
    );
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<FavoriteFoodsBloc>(context);
    bloc.add(InitializeState());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FavoriteFoodsBloc>(context);

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<FavoriteFoodsBloc, FavoriteFoodsState>(
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
          builder:  (ctx, state) {
            return Scaffold(
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  AppLocalizations.of(context)!.food_favs,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimens.fontSizeLarge,
                  ),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (state.showCard != null && state.showCard!) ExplainingCardsHelper().getExplainingCardWithId(
                              context: context,
                              explainingCardId: ExplainingCardRefs.addFoodFavorite.index,
                              onHideCard: () => bloc.add(HideExplainingCardAction()),
                              onPressedButton: () => Navigator.pushNamed(context, CreateNewFoodFavoriteScreen.routeName).then((value) => bloc.add(InitializeState())),
                            ),
                            FavoritesCluster(
                              clusterTitle: '${AppLocalizationsHelper.instance.translate('breakfast')}s',
                              items: /*bloc.getFavoritesSummary(Breakfast()).map((favorite) => favorite.title).toList()*/ [],
                              onEdit: (index) => Navigator.pushNamed(context, AddFoodFavoriteScreen.routeName, arguments: bloc.getFavoritesSummary(Breakfast())[index]).then((value) => bloc.add(InitializeState())),
                              onFavorite: (index) => showUndoFavoriteDialog(
                                context: context,
                                foodTitle: bloc.getFavoritesSummary(Breakfast())[index].title ?? '',
                                onUndoFavorite: () => bloc.add(
                                  RemoveFavoriteAction(
                                    foodFavorite: bloc.getFavoritesSummary(Breakfast())[index],
                                    onFinish: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                              onSeeMore: () => Navigator.pushNamed(context, FavoriteFoodsClusterScreen.routeName, arguments: Breakfast()),
                            ),
                            FavoritesCluster(
                              clusterTitle: '${AppLocalizationsHelper.instance.translate('lunch')}s',
                              items: /*bloc.getFavoritesSummary(Lunch()).map((favorite) => favorite.title).toList()*/ [],
                              onEdit: (index) => Navigator.pushNamed(context, AddFoodFavoriteScreen.routeName, arguments: bloc.getFavoritesSummary(Lunch())[index]).then((value) => bloc.add(InitializeState())),
                              onFavorite: (index) => showUndoFavoriteDialog(
                                context: context,
                                foodTitle: bloc.getFavoritesSummary(Lunch())[index].title ?? '',
                                onUndoFavorite: () => bloc.add(
                                  RemoveFavoriteAction(
                                    foodFavorite: bloc.getFavoritesSummary(Lunch())[index],
                                    onFinish: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                              onSeeMore: () => Navigator.pushNamed(context, FavoriteFoodsClusterScreen.routeName, arguments: Lunch()),
                            ),
                            FavoritesCluster(
                              clusterTitle: '${AppLocalizationsHelper.instance.translate('dinner')}s',
                              items: /*bloc.getFavoritesSummary(Dinner()).map((favorite) => favorite.title).toList()*/ [],
                              onEdit: (index) => Navigator.pushNamed(context, AddFoodFavoriteScreen.routeName, arguments: bloc.getFavoritesSummary(Dinner())[index]).then((value) => bloc.add(InitializeState())),
                              onFavorite: (index) => showUndoFavoriteDialog(
                                context: context,
                                foodTitle: bloc.getFavoritesSummary(Dinner())[index].title ?? '',
                                onUndoFavorite: () => bloc.add(
                                  RemoveFavoriteAction(
                                    foodFavorite: bloc.getFavoritesSummary(Dinner())[index],
                                    onFinish: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                              onSeeMore: () => Navigator.pushNamed(context, FavoriteFoodsClusterScreen.routeName, arguments: Dinner()),),
                            FavoritesCluster(
                              clusterTitle: '${AppLocalizationsHelper.instance.translate('snack')}s',
                              items: /*bloc.getFavoritesSummary(Snack()).map((favorite) => favorite.title).toList()*/ [],
                              onEdit: (index) => Navigator.pushNamed(context, AddFoodFavoriteScreen.routeName, arguments: bloc.getFavoritesSummary(Snack())[index]).then((value) => bloc.add(InitializeState())),
                              onFavorite: (index) => showUndoFavoriteDialog(
                                context: context,
                                foodTitle: bloc.getFavoritesSummary(Snack())[index].title ?? '',
                                onUndoFavorite: () => bloc.add(
                                  RemoveFavoriteAction(
                                    foodFavorite: bloc.getFavoritesSummary(Snack())[index],
                                    onFinish: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                              onSeeMore: () => Navigator.pushNamed(context, FavoriteFoodsClusterScreen.routeName, arguments: Snack()),),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: Dimens.marginSmall, left: Dimens.marginLarge, right: Dimens.marginLarge, bottom: Dimens.marginSmall),
                    child: GeneralButton(
                      title: AppLocalizations.of(context)!.add,
                      onTap: () => Navigator.pushNamed(context, CreateNewFoodFavoriteScreen.routeName).then((value) => bloc.add(InitializeState())),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}