import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/app_text_styles.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/healthsync/view/health_sync_onboarding_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/general_button.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome_screen';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0)),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.marginXXXLarge,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_name_white.png',
                    width: 220,
                    color: Colors.white,
                  ),
                  const SizedBox(height: Dimens.height37),
                  Text(
                    '${AppLocalizations.of(context)!.welcome}!',
                    style: AppTextStyles.merriWeather.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: Dimens.fontSize21,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Dimens.height37),
                  GeneralButton(
                    title: AppLocalizations.of(context)!.begin,
                    onTap: () {
                      Navigator.of(context).popAndPushNamed(
                        HealthSyncOnboardingScreen.routeName,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
