import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/undo_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/favorite_liquids_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/favorite_liquids_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/favorite_liquids_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/view/create_new_liquid_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/view/favorite_liquids_cluster_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/favorites_cluster.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

class FavoriteLiquidsScreen extends StatefulWidget {
  static const routeName = '/favorite_liquids';

  const FavoriteLiquidsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FavoriteLiquidsScreenState();

}

class _FavoriteLiquidsScreenState extends State<FavoriteLiquidsScreen> {

  Future<void> showUndoFavoriteDialog({
    required BuildContext context,
    required String liquidTitle,
    required Function onUndoFavorite,
  }) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return UndoFavoriteDialog(
          title: liquidTitle,
          onUndoFavorite: () => onUndoFavorite.call(),
        );
      },
    );
  }

  @override
  void initState() {
    final bloc = BlocProvider.of<FavoriteLiquidsBloc>(context);
    bloc.add(InitializeState());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FavoriteLiquidsBloc>(context);

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<FavoriteLiquidsBloc, FavoriteLiquidsState>(
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
                backgroundColor: Colors.white,
                titleSpacing: Dimens.marginNormal,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: Dimens.marginNormal),
                      child: Text(
                        AppLocalizations.of(context)!.liquid_favorites,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: Dimens.fontSizeLarge,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, CreateNewLiquidFavoriteScreen.routeName).then((value) => bloc.add(InitializeState())),
                      icon: const Icon(Icons.add_circle_outline_sharp, color: Colors.black,),
                    )
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FavoritesCluster(
                      clusterTitle: AppLocalizationsHelper.instance.translate('breakfast'),
                      items: bloc.getFavoritesSummary(Breakfast()).map((favorite) => favorite.title).toList(),
                      onEdit: (index) => bloc.getFavoritesSummary(Breakfast())[index],
                      onFavorite: (index) => showUndoFavoriteDialog(
                        context: context,
                        liquidTitle: bloc.getFavoritesSummary(Breakfast())[index].title,
                        onUndoFavorite: () => bloc.add(
                          RemoveFavoriteAction(
                            liquidFavorite: bloc.getFavoritesSummary(Breakfast())[index],
                            onFinish: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      onSeeMore: () => Navigator.pushNamed(context, FavoriteLiquidsClusterScreen.routeName, arguments: Breakfast()),
                    ),
                    FavoritesCluster(
                      clusterTitle: AppLocalizationsHelper.instance.translate('lunch'),
                      items: bloc.getFavoritesSummary(Lunch()).map((favorite) => favorite.title).toList(),
                      onEdit: (index) => bloc.getFavoritesSummary(Lunch())[index],
                      onFavorite: (index) => showUndoFavoriteDialog(
                        context: context,
                        liquidTitle: bloc.getFavoritesSummary(Breakfast())[index].title,
                        onUndoFavorite: () => bloc.add(
                          RemoveFavoriteAction(
                            liquidFavorite: bloc.getFavoritesSummary(Lunch())[index],
                            onFinish: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      onSeeMore: () => Navigator.pushNamed(context, FavoriteLiquidsClusterScreen.routeName, arguments: Lunch()),
                    ),
                    FavoritesCluster(
                      clusterTitle: AppLocalizationsHelper.instance.translate('dinner'),
                      items: bloc.getFavoritesSummary(Dinner()).map((favorite) => favorite.title).toList(),
                      onEdit: (index) => bloc.getFavoritesSummary(Dinner())[index],
                      onFavorite: (index) => showUndoFavoriteDialog(
                        context: context,
                        liquidTitle: bloc.getFavoritesSummary(Breakfast())[index].title,
                        onUndoFavorite: () => bloc.add(
                          RemoveFavoriteAction(
                            liquidFavorite: bloc.getFavoritesSummary(Dinner())[index],
                            onFinish: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      onSeeMore: () => Navigator.pushNamed(context, FavoriteLiquidsClusterScreen.routeName, arguments: Dinner()),                    ),
                    FavoritesCluster(
                      clusterTitle: AppLocalizationsHelper.instance.translate('snack'),
                      items: bloc.getFavoritesSummary(Snack()).map((favorite) => favorite.title).toList(),
                      onEdit: (index) => bloc.getFavoritesSummary(Snack())[index],
                      onFavorite: (index) => showUndoFavoriteDialog(
                        context: context,
                        liquidTitle: bloc.getFavoritesSummary(Breakfast())[index].title,
                        onUndoFavorite: () => bloc.add(
                          RemoveFavoriteAction(
                            liquidFavorite: bloc.getFavoritesSummary(Snack())[index],
                            onFinish: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      onSeeMore: () => Navigator.pushNamed(context, FavoriteLiquidsClusterScreen.routeName, arguments: Snack()),                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}