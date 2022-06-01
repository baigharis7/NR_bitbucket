import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/dimens.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/view/dashboard_screen.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';
import 'package:nutrenaissance_flutter/presentation/splash/splash_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/splash_screen';

  final isLoggedIn = false;
  Animation<double>? _opacityAnimation;

  SplashScreen({Key? key}) : super(key: key);

  Route _createRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.linear,
          ),
        );

        return FadeTransition(
          opacity: _opacityAnimation!,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SplashProvider>(context);

    provider.init(
        toLogin: () => Navigator.of(context).push(_createRoute(const LoginScreen())),
        toDashboard: () => Navigator.of(context).push(_createRoute(const DashboardScreen()))
    );

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimens.marginXLarge),
        child: Image.asset(
          'assets/images/logo_name_black.png',
          fit: BoxFit.cover,
          color: Colors.white,
        ),
      ),
    );
  }
}
