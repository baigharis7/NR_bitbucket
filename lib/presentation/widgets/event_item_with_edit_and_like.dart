import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class EventItemWithEditAndLike extends StatelessWidget {
  final String name;
  final bool isFavorite;
  final Function onFavorite;
  final Function onEdit;
  final Function onDetail;
  final Function onDelete;
  final bool? isCentered;
  final IconData? leadingIcon;
  final Color? leadingIconColor;

  const EventItemWithEditAndLike({
    Key? key,
    required this.name,
    required this.isFavorite,
    required this.onFavorite,
    required this.onEdit,
    required this.onDetail,
    required this.onDelete,
    this.isCentered,
    this.leadingIcon,
    this.leadingIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () { onDetail.call(); },
      child: Card(
        margin: const EdgeInsets.only(top: Dimens.marginSmall),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginSmall),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 22, color: leadingIconColor),
                const SizedBox(width: Dimens.marginSmall),
              ],
              Expanded(
                child: Text(name, overflow: TextOverflow.clip),
              ),
              const SizedBox(width: Dimens.marginSmall),
              IconButton(
                onPressed: () => onEdit.call(),
                iconSize: 26,
                icon: const Icon(Icons.edit),
              ),
              const SizedBox(width: Dimens.marginSmall),
              IconButton(
                onPressed: () => onFavorite.call(),
                iconSize: 26,
                icon: isFavorite ? const Icon(Icons.favorite, color: Colors.red) : const Icon(Icons.favorite_border, color: Colors.red),
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
      ),
    );
  }

}