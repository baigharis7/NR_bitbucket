import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GenericButton extends StatelessWidget {
  final String? title;
  final Function onPressed;
  final bool enableButton;
  const GenericButton({super.key, this.title, required this.onPressed, this.enableButton = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
        height: 50,
        child: ElevatedButton(
            onPressed: () => enableButton ? onPressed.call() : null,
          style: ElevatedButton.styleFrom(
            side: const BorderSide(
              color: Colors.transparent,
              width: 0.0,
            ),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(1))),
            backgroundColor: enableButton ? AppColors.white70Percent : AppColors.white25Percent,
          ),
            child: Text(title ?? AppLocalizations.of(context)!.save, style: const TextStyle(color: AppColors.yellowishGreen,fontSize: Dimens.fontSizeMedium, fontWeight: FontWeight.w700)),
        ),
    );
  }

}