import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/confirmation_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/common/view/loading_screen.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_comment_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/common/add_favorite_dialog.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/add_favorite_food_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/view/create_new_food_favorite_screen.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_card.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_resolver.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/snack_bar_helper.dart';

import '../../../foodevent/view/add_food_event_screen.dart';
import '../../../widgets/box_type_radio_text_widget.dart';
import '../../../widgets/custom_bottom_navi_bar_widget.dart';
import '../../common/undo_favorite_dialog.dart';

class AddFoodFavoriteScreen extends StatefulWidget {
  static const routeName = '/add_food_favorite';

  const AddFoodFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddFoodFavoriteScreenState();
}

class _AddFoodFavoriteScreenState extends State<AddFoodFavoriteScreen> {
  void _showConfirmationDialog(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () => Navigator.pop(context));

    showDialog(context: context, builder: (ctx) => ConfirmationDialog(
      message: AppLocalizations.of(context)!.favorite_saved,
      iconData: Icons.star_rounded,
      hint: AppLocalizations.of(context)!.confirmation_edit_hint_favorites,
    ),).then(
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
    super.initState();
    final bloc = BlocProvider.of<AddFavoriteFoodBloc>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bloc.add(InitializeStateAction());
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is FoodEventComplete) {
        bloc.add(SetFoodsInFavoriteAction(foodsInFavorite: arguments));
      } else if (arguments is FoodFavorite) {
        bloc.add(SetFoodFavoriteToEditAction(foodFavorite: arguments));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AddFavoriteFoodBloc>(context);
    final eventHelper = EventsHelper();
    final arguments = ModalRoute.of(context)?.settings.arguments;

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
              bottomNavigationBar: const CustomBottomNaviBarWidget(activePosition: Constants.DASHBOARD),
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
                                    // if (arguments is FoodFavorite) {
                                    //   showUndoFavoriteDialog(
                                    //     context: context,
                                    //     foodTitle: arguments.title,
                                    //     onUndoFavorite: () => bloc.add(
                                    //       RemoveFavoriteFoodEventAction(
                                    //         onFinish: () =>
                                    //             Navigator.pop(context),
                                    //         foodFavorite: arguments,
                                    //       ),
                                    //     ),
                                    //   );
                                    // } else if (arguments is FoodEventComplete) {
                                    //   if (bloc.isFoodFavourite(arguments)) {
                                    //     showUndoFavoriteDialog(
                                    //       context: context,
                                    //       foodTitle: (arguments).foodName ?? '',
                                    //       onUndoFavorite: () => bloc.add(
                                    //         RemoveFavoriteFoodEventAction(
                                    //           onFinish: () =>
                                    //               Navigator.pop(context),
                                    //           foodFavorite: bloc.isFoundObjectFromFavoriteList(mapToFoodFavoriteFromFoodEvent(arguments)),
                                    //         ),
                                    //       ),
                                    //     );
                                    //   }
                                    //   else {
                                    //     bloc.add(
                                    //         FinishAddingFavoriteAction(
                                    //           onFinish: () =>
                                    //               _showConfirmationDialog(
                                    //                 context,
                                    //               ),
                                    //         ),
                                    //       );
                                    //   }
                                    // }
                                  },
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
                                      conversionFactor: state.conversionFactors.isNull() || foodInFavorite.conversionFactor.isNull() ? null : state.conversionFactors!.data.firstWhere((factor) => factor.id == foodInFavorite.conversionFactor,),
                                      usedOil: state.oilTypes.isNull() || foodInFavorite.usedOil.isNull() ? null : state.oilTypes!.data.firstWhere((oil) => oil.id == foodInFavorite.usedOil,),
                                      unit: eventHelper
                                          .findUnitName(
                                              foodInFavorite.unit,
                                              state.unitsInfoMaster!
                                                  .unitsInfoMaster)
                                          .translate(context),
                                      removeFood: null,
                                      editFood: null,
                                    ),
                                  ),
                                  if (state.dish ?? false) Container(margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge), child: BoxTypeRadioTextWidget(onPressed: () => {}, isSelected: true, title: AppLocalizations.of(context)!.create_dish)),
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
                          if (arguments is FoodEventComplete) {
                            Navigator.pushNamed(
                                  context, AddFoodEventScreen.routeName,
                                      arguments: arguments)
                              .then((value) => Navigator.pop(context));
                          }
                          else if (arguments is FoodFavorite) {
                            Navigator.pushNamed(context, CreateNewFoodFavoriteScreen.routeName, arguments: arguments).then((value) => Navigator.pop(context));
                          }
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
