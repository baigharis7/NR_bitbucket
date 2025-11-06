import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/sportevent/view/add_sport_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/supplements/view/supplements_screen.dart';
import 'package:nutrenaissance_flutter/presentation/updatesupplement/view/update_supplement_screen.dart';

import '../../../infrastructure/utils/app_color.dart';
import '../../../infrastructure/utils/nutrition_utils.dart';
import '../../common/view/confirmation_dialog.dart';
import '../../widgets/item_info_card.dart';
import '../../widgets/remove_item_widget.dart';
import '../bloc/favorites_tabs_bloc.dart';

class SupplementsTab extends StatefulWidget {
  const SupplementsTab({super.key});

  @override
  State<SupplementsTab> createState() => _SupplementsTabState();
}

class _SupplementsTabState extends State<SupplementsTab> {
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
          shrinkWrap: true,
          primary: false,
          itemCount: state.favSupplements?.length ?? 0,
          itemBuilder: (context, index) {
            final supplementFavorite = state.favSupplements.orEmpty()[index];
            final itemName = supplementFavorite.name ?? NutritionUtils.findSupplementById(state.supplementsInfo?.data ?? [], supplementFavorite.info![0].id ?? -1).translate(context);
            return ItemInfoCard(
              title: itemName,
              trailingSrc: 'assets/images/delete_icon.png',
              trailingTap: () => _showRemoveDialog(
                  description: AppLocalizations.of(context)!.remove_item(itemName),
                  onCancel: () => Navigator.pop(context),
                  onConfirm: () => favoritesTabsBloc.add(DeleteSupplementFavoriteFavoritesTabsEvent(supplementSimple: supplementFavorite)),
              ),
              subtitle: supplementFavorite.info.orEmpty().length > 1 ? AppLocalizations.of(context)!.combo.toUpperCase() : '${AppLocalizations.of(context)!.amount}: ${supplementFavorite.info![0].amount.toString()} ${supplementFavorite.info![0].unit}.',
              leadingSrc: 'assets/images/favorite_icon.png',
              leadingTap: () {},
              beforeTrailingSrc: 'assets/icon/edit_icon.png',
              beforeTrailingTap: () => Navigator.pushNamed(context, UpdateSupplementScreen.routeName, arguments: supplementFavorite).then((value) => favoritesTabsBloc.add(InitializeFavoritesTabsEvent())),
            );
          },
        ),
      ),
    );
  }
}