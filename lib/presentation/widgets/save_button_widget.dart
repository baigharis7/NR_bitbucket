import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';

class SaveButton extends StatelessWidget {
  final Function onPressed;
  final String? text;

  const SaveButton({
    Key? key,
    required this.onPressed,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => onPressed.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Dimens.marginNormal),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.yellowishGreen.withOpacity(0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            text ?? AppLocalizations.of(context)!.save,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: Dimens.fontSizeLarge,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
