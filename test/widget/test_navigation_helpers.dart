import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';

/// Lightweight harness that records every named-route push and renders a
/// stub destination widget so tests can verify navigation wiring without
/// instantiating real screens (which would require full DI scaffolding).
///
/// Usage:
/// ```dart
/// final recorder = NavRecorder();
/// await tester.pumpWidget(buildAppWithStubRoutes(
///   home: MyWidgetUnderTest(...),
///   routeNames: ['/some_route', '/other_route'],
///   recorder: recorder,
/// ));
/// await tester.tap(find.text('Tap me'));
/// await tester.pumpAndSettle();
/// expect(recorder.lastRoute, '/some_route');
/// ```
class NavRecorder extends NavigatorObserver {
  final List<RoutePush> pushes = [];

  RoutePush? get last => pushes.isEmpty ? null : pushes.last;
  String? get lastRoute => last?.routeName;
  Object? get lastArguments => last?.arguments;

  void reset() => pushes.clear();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      pushes.add(RoutePush(
        routeName: route.settings.name!,
        arguments: route.settings.arguments,
      ));
    }
  }
}

class RoutePush {
  final String routeName;
  final Object? arguments;
  const RoutePush({required this.routeName, this.arguments});
}

/// Build a `MaterialApp` with stub route handlers for the named routes the
/// caller cares about. Each route renders a `Text(routeName)` plus a `Key`
/// for unambiguous finding via `find.byKey`.
Widget buildAppWithStubRoutes({
  required Widget home,
  List<String> routeNames = const [],
  NavRecorder? recorder,
}) {
  final routes = <String, WidgetBuilder>{
    for (final r in routeNames)
      r: (ctx) => Scaffold(
            key: Key('stub:$r'),
            body: Center(child: Text(r)),
          ),
  };

  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('es')],
    routes: routes,
    navigatorObservers: [if (recorder != null) recorder],
    onGenerateRoute: (settings) {
      // Fallback stub for any route not registered in [routes]. Using a
      // simple PageRouteBuilder avoids the page transition animation, which
      // makes pumpAndSettle finish faster.
      return PageRouteBuilder<dynamic>(
        settings: settings,
        pageBuilder: (ctx, _, __) => Scaffold(
          key: Key('stub:${settings.name}'),
          body: Center(child: Text(settings.name ?? 'unknown')),
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    },
    home: home,
  );
}

/// Set a phone-like surface size so widgets that assume real device width
/// don't overflow. Resets on tearDown.
void setPhoneSurface(WidgetTester tester, {Size size = const Size(400, 800)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Assert that the latest push was to [routeName] (most-recent navigation).
void expectNavigated(NavRecorder recorder, String routeName) {
  expect(
    recorder.lastRoute,
    routeName,
    reason: 'Expected last navigation to be "$routeName" '
        'but was "${recorder.lastRoute}". '
        'Full push history: ${recorder.pushes.map((p) => p.routeName).toList()}',
  );
}
