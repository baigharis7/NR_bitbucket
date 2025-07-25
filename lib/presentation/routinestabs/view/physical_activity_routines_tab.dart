import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';

import '../../../infrastructure/errors/error_resolver.dart';
import '../../../infrastructure/helpers/app_text_styles.dart';
import '../../../infrastructure/helpers/snack_bar_helper.dart';
import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/dimens.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../common/view/loading_screen.dart';
import '../../widgets/item_info_card.dart';
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
              return ItemInfoCard(
                onItemTap: () => Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: item).then((value) => routinesTabsBloc.add(InitializeRoutinesTabEvent())),
                title: NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: item.info, context: context),
                leadingSrc: 'assets/icon/routine_icon.png',
                leadingIconSize: Dimens.height27,
                trailingSrc: 'assets/images/delete_icon.png',
                color: AppColors.floralWhite,
                leadingTap: () {},
                trailingTap: () => routinesTabsBloc.add(DeleteSportRoutineAction(sportRoutineCompleted: item)),
                subtitle: '--- ---- ---',);
            },
          );
        },
      ),
    );
  }
}