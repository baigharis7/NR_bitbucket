import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class EventListItem extends StatelessWidget {
  final String title;
  final Function onEdit;
  final Function onFavorite;

  const EventListItem({
    Key? key,
    required this.title,
    required this.onEdit,
    required this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: Dimens.marginSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(width: Dimens.marginSmall),
            IconButton(
              onPressed: () => onEdit.call(),
              iconSize: 28,
              icon: const Icon(Icons.edit),
            ),
            const SizedBox(width: Dimens.marginSmall),
            IconButton(
              onPressed: () => onFavorite.call(),
              iconSize: 28,
              icon: const Icon(Icons.favorite, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

}