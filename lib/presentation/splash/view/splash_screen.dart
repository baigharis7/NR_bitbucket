import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/splash/provider/splash_provider.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash_screen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SplashProvider().init(
        toLogin: () => Navigator.popAndPushNamed(context, LoginScreen.routeName),
        toDashboard: () => Navigator.popAndPushNamed(context, DashboardScreen.routeName),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge),
          child: Image.asset(
            'assets/images/logo_name_black.png',
            fit: BoxFit.cover,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
