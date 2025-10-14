import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/item_info_card.dart';
import '../../widgets/remove_item_widget.dart';
import '../bloc/routines_tab_bloc.dart';

class MealRoutinesTab extends StatefulWidget {
  const MealRoutinesTab({super.key});

  @override
  State<MealRoutinesTab> createState() => _MealRoutinesTabState();
}

class _MealRoutinesTabState extends State<MealRoutinesTab> {
  late RoutinesTabBloc routinesTabsBloc;

  @override
  void initState() {
    routinesTabsBloc = BlocProvider.of<RoutinesTabBloc>(context);
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
      value: routinesTabsBloc,
      child: BlocConsumer<RoutinesTabBloc, RoutinesTabState>(
        listener: (ctx, state) {},
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.mealRoutines.orEmpty().length,
            itemBuilder: (context, index) {
              final item = state.mealRoutines.orEmpty()[index];
              final itemName = NutritionUtils.findFoodsName(foodNames: state.foodNames?.foodsAndDrinksNames?.foodNames, ingredients: item.ingredients, context: context);
              return ItemInfoCard(
                onItemTap: () => Navigator.pushNamed(context, AddFoodEventScreen.routeName, arguments: item).then((value) => routinesTabsBloc.add(InitializeRoutinesTabEvent())),
                title: itemName,
                leadingSrc: 'assets/icon/routine_icon.png',
                leadingIconSize: Dimens.height27,
                trailingSrc: 'assets/images/delete_icon.png',
                color: AppColors.floralWhite,
                leadingTap: () {},
                trailingTap: () => _showRemoveDialog(
                  description: AppLocalizations.of(context)!.remove_item(itemName),
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () => routinesTabsBloc.add(DeleteFoodRoutineActionRoutinesTabEvent(foodRoutineEvent: item)),
                ),
                subtitle: '${item.ingredients![0].qty} ${NutritionUtils.unitOfFoods(state.unitsInfoMaster?.unitsInfoMaster, item.ingredients.orEmpty(), context)}.',);
            },
          );
        },
      ),
    );
  }
}