import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/splash/provider/splash_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash_screen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SplashProvider().init(
        toLogin: () => Navigator.popAndPushNamed(context, LoginScreen.routeName),
        toDashboard: () => Navigator.popAndPushNamed(context, DashboardScreen.routeName),
    );

    return Stack(
      children: [
        // Background image or gradient
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'), // Your image
              fit: BoxFit.cover,
            ),
          ),
        ),

        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/opacity_splash.png'), // Your image
              fit: BoxFit.cover,
              opacity: 0.85,
            ),
          ),
        ),

        // Blur effect
        // BackdropFilter(
        //   filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        //   child: Container(
        //     color: Colors.black26.withOpacity(0.5), // Needed to activate the blur
        //   ),
        // ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_name_white.png',
                  fit: BoxFit.cover,
                  height: 106, width: 242,
                ),
                const SizedBox(height: Dimens.heightSmall),
                Text(AppLocalizations.of(context)!.welcome + ' :)', style: AppTextStyles.merriWeather.copyWith(fontWeight: FontWeight.w400, fontSize: Dimens.fontSizeXXLarge),),
              ],
            ),
          ),
        ),
      ] ,
    );
  }
}
