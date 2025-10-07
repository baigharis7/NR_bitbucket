import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../widgets/item_info_card.dart';
import '../bloc/routines_tab_bloc.dart';

class SupplementRoutinesTab extends StatelessWidget {

  const SupplementRoutinesTab({super.key});
  @override
  Widget build(BuildContext context) {
    RoutinesTabBloc routinesTabsBloc = BlocProvider.of<RoutinesTabBloc>(context);

    return BlocProvider.value(
      value: routinesTabsBloc,
      child: BlocConsumer<RoutinesTabBloc, RoutinesTabState>(
        listener: (ctx, state) {},
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.supplementRoutines.orEmpty().length,
            itemBuilder: (context, index) {
              final supplementRoutine = state.supplementRoutines.orEmpty()[index];
              return ItemInfoCard(
                onItemTap: () {},
                title: NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], supplementRoutine.info![0].id ?? -1).translate(context),
                leadingSrc: 'assets/icon/routine_icon.png',
                leadingIconSize: Dimens.height27,
                trailingSrc: 'assets/images/delete_icon.png',
                color: AppColors.floralWhite,
                leadingTap: () {},
                trailingTap: () => routinesTabsBloc.add(DeleteSupplementRoutineRoutinesTabEvent(supplement: supplementRoutine)),
                subtitle: '${supplementRoutine.info![0].amount.toString()} ${supplementRoutine.info![0].unit}',);
            },
          );
        },
      ),
    );
  }

}