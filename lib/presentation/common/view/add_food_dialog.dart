import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class AddFoodDialog extends StatelessWidget {
  final Widget widget;
  final String foodName;

  const AddFoodDialog({
    Key? key,
    required this.widget,
    required this.foodName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 8,
              child: Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: Dimens.marginNormal),
                child: Text(
                  foodName,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
      children: [
        // Aquí había un SizedBox
        widget
      ],
    );
  }
  
}