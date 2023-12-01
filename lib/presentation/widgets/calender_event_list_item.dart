import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class CalenderEventListItem extends StatelessWidget {
  final String title;
  final Function onEdit;
  final Function onDelete;

  const CalenderEventListItem({
    Key? key,
    required this.title,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginLarge, vertical: Dimens.marginSmall),
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.black12, width: 1), borderRadius: BorderRadius.circular(8)),
      elevation: 5,
      child: Container(
        margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginNormal, bottom: Dimens.marginLarge),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                onPressed: () => onDelete.call(),
                icon: const Icon(Icons.delete,),
              ),
            ),
          ],
        ),
      ),
    );
  }

}