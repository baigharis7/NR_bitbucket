import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class PopupMenuHelper {
  PopupMenuHelper();

  PopupMenuButton createPopupMenuWith({
    required List<PopupMenuItemModel> model,
    required Image buttonImage,
    double? iconSize,
  }) {
    return PopupMenuButton(
      iconSize: iconSize ?? 28,
      padding: const EdgeInsets.only(right: Dimens.marginNormal),
      icon: buttonImage,
      itemBuilder: (ctx) {
        return [
          ...model.map((option) {
            return PopupMenuItem<int>(
              value: option.value, // TODO: va a dar error
              child: InkWell(
                onTap: () => option.onPressed.call(),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: Dimens.marginNormal,
                    vertical: Dimens.marginSmall,
                  ),
                  child: Text(option.title),
                ),
              ),
            );
          }).toList()
        ];
      },
    );
  }

}

class PopupMenuItemModel {
  final int value;
  final String title;
  final Function onPressed;

  PopupMenuItemModel({
    required this.value,
    required this.title,
    required this.onPressed,
  });

}