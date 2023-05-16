import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class ProfileOptionWithGraphicAndAdd extends StatelessWidget {
  final String title;
  final Widget widget;
  final Function onAdd;

  const ProfileOptionWithGraphicAndAdd({
    Key? key,
    required this.title,
    required this.widget,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimens.marginNormal),
      child: Card(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title),
                  IconButton(
                    onPressed: () => onAdd.call(),
                    icon: const Icon(
                      Icons.add_circle_outline_sharp,
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(Dimens.marginNormal),
              child: widget,
            )
          ],
        ),
      ),
    );
  }

}