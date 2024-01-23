import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoundedCustomButton extends StatelessWidget {
  final Function onPressed;
  final String? buttonText;
  final bool enableButton;

  const RoundedCustomButton({
    Key? key,
    required this.onPressed,
    this.buttonText,
    this.enableButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(/*left: Dimens.marginNormal, right: Dimens.marginNormal, */vertical: Dimens.marginXXLarge),
      child: CustomButton1(
        enable: enableButton,
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            color: Colors.white,
          ),
          backgroundColor: enableButton ? AppColors.mountainMeadow : Colors.green.shade100,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7)),),
        ),
        textColor: Colors.white,
        message: buttonText ?? AppLocalizations.of(context)!.save,
        action: () => onPressed.call(),
      ),
    );
  }

}