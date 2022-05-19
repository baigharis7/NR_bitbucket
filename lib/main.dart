import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/splash/view/splash_screen.dart';

void main() async {








  runApp(
    MultiProvider(
      child: MaterialApp(
        title: 'NutreNaissance',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        initialRoute: '/',
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
          Locale('es', ''), // Spanish, no country code
        ],
        routes: {
          '/': (ctx) => const LoginScreen(),
          SplashScreen.routeName: (ctx) => SplashScreen(context: ctx),
        },
      ),
    ),
  );
}

}