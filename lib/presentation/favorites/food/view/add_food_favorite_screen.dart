import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_comment_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_state.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_card.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

import '../../../foodevent/view/add_food_event_screen.dart';
import '../../common/undo_favorite_dialog.dart';

class AddFoodFavoriteScreen extends StatefulWidget {
  static const routeName = '/add_food_favorite';

  const AddFoodFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFoodFavoriteScreenState();
}

class _AddFoodFavoriteScreenState extends State<AddFoodFavoriteScreen> {
  void _showConfirmationDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (ctx) => Container(
        height: mediaQuerySize.height,
        width: mediaQuerySize.width,
        color: const Color.fromARGB(148, 104, 96, 96),
        child: ConfirmationDialog(
            message: AppLocalizations.of(context)!.favorite_saved),
      ),
    ).then(
      (value) => Navigator.pop(context),
    );
  }

  Future<void> showAddCommentDialog({
    required BuildContext context,
    required Function onAddComment,
    required Function onSaveComment,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddCommentDialog(
        onEdit: (String comment) => onAddComment.call(comment),
        onSaveClick: () => onSaveComment.call(),
      ),
    ).then((value) => Navigator.pop(context));
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
        onNameChange: (String foodName) => onNameChange.call(foodName),
        onMealTimeChange: (int mealTime) => onMealTimeChange.call(mealTime),
        onFinish: () => onFinish.call(),
        onPop: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
  }

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

  @override
  void initState() {
    final bloc = BlocProvider.of<AddFavoriteFoodBloc>(context);
    bloc.add(InitializeStateAction());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AddFavoriteFoodBloc>(context);
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments != null) {
      if (arguments is FoodEventComplete) {
        bloc.add(SetFoodsInFavoriteAction(foodsInFavorite: arguments));
      } else if (arguments is FoodFavorite) {
        bloc.add(SetFoodFavoriteToEditAction(foodFavorite: arguments));
      }
    }
    final eventHelper = EventsHelper();

    return BlocProvider.value(
      value: bloc,
      child: SafeArea(
        child: BlocConsumer<AddFavoriteFoodBloc, AddFavoriteFoodState>(
          listener: (ctx, state) {
            if (state.isLoading) {
              LoadingScreen.instance().show(
                context: ctx,
                text: AppLocalizations.of(ctx)!.loading,
              );
            } else {
              LoadingScreen.instance().hide();
            }
            if (state.onError != null)
              showErrorSnackBar(context, resolveError(ctx, state.onError!));
          },
          builder: (ctx, state) {
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin:
                              const EdgeInsets.only(top: Dimens.marginXLarge),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back_ios,
                                        size: 24)),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  state.foodsInFavorite!
                                      .map(
                                          (favorite) => favorite.translate(ctx))
                                      .join(', '),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: Dimens.fontSizeLarge,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: () {
                                    if (arguments is FoodFavorite) {
                                      showUndoFavoriteDialog(
                                        context: context,
                                        foodTitle: arguments.title,
                                        onUndoFavorite: () => bloc.add(
                                          RemoveFavoriteFoodEventAction(
                                            onFinish: () =>
                                                Navigator.pop(context),
                                            foodFavorite: arguments,
                                          ),
                                        ),
                                      );
                                    } else if (arguments is FoodEventComplete
                                        ? !bloc.isFoodFavourite(arguments)
                                        : false) {
                                      showAddFavoriteDialog(
                                        context: ctx,
                                        onNameChange: (String foodName) =>
                                            bloc.add(
                                          AddFoodNameAction(
                                            name: foodName,
                                          ),
                                        ),
                                        onMealTimeChange: (int mealTime) =>
                                            bloc.add(
                                          AddMealTimeAction(
                                            mealTime: mealTime,
                                          ),
                                        ),
                                        onFinish: () => bloc.add(
                                          FinishAddingFavoriteAction(
                                            onFinish: () =>
                                                _showConfirmationDialog(
                                              context,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  // (arguments is FoodFavorite || (arguments is FoodEventComplete ? !bloc.isFoodFavourite(arguments) : true)) ? () {
                                  //   showAddFavoriteDialog(
                                  //     context: ctx,
                                  //     onNameChange: (String foodName) => bloc.add(AddFoodNameAction(name: foodName)),
                                  //     onMealTimeChange: (int mealTime) => bloc.add(AddMealTimeAction(mealTime: mealTime)),
                                  //     onFinish: () => bloc.add(FinishAddingFavoriteAction(onFinish: () => _showConfirmationDialog(context))),
                                  //   );
                                  // } : () {}
                                  ,
                                  child: (arguments is FoodFavorite ||
                                          (arguments is FoodEventComplete
                                              ? bloc.isFoodFavourite(arguments)
                                              : true))
                                      ? const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        )
                                      : const Icon(
                                          Icons.favorite_border,
                                          color: Colors.red,
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              padding:
                                  const EdgeInsets.all(Dimens.paddingNormal),
                              margin: const EdgeInsets.all(Dimens.marginNormal),
                              child: Column(
                                children: [
                                  ...state.foodsInFavorite!.map(
                                    (foodInFavorite) => FoodCard(
                                      foodName: eventHelper.findFoodNameFromId(
                                          foodInFavorite.id,
                                          context,
                                          state.foodNames!.foodsAndDrinksNames!
                                              .foodNames!),
                                      cookingMethod:
                                          eventHelper.findCookingMethodName(
                                        ctx,
                                        foodInFavorite.cookingMethod,
                                        state.cookingMethodsInfoMaster!
                                            .cookingMethodsInfo!,
                                      ),
                                      quantity: foodInFavorite.qty.toString(),
                                      unit: eventHelper
                                          .findUnitName(
                                              foodInFavorite.unit,
                                              state.unitsInfoMaster!
                                                  .unitsInfoMaster)
                                          .translate(context),
                                      removeFood: () {},
                                      editFood: () {},
                                    ),
                                  ),
                                  if (state.comment.isNotEmptyOrNull())
                                    Container(
                                      margin: const EdgeInsets.all(
                                          Dimens.marginNormal),
                                      child: Card(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.all(
                                              Dimens.marginNormal),
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.all(
                                                    Dimens.marginNormal),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.paddingXLarge,
                        vertical: Dimens.paddingLarge),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadiusDirectional.vertical(
                            top: Radius.circular(5.0)),
                        color: Colors.white,
                        boxShadow: [BoxShadow(blurRadius: 5.0)]),
                    child: Column(children: [
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.all(Dimens.marginSmall),
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimens.paddingLarge,
                              vertical: Dimens.paddingSmall),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.yellow[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!
                                  .add_new_ingredient),
                              const Icon(Icons.add_circle)
                            ],
                          ),
                        ),
                        onTap: () {
                          // if (arguments is FoodEventComplete)
                          Navigator.pushNamed(
                                  context, AddFoodEventScreen.routeName,
                                  arguments: arguments)
                              .then((value) => Navigator.pop(context));
                        },
                      ),
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.all(Dimens.marginSmall),
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimens.paddingLarge,
                              vertical: Dimens.paddingSmall),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.yellow[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.add_comment),
                              const Icon(Icons.mode_comment_outlined)
                            ],
                          ),
                        ),
                        onTap: () => showAddCommentDialog(
                          context: ctx,
                          onAddComment: (String comment) => bloc.add(
                            AddCommentToFavoriteActions(
                              comment: comment,
                            ),
                          ),
                          onSaveComment: () => arguments is FoodEventComplete
                              ? bloc.add(
                                  FinishFoodCommentAction(
                                    foodEventComplete: arguments,
                                    onFinish: () =>
                                        _showConfirmationDialog(context),
                                  ),
                                )
                              : bloc.add(
                            FinishFoodFavoriteCommentAction(
                              foodFavorite: arguments as FoodFavorite,
                              onFinish: () =>
                                  _showConfirmationDialog(context),
                            ),
                          ),
                        ),
                      ),
                    ],),
                  )
                ,],
              ),
            );
          },
        ),
      ),
    );
  }
}
