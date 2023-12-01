import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class AddEventCalendarButton extends StatelessWidget {
  final String title;
  final Function onPressedButton;

  const AddEventCalendarButton({
    Key? key,
    required this.title,
    required this.onPressedButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal, vertical: Dimens.marginXSmall-2),
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)), side: BorderSide(color: AppColors.mountainMeadow, width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Dimens.marginNormal),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => onPressedButton.call(),
              icon: const Icon(Icons.add_circle, color: AppColors.mountainMeadow),
            )
          ],
        ),
      ),
    );
  }

}