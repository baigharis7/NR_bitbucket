import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/rounded_custom_button.dart';

import '../profile/common/objectives_screen.dart';
import '../profile/registry/view/registry_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome_screen';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXXXLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(
              'assets/icon/app_icon.png',
              width: 90,
              height: 90,
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: Dimens.marginXXLarge),
              child: Text(
                AppLocalizations.of(context)!.welcome + '!',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: Dimens.fontSizeXLarge,
                ),
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: Dimens.marginXXXLarge),
              child: RoundedCustomButton(
                onPressed: () {
                  Navigator.of(context)
                      .popAndPushNamed(ObjectivesScreen.routeName);
                },
                buttonText: AppLocalizations.of(context)!.begin,
              ),
            )
          ]),
        ),
      ),
    ));
  }
}
