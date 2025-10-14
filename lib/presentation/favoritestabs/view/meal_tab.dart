import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/item_info_card.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
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


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: favoritesTabsBloc,
      child: BlocConsumer<FavoritesTabsBloc, FavoritesTabsState>(
        listener: (context, state) {},
        builder: (context, state) => Column(
      children: [
        ...state.favFoods.orEmpty().map((favFood) => ItemInfoCard(
          onItemTap: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: favFood),
          title: NutritionUtils.findFoodsName(foodNames: state.foodNames?.foodsAndDrinksNames?.foodNames, ingredients: favFood.ingredients, context: context),
          leadingSrc: 'assets/images/favorite_icon.png',
          trailingSrc: 'assets/images/delete_icon.png',
          color: AppColors.floralWhite,
          leadingTap: () {},
          trailingTap: () { favoritesTabsBloc.add(RemoveFavoriteFoodFavoritesTabsEvent(foodFavorite: favFood)); },
          subtitle: '${favFood.ingredients[0].qty} ${NutritionUtils.findUnitNameFavFood(state.unitsInfoMaster?.unitsInfoMaster, [favFood.ingredients[0]], context)}.',),
        ),
      ],
        ),
      ),
    );
  }
}