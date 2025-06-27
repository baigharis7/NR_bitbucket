import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class GeneralButton extends StatelessWidget {
  final String? title;
  final Color? selectedColor;
  final Color? textColor;
  final Function? onTap;

  const GeneralButton({super.key, this.title, this.selectedColor, this.textColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.border18),
      onTap: () => onTap?.call(),
      child: Container(
        height: Dimens.height55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedColor ?? AppColors.yellowishGreen,
          border: Border.all(color: AppColors.whit),
          borderRadius: BorderRadius.circular(Dimens.border18),
        ),
        child: Text(title ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: Dimens.fontSize17, color: textColor ?? Colors.white)),
      ),
    );
  }

}