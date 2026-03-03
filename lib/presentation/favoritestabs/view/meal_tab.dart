import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/updatemeal/view/update_meal_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_info_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../widgets/remove_item_widget.dart';
import '../bloc/favorites_tabs_bloc.dart';

class MealTab extends StatefulWidget {
  const MealTab({super.key});

  @override
  State<MealTab> createState() => _MealTabState();
}

class _MealTabState extends State<MealTab> {
  late FavoritesTabsBloc favoritesTabsBloc;

  @override
  void initState() {
    favoritesTabsBloc = BlocProvider.of<FavoritesTabsBloc>(context);
    super.initState();
  }


  // TODO: Remove Item from db
  void _showRemoveDialog({required String description, required VoidCallback onCancel, required VoidCallback onConfirm}) {
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) => RemoveItemWidget(
        description: description,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: favoritesTabsBloc,
      child: BlocConsumer<FavoritesTabsBloc, FavoritesTabsState>(
        listener: (context, state) {},
        builder: (context, state) => ListView.builder(
        itemCount: state.favFoods?.length ?? 0,
          itemBuilder: (context, index) {
          final favFood = state.favFoods.orEmpty()[index];
          final itemName = favFood.title ?? NutritionUtils.findFoodsName(foodNames: state.foodNames?.foodsAndDrinksNames?.foodNames, ingredients: favFood.ingredients, context: context);
            return ItemInfoCard(
              onItemTap: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: favFood),
              title: itemName,
              leadingIcon: Icons.star_rounded,
              leadingIconSize: Dimens.height27,
              leadingIconColor: AppColors.yellowishGreen,
              trailingSrc: 'assets/images/delete_icon.png',
              color: AppColors.floralWhite,
              leadingTap: () {},
              trailingTap: () => _showRemoveDialog(
                description: AppLocalizations.of(context)!.remove_item(itemName),
                onCancel: () => Navigator.pop(context),
                onConfirm: () => favoritesTabsBloc.add(RemoveFavoriteFoodFavoritesTabsEvent(foodFavorite: favFood)),
              ),
              subtitle: favFood.ingredients.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.amount}: ${favFood.ingredients[0].qty} ${NutritionUtils.findUnitNameFavFood(state.unitsInfoMaster?.unitsInfoMaster, favFood.ingredients, context)}.',
              beforeTrailingSrc: 'assets/icon/edit_icon.png',
              beforeTrailingTap: () => Navigator.pushNamed(context, UpdateMealScreen.routeName, arguments: favFood).then((value) => favoritesTabsBloc.add(InitializeFavoritesTabsEvent())),
            );
          },
        ),
      ),
    );
  }
}