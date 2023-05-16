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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                title,
                overflow: TextOverflow.clip,
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => onEdit.call(),
                icon: const Icon(Icons.edit),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => onFavorite.call(),
                icon: const Icon(Icons.favorite, color: Colors.red,),
              ),
            ),
          ],
        ),
      ),
    );
  }

}