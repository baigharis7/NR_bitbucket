import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/num_constants.dart';
import 'package:nutrenaissance_flutter/presentation/login/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash_screen';
  late final BuildContext _context;

  SplashScreen({Key? key, context}) : super(key: key) {
    _context = context;
  }

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final isLoggedIn = false;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    nextScreen(widget._context);
  }

  void nextScreen(BuildContext context) {
    Future.delayed(
      const Duration(seconds: NumConstants.splashDelay),
      () {
        if (isLoggedIn) {
        } else {
          Navigator.of(context).push(_createRoute());
        }
      },
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
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
    return Center(
      child: Image.asset(
        'assets/images/logo_name_black.png',
        fit: BoxFit.cover,
        color: Colors.white,
      ),
    );
  }
}
