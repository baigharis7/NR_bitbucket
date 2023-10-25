import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/events_helper.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/toast_helper.dart';
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

    showDialog(context: context, builder: (ctx) => Container(
      height: mediaQuerySize.height,
      width: mediaQuerySize.width,
      color: const Color.fromARGB(148, 104, 96, 96),
      child: ConfirmationDialog(message: AppLocalizations.of(context)!.favorite_saved),
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
        onNameChange: (String foodName) => onNameChange.call(foodName),
        onMealTimeChange: (int mealTime) => onMealTimeChange.call(mealTime),
        onFinish: () => onFinish.call(),
        onPop: () => Navigator.pop(context),
      ),
    ).then((_) => Navigator.pop(context));
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
      if (arguments is List<FoodInFavorite>) {
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
            if (state.onError != null) showErrorSnackBar(context, resolveError(ctx, state.onError!));
          },
          builder: (ctx, state) {
            return Scaffold(
              body: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: Dimens.marginXLarge),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, size: 24)),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  state.foodsInFavorite!.map((favorite) => favorite.translate(ctx)).join(', '),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: Dimens.fontSizeLarge,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Image.asset('assets/icon/fork_knife.png', width: 24, height: 31,),
                              )
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: Colors.grey[300]!, width: 1.0),
                          ),
                          padding: const EdgeInsets.all(Dimens.paddingNormal),
                          margin: const EdgeInsets.all(Dimens.marginNormal),
                          child: Column(
                            children: [
                              ...state.foodsInFavorite!.map((foodInFavorite) => FoodCard(
                                foodName: eventHelper.findFoodNameFromId(foodInFavorite.id, context, state.foodNames!.foodsAndDrinksNames!.foodNames!),
                                cookingMethod: eventHelper.findCookingMethodName(
                                  ctx,
                                  foodInFavorite.id,
                                  state.cookingMethodsInfoMaster!.cookingMethodsInfo!,
                                ),
                                quantity: foodInFavorite.qty.toString(),
                                unit: eventHelper.findUnitName(foodInFavorite.unit, state.unitsInfoMaster!.unitsInfoMaster).translate(context),
                                removeFood: () {
                                  return AlertDialog(
                                    title: Text('Are you sure want to delete this food ?'),
                                    actions: [
                                      TextButton(onPressed: () {ToastHelper().showToast(text: 'Yes');}, child: Text('Yes')),
                                      TextButton(onPressed: () {ToastHelper().showToast(text: 'No');}, child: Text('No')),
                                    ],
                                  );
                                },
                                editFood: () {},
                              ),),
                              SizedBox(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.yellow[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(Dimens.marginNormal),
                                  child: InkWell(
                                    child: Container(
                                      margin: const EdgeInsets.all(Dimens.marginNormal),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(AppLocalizations.of(context)!.add_comment),
                                          const Icon(Icons.mode_comment_outlined)
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
                                        const Icon(Icons.mode_comment),
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
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(Dimens.marginNormal),
                                  child: Container(
                                    margin: const EdgeInsets.all(Dimens.marginNormal),
                                    child: InkWell(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(AppLocalizations.of(context)!.add_favorite),
                                          const Icon(Icons.favorite_border)
                                        ],
                                      ),
                                      onTap: () {
                                        showAddFavoriteDialog(
                                          context: ctx,
                                          onNameChange: (String foodName) => bloc.add(AddFoodNameAction(name: foodName)),
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
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.paddingXLarge, vertical: Dimens.paddingLarge),
                    decoration: BoxDecoration(borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(5.0)),color: Colors.white,boxShadow: [BoxShadow(blurRadius: 5.0)]),
                    child: Column(children: [
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.all(Dimens.marginSmall),
                          padding: EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingSmall),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.yellow[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.add_food),
                              const Icon(Icons.add_circle)
                            ],
                          ),
                        ),
                        onTap: () {},
                      ),
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.all(Dimens.marginSmall),
                          padding: EdgeInsets.symmetric(horizontal: Dimens.paddingLarge, vertical: Dimens.paddingSmall),
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
                          onAddComment: (String comment) => bloc.add(AddCommentToFavoriteActions(
                            comment: comment,
                            onFinish: () => Navigator.pop(context),
                          ),),
                        ),
                      ),
                    ]),)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}