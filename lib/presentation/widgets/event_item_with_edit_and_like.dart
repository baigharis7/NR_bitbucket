import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class EventItemWithEditAndLike extends StatelessWidget {
  final String name;
  final bool isFavorite;
  final Function onFavorite;
  final Function onEdit;
  final Function onDelete;
  final bool? isCentered;

  const EventItemWithEditAndLike({
    Key? key,
    required this.name,
    required this.isFavorite,
    required this.onFavorite,
    required this.onEdit,
    required this.onDelete,
    this.isCentered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () { onEdit.call(); },
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.symmetric(vertical: Dimens.marginSmall, horizontal: Dimens.marginNormal),
                    child: Text(name, overflow: TextOverflow.clip,),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () => onFavorite.call(),
                    icon: isFavorite ? const Icon(Icons.favorite, color: Colors.red,) : const Icon(Icons.favorite_border, color: Colors.red,),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => onDelete.call(),
                    icon: const Icon(Icons.delete),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}