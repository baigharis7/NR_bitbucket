import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/custom_button_1.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoundedCustomButton extends StatelessWidget {
  final Function onPressed;
  final String? buttonText;

  const RoundedCustomButton({
    Key? key,
    required this.onPressed,
    this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: Dimens.marginNormal, right: Dimens.marginNormal, top: Dimens.marginNormal),
      child: CustomButton1(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            color: Colors.white,
          ),
          backgroundColor: Colors.teal,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(7)),),
        ),
        textColor: Colors.white,
        message: buttonText ?? AppLocalizations.of(context)!.save,
        action: () => onPressed.call(),
      ),
    );
  }

}