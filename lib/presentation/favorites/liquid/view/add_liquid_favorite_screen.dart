import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_comment_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/add_favorite_liquid_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/add_favorite_liquid_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/add_favorite_liquid_state.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_card.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

class AddLiquidFavoriteScreen extends StatefulWidget {
  static const routeName = '/add_liquid_favorite';

  const AddLiquidFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddLiquidFavoriteScreenState();
}

class _AddLiquidFavoriteScreenState extends State<AddLiquidFavoriteScreen> {

  void _showConfirmationDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: AppLocalizations.of(context)!.liquid_event_successfully_saved),
    ),).then((value) =>
        Navigator.pop(context),
    );
  }

  Future<void> showAddCommentDialog({
    required BuildContext context,
    required Function onAddComment,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddCommentDialog(
        onAddComment: (String comment) => onAddComment.call(comment),
        onPop: () => Navigator.pop(ctx),
      ),
    );
  }

  Future<void> showAddFavoriteDialog({
    required BuildContext context,
    required Function onFinish,
    required Function onNameChange,
    required Function onMealTimeChange,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddFavoriteDialog(
        onNameChange: (String liquidName) => onNameChange.call(liquidName),
        onMealTimeChange: (int mealTime) => onMealTimeChange.call(mealTime),
        onFinish: () => onFinish.call(),
        onPop: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AddFavoriteLiquidBloc>(context);
    final liquidsInFavorite = ModalRoute.of(context)!.settings.arguments as List<LiquidInFavorite>;
    final eventHelper = EventsHelper();
    bloc.add(InitializeStateAction());
    bloc.add(SetLiquidsInFavoriteAction(liquidsInFavorite: liquidsInFavorite));

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<AddFavoriteLiquidBloc, AddFavoriteLiquidState>(
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
          builder: (ctx, state) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                titleSpacing: Dimens.marginNormal,
                title: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.only(left: Dimens.marginNormal),
                        child: Text(
                          state.liquidsInFavorite!.map((favorite) => favorite.translate(ctx)).join(', '),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: Dimens.fontSizeLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    ...state.liquidsInFavorite!.map((liquidInFavorite) => FoodCard(
                      foodName: eventHelper.findFoodNameFromId(liquidInFavorite.id, context, state.liquidNames!.foodsAndDrinksNames!.drinkNames!),
                      cookingMethod: eventHelper.findCookingMethodName(
                        ctx,
                        liquidInFavorite.id,
                        state.cookingMethodsInfoMaster!.cookingMethodsInfo!,
                      ),
                      quantity: liquidInFavorite.qty.toString(),
                      unit: eventHelper.findUnitName(liquidInFavorite.unit, state.unitsInfoMaster!.unitsInfoMaster).translate(context),
                      removeFood: () {},
                      editFood: () {},
                    ),),
                    SizedBox(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.yellow[200],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        margin: const EdgeInsets.all(Dimens.marginNormal),
                        child: InkWell(
                          child: Container(
                            margin: const EdgeInsets.all(Dimens.marginNormal),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(AppLocalizations.of(context)!.add_comment),
                                const Icon(Icons.comment_outlined)
                              ],
                            ),
                          ),
                          onTap: () => showAddCommentDialog(
                            context: ctx,
                            onAddComment: (String comment) => bloc.add(AddCommentToFavoriteActions(
                              comment: comment,
                              onFinish: () => Navigator.pop(context),
                            ),),
                          ),
                        ),
                      ),
                    ),
                    if (state.comment.isNotEmptyOrNull()) Container(
                      margin: const EdgeInsets.all(Dimens.marginNormal),
                      child: Card(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.all(Dimens.marginNormal),
                            child: Row(
                              children: [
                                const Icon(Icons.mode_comment_rounded),
                                Container(
                                  margin: const EdgeInsets.only(left: Dimens.marginNormal),
                                  child: Text(
                                    state.comment.orEmpty(),
                                    style: const TextStyle(
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                    ),
                    SizedBox(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.pink[200],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        margin: const EdgeInsets.all(Dimens.marginNormal),
                        child: Container(
                          margin: const EdgeInsets.all(Dimens.marginNormal),
                          child: InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(AppLocalizations.of(context)!.add_favorite),
                                const Icon(Icons.favorite)
                              ],
                            ),
                            onTap: () {
                              showAddFavoriteDialog(
                                context: ctx,
                                onNameChange: (String liquidName) => bloc.add(AddLiquidNameAction(name: liquidName)),
                                onMealTimeChange: (int mealTime) => bloc.add(AddMealTimeAction(mealTime: mealTime)),
                                onFinish: () => bloc.add(FinishAddingFavoriteAction(onFinish: () => _showConfirmationDialog(context))),
                              );
                            },
                          ),
                        ),
                      ),
                    )
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