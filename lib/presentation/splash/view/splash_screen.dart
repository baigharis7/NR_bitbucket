import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/splash/provider/splash_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

import '../../../infrastructure/helpers/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash_screen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _initStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initStarted) {
      _initStarted = true;
      SplashProvider().init(
        toLogin: () => Navigator.popAndPushNamed(context, LoginScreen.routeName),
        toDashboard: () => Navigator.popAndPushNamed(context, DashboardScreen.routeName),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
