import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/add_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/undo_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_bottom_navi_bar_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_list_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

class FavoriteFoodsClusterScreen extends StatelessWidget {
  static const routeName = '/favorite_foods_cluster';

  const FavoriteFoodsClusterScreen({
    Key? key,
  }) : super(key: key);

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
    final bloc = BlocProvider.of<FavoriteFoodsBloc>(context);
    var mealTime = assignMealTimeType(ModalRoute.of(context)!.settings.arguments);

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<FavoriteFoodsBloc, FavoriteFoodsState>(
          listener: (ctx, state) {},
          builder: (ctx, state) {
            return Scaffold(
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleSpacing: Dimens.marginNormal,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: Dimens.marginNormal),
                      child: Text(
                        AppLocalizations.of(context)!.food_favs,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: Dimens.fontSizeLarge,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, AddFoodFavoriteScreen.routeName, arguments: []),
                      icon: const Icon(
                        Icons.add_circle,
                        size: 28,
                        color: Colors.teal,
                      ),
                    )
                  ],
                ),
              ),
              body: SizedBox(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${mealTime.name}s',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...bloc.getFavorites(bloc.getMealTimeById(mealTime.id!)).map((favorite) => EventListItem(
                          title: favorite.title.orEmpty(),
                          onEdit: () => Navigator.pushNamed(context, AddFoodFavoriteScreen.routeName, arguments: favorite).then((value) => bloc.add(InitializeState())),
                          onFavorite: () => showUndoFavoriteDialog(
                            context: context,
                            foodTitle: favorite.title.orEmpty(),
                            onUndoFavorite: () => bloc.add(
                              RemoveFavoriteAction(
                                foodFavorite: favorite,
                                onFinish: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                        ),).toList()
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}