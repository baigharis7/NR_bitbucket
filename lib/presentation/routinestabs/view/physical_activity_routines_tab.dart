import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/updatesport/view/update_sport_screen.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../widgets/item_info_card.dart';
import '../../widgets/remove_item_widget.dart';
import '../bloc/routines_tab_bloc.dart';

class PhysicalActivityRoutinesTab extends StatefulWidget {
  const PhysicalActivityRoutinesTab({super.key});

  @override
  State<PhysicalActivityRoutinesTab> createState() => _PhysicalActivityRoutinesTabState();
}

class _PhysicalActivityRoutinesTabState extends State<PhysicalActivityRoutinesTab> {
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
            itemCount: state.sportRoutines.orEmpty().length,
            itemBuilder: (context, index) {
              final item = state.sportRoutines.orEmpty()[index];
              final itemName = item.sportName ?? NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: item.info, context: context);
              return ItemInfoCard(
                onItemTap: () => Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: item).then((value) => routinesTabsBloc.add(InitializeRoutinesTabEvent())),
                title: itemName,
                leadingIcon: Icons.history,
                leadingIconSize: Dimens.height27,
                trailingSrc: 'assets/images/delete_icon.png',
                color: AppColors.floralWhite,
                leadingTap: () {},
                trailingTap: () => _showRemoveDialog(
                    description: AppLocalizations.of(context)!.remove_item(itemName),
                    onCancel: () => Navigator.pop(context),
                    onConfirm: () => routinesTabsBloc.add(DeleteSportRoutineAction(sportRoutineCompleted: item)),
                ),
                subtitle: item.info.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.duration}: ${item.info![0].minutes} min. - ${AppLocalizations.of(context)!.intensity}: ${NutritionUtils.activityIntensityById(item.info![0].intensity?.toInt() ?? 0, context)}.',
                beforeTrailingSrc: 'assets/icon/edit_icon.png',
                beforeTrailingTap: () => Navigator.pushNamed(context, UpdateSportScreen.routeName, arguments: mapToSportFavoriteFromRoutine(item)).then((value) => routinesTabsBloc.add(InitializeRoutinesTabEvent())),
              );
            },
          );
        },
      ),
    );
  }
}