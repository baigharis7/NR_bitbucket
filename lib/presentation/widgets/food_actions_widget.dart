import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class FoodActionsWidget extends StatelessWidget {
  final String title;
  final Function? onTap;
  final Widget? rightSideWidget;
  final Color? backgroundColor;
  const FoodActionsWidget({super.key, required this.title, this.onTap, this.rightSideWidget, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal, horizontal: Dimens.marginXSmall),
      padding: const EdgeInsets.all(Dimens.marginLarge),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.floralWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: () => onTap?.call(),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w300, fontSize: Dimens.fontSizeMedium)),
            const Spacer(),
            if (rightSideWidget != null) rightSideWidget!,
          ],
        ),
      ),
    );
  }

}