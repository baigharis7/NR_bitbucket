import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/event_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FavoritesCluster extends StatelessWidget {
  final String clusterTitle;
  final List<String> items;
  final Function onEdit;
  final Function onFavorite;
  final Function onSeeMore;

  const FavoritesCluster({
    Key? key,
    required this.clusterTitle,
    required this.items,
    required this.onEdit,
    required this.onFavorite,
    required this.onSeeMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
            child: Text(
              clusterTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
              ),
            ),
          ),
          items.isNotEmpty
              ? Column(
                children: [
                  ...items.map((title) => EventListItem(
                    title: title,
                    onEdit: () => onEdit.call(items.indexOf(title)),
                    onFavorite: () => onFavorite.call(items.indexOf(title)),
                  ),).toList(),
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: Text(
                        AppLocalizations.of(context)!.see_more,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onPressed: () => onSeeMore.call(),
                    ),
                  ),
                ],
              )
              : Center(
                child: Text(AppLocalizations.of(context)!.no_food_favorites),
              )
        ],
      ),
    );
  }

}