import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../common/view/confirmation_dialog.dart';
import '../../widgets/item_info_card.dart';
import '../bloc/favorites_tabs_bloc.dart';

class PhysicalActivityTab extends StatefulWidget {
  const PhysicalActivityTab({super.key});

  @override
  State<PhysicalActivityTab> createState() => _PhysicalActivityTabState();
}

class _PhysicalActivityTabState extends State<PhysicalActivityTab> {
  late FavoritesTabsBloc favoritesTabsBloc;

  @override
  void initState() {
    favoritesTabsBloc = BlocProvider.of<FavoritesTabsBloc>(context);
    super.initState();
  }

  void _showConfirmationDialog({required BuildContext context}) {
    Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    final mediaQuerySize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (ctx) => Container(
        height: mediaQuerySize.height,
        width: mediaQuerySize.width,
        color: const Color.fromARGB(148, 104, 96, 96),
        child: ConfirmationDialog(
          message: AppLocalizations.of(context)!.sport_event_successfully_saved,
        ),
      ),
    ).then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: favoritesTabsBloc,
      child: BlocConsumer<FavoritesTabsBloc, FavoritesTabsState>(
        listener: (context, state) {},
        builder: (context, state) => Column(
          children: [
            ...state.favSports.orEmpty().map((favSport) => ItemInfoCard(
              onItemTap: () => Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: favSport),
              title: NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: favSport.info, context: context),
              leadingSrc: 'assets/images/favorite_icon.png',
              // leadingSrc: 'assets/images/sport.png',
              trailingSrc: 'assets/images/delete_icon.png',
              color: AppColors.floralWhite,
              leadingTap: () {},
              trailingTap: () => favoritesTabsBloc.add(DeleteFavoriteSportFavoritesTabsEvent(sportFavorite: favSport, onFinish: () => _showConfirmationDialog(context: context))),
              subtitle: '--- ---- ---',),
            ),
          ],
        ),
      ),
    );
  }
}