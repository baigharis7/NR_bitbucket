import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(
    BuildContext context,
    String? message,
    {
      String? actionLabel,
      Function? action,
    }
    ) {
  final snackBar = SnackBar(
    backgroundColor: Colors.red,
    content: Text(
      message ?? AppLocalizations.of(context)!.generic_error,
      style: const TextStyle(color: Colors.white),
    ),
    action: SnackBarAction(
      textColor: Colors.white,
      label: actionLabel ?? AppLocalizations.of(context)!.dismiss,
      onPressed: () {
        action?.call();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );

  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}