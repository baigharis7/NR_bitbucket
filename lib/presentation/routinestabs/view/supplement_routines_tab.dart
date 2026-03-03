import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/updatesupplement/view/update_supplement_screen.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../widgets/item_info_card.dart';
import '../../widgets/remove_item_widget.dart';
import '../bloc/routines_tab_bloc.dart';

class SupplementRoutinesTab extends StatelessWidget {

  const SupplementRoutinesTab({super.key});
  @override
  Widget build(BuildContext context) {
    RoutinesTabBloc routinesTabsBloc = BlocProvider.of<RoutinesTabBloc>(context);


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

    return BlocProvider.value(
      value: routinesTabsBloc,
      child: BlocConsumer<RoutinesTabBloc, RoutinesTabState>(
        listener: (ctx, state) {},
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.supplementRoutines.orEmpty().length,
            itemBuilder: (context, index) {
              final supplementRoutine = state.supplementRoutines.orEmpty()[index];
              final itemName = supplementRoutine.name ?? NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], supplementRoutine.info![0].id ?? -1).translate(context);
              return ItemInfoCard(
                onItemTap: () {},
                title: itemName,
                leadingIcon: Icons.history,
                leadingIconSize: Dimens.height27,
                trailingSrc: 'assets/images/delete_icon.png',
                color: AppColors.floralWhite,
                leadingTap: () {},
                trailingTap: () => _showRemoveDialog(
                    description: AppLocalizations.of(context)!.remove_item(itemName),
                    onCancel: () => Navigator.pop(context),
                    onConfirm: () => routinesTabsBloc.add(DeleteSupplementRoutineRoutinesTabEvent(supplement: supplementRoutine)),
                ),
                subtitle: supplementRoutine.info.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.amount}: ${supplementRoutine.info![0].amount.toString()} ${supplementRoutine.info![0].unit}.',
                beforeTrailingSrc: 'assets/icon/edit_icon.png',
                beforeTrailingTap: () => Navigator.pushNamed(context, UpdateSupplementScreen.routeName, arguments: supplementRoutine).then((value) => routinesTabsBloc.add(InitializeRoutinesTabEvent())),
              );
            },
          );
        },
      ),
    );
  }

}