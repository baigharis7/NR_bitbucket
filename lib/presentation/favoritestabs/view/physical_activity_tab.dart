import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/updatesport/view/update_sport_screen.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../common/view/confirmation_dialog.dart';
import '../../widgets/item_info_card.dart';
import '../../widgets/remove_item_widget.dart';
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
          itemCount: state.favSports?.length ?? 0,
          itemBuilder: (context, index) {
            final favSport = state.favSports.orEmpty()[index];
            final itemName = favSport.title ?? NutritionUtils.findSportName(names: state.sportsInfo?.sportsInfoMaster, ingredients: favSport.info, context: context);
            return ItemInfoCard(
              onItemTap: () => Navigator.pushNamed(context, AddSportEventScreen.routeName, arguments: favSport),
              title: itemName,
              leadingSrc: 'assets/images/favorite_icon.png',
              // leadingSrc: 'assets/images/sport.png',
              trailingSrc: 'assets/images/delete_icon.png',
              color: AppColors.floralWhite,
              leadingTap: () {},
              trailingTap: () => _showRemoveDialog(
                  description: AppLocalizations.of(context)!.remove_item(itemName),
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () => favoritesTabsBloc.add(DeleteFavoriteSportFavoritesTabsEvent(sportFavorite: favSport,)),
              ),
              subtitle: favSport.info.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.duration}: ${favSport.info![0].minutes} min. - ${AppLocalizations.of(context)!.intensity}: ${NutritionUtils.activityIntensityById(favSport.info![0].intensity.orZero(), context)}.',
              beforeTrailingSrc: 'assets/icon/edit_icon.png',
              beforeTrailingTap: () => Navigator.pushNamed(context, UpdateSportScreen.routeName, arguments: favSport).then((value) => favoritesTabsBloc.add(InitializeFavoritesTabsEvent())),
            );
          },
        ),
      ),
    );
  }
}