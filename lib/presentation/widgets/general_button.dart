import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

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
        child: Text(title ?? AppLocalizations.of(context)!.save, style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w700, fontSize: Dimens.fontSize19, color: textColor)),
      ),
    );
  }

}