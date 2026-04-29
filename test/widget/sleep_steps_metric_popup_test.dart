import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/healthmetrics/health_metric_detail_sheet.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/sleeping_hours_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/steps_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/water_intake_wigdet.dart';

/// Integration tests verifying the dashboard widgets (Sleep, Steps, Water)
/// each render the HealthImpactMetricsRow and tapping a metric opens the
/// popup detail sheet on the dashboard.
void main() {
  Widget buildHarness(Widget body) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: SingleChildScrollView(child: body),
      ),
    );
  }

  void setupPopup(WidgetTester tester) {
    // Use a wide surface so multi-word metric labels render without overflow
    // ellipsis truncating them and breaking find.text() lookups.
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() async {
      HealthMetricDetailSheet.hide();
      await tester.pumpAndSettle();
    });
  }

  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      FlutterError.presentError(details);
    };
  });
  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  group('SleepingHoursWidget metric markers', () {
    testWidgets('renders both Concentration and Muscle Regeneration metrics',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        const SleepingHoursWidget(hoursSlept: 7.0, hoursGoal: 8),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Concentration & Focus'), findsOneWidget);
      expect(find.text('Muscle Regeneration'), findsOneWidget);
    });

    testWidgets('tapping Concentration & Focus opens the metric detail popup',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        const SleepingHoursWidget(hoursSlept: 7.0, hoursGoal: 8),
      ));
      await tester.pumpAndSettle();

      // Popup not visible yet
      expect(find.byIcon(Icons.menu_book_outlined), findsNothing);

      await tester.tap(find.text('Concentration & Focus'));
      await tester.pumpAndSettle();

      // Popup is visible
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    });

    testWidgets('tapping Muscle Regeneration opens the metric detail popup',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        const SleepingHoursWidget(hoursSlept: 6.0, hoursGoal: 8),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Muscle Regeneration'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });
  });

  group('StepsWidget metric markers', () {
    testWidgets('renders both Cardiovascular Health and Physical Endurance metrics',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        const StepsWidget(stepsTaken: 5000, stepsGoal: 10000),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Cardiovascular Health'), findsOneWidget);
      expect(find.text('Physical Endurance'), findsOneWidget);
    });

    testWidgets('tapping Cardiovascular Health opens the metric detail popup',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        const StepsWidget(stepsTaken: 5000, stepsGoal: 10000),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cardiovascular Health'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    });

    testWidgets('tapping Physical Endurance opens the metric detail popup',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        const StepsWidget(stepsTaken: 8500, stepsGoal: 10000),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Physical Endurance'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });
  });

  group('WaterIntakeWidget metric markers', () {
    testWidgets('renders all three hydration metrics',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        WaterIntakeWidget(
          totalLitersGoal: 2.0,
          consumedGlasses: 6,
          onAddWater: () {},
          onRemoveWater: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Hydration produces three metrics: cramps, skin care (collagen), kidneys
      expect(find.text('Cramps'), findsOneWidget);
      expect(find.text('Skin Care'), findsOneWidget);
      expect(find.text('Kidneys'), findsOneWidget);
    });

    testWidgets('tapping Cramps metric opens the metric detail popup',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        WaterIntakeWidget(
          totalLitersGoal: 2.0,
          consumedGlasses: 6,
          onAddWater: () {},
          onRemoveWater: () {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cramps'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });

    testWidgets('tapping Kidneys metric opens the metric detail popup',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        WaterIntakeWidget(
          totalLitersGoal: 2.0,
          consumedGlasses: 6,
          onAddWater: () {},
          onRemoveWater: () {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kidneys'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });

    testWidgets('tapping Skin Care metric opens the metric detail popup',
        (tester) async {
      setupPopup(tester);
      await tester.pumpWidget(buildHarness(
        WaterIntakeWidget(
          totalLitersGoal: 2.0,
          consumedGlasses: 6,
          onAddWater: () {},
          onRemoveWater: () {},
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skin Care'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });
  });
}
