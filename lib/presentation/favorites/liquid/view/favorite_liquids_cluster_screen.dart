import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/favorite_liquids_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/favorite_liquids_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/favorite_liquids_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/view/add_liquid_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/undo_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_list_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

class FavoriteLiquidsClusterScreen extends StatelessWidget {
  static const routeName = '/favorite_liquids_cluster';

  const FavoriteLiquidsClusterScreen({
    Key? key,
  }) : super(key: key);

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
          onUndoFavorite: onUndoFavorite.call(),
        );
      },
    ).then((value) => Navigator.pop(context));
  }

  dynamic assignMealTimeType(dynamic mealTime) {
    if (mealTime.runtimeType == Breakfast) {
      mealTime as Breakfast;
      return Breakfast();
    } else if(mealTime.runtimeType == Lunch) {
      mealTime as Lunch;
      return Lunch();
    } else if(mealTime.runtimeType == Dinner) {
      mealTime as Dinner;
      return Dinner();
    } else if(mealTime.runtimeType == Snack) {
      mealTime as Snack;
      return Snack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<FavoriteLiquidsBloc>(context);
    var mealTime = assignMealTimeType(ModalRoute.of(context)!.settings.arguments);

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<FavoriteLiquidsBloc, FavoriteLiquidsState>(
          listener: (ctx, state) {},
          builder: (ctx, state) {
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
                    Container(
                      height: 28,
                      margin: const EdgeInsets.only(left: Dimens.marginNormal),
                      child: IconButton(
                        onPressed: () => Navigator.pushNamed(context, AddLiquidFavoriteScreen.routeName, arguments: []),
                        icon: const Icon(
                          Icons.add_circle_outline_sharp,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              body: SizedBox(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(Dimens.marginNormal),
                      child: Text(mealTime.name),
                    ),
                    ...bloc.getFavorites(bloc.getMealTimeById(mealTime.id!)).map((favorite) => EventListItem(
                      title: favorite.title,
                      onEdit: () {},
                      onFavorite: (index) => showUndoFavoriteDialog(
                        context: context,
                        liquidTitle: favorite.title,
                        onUndoFavorite: () => bloc.add(
                          RemoveFavoriteAction(
                            liquidFavorite: favorite,
                            onFinish: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),).toList()
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