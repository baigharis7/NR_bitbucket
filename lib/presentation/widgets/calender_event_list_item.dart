import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class CalenderEventListItem extends StatelessWidget {
  final String title;
  final Function onEdit;
  final Function onDelete;
  final Function? onHeartClick;
  final bool isFavourite;

  const CalenderEventListItem({
    Key? key,
    required this.title,
    required this.onEdit,
    required this.onDelete,
    this.onHeartClick,
    this.isFavourite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: Dimens.marginSmall, left: Dimens.marginLarge, right: Dimens.marginLarge),
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.black12, width: 1), borderRadius: BorderRadius.circular(8)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Dimens.marginSmall),
            if (onHeartClick != null) ...[
              IconButton(
                onPressed: () => onHeartClick?.call(),
                iconSize: 26,
                icon: Icon(isFavourite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
              ),
              const SizedBox(width: Dimens.marginSmall),
            ],
            IconButton(
              onPressed: () => onEdit.call(),
              iconSize: 26,
              icon: const Icon(Icons.edit),
            ),
            const SizedBox(width: Dimens.marginSmall),
            IconButton(
              onPressed: () => onDelete.call(),
              iconSize: 26,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }

}