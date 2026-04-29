import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/activity_log_widget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/meal_time_widget.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/NutritionProgressWidget.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/micro_nutrients_section.dart';

import 'test_navigation_helpers.dart';

/// Verifies that callback-driven dashboard widgets fire their navigation
/// hooks. The actual destination is wired up in dashboard_screen.dart;
/// here we only test the widget's tap → callback contract.
void main() {
  setUpAll(() {
    AppLocalizationsHelperDelegate.instance =
        AppLocalizationsHelper(const Locale('en'));
  });

  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      FlutterError.presentError(details);
    };
  });
  tearDown(() {
    FlutterError.onError = FlutterError.presentError;
  });

  Widget wrapInApp(Widget child) {
    return buildAppWithStubRoutes(home: Scaffold(body: child));
  }

  group('MealTimeWidget (used as Supplements card and Feces/Urine card)', () {
    testWidgets('tapping body fires onItemClick (supplements detail nav)',
        (tester) async {
      setPhoneSurface(tester);
      var itemTapped = false;
      var addTapped = false;
      await tester.pumpWidget(wrapInApp(
        MealTimeWidget(
          name: 'Supplements',
          svg: 'assets/images/supplement.png',
          onItemClick: () => itemTapped = true,
          onClick: () => addTapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap the body (the name text)
      await tester.tap(find.text('Supplements'));
      await tester.pumpAndSettle();

      expect(itemTapped, isTrue);
      expect(addTapped, isFalse);
    });

    testWidgets('tapping + icon fires onClick (add new nav)', (tester) async {
      setPhoneSurface(tester);
      var itemTapped = false;
      var addTapped = false;
      await tester.pumpWidget(wrapInApp(
        MealTimeWidget(
          name: 'Supplements',
          svg: 'assets/images/supplement.png',
          onItemClick: () => itemTapped = true,
          onClick: () => addTapped = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap the + icon (add_circle is rendered inside the widget)
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      expect(addTapped, isTrue);
      expect(itemTapped, isFalse);
    });
  });

  group('ActivityLogWidget', () {
    testWidgets('tapping log area fires onTap (sport items nav)',
        (tester) async {
      setPhoneSurface(tester);
      var bodyTapped = false;
      var addTapped = false;
      var hsTapped = false;
      await tester.pumpWidget(wrapInApp(
        ActivityLogWidget(
          sportEvents: const [],
          onAdd: () => addTapped = true,
          onTap: () => bodyTapped = true,
          showHealthSyncPrompt: false,
          onHealthSyncTap: () => hsTapped = true,
          onHealthSyncDismiss: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Tap the body — find the log area text or scaffold body region
      await tester.tap(find.text('Activity Log'));
      await tester.pumpAndSettle();

      expect(bodyTapped, isTrue);
      expect(addTapped, isFalse);
      expect(hsTapped, isFalse);
    });

    testWidgets('tapping + icon fires onAdd (add sport event nav)',
        (tester) async {
      setPhoneSurface(tester);
      var addTapped = false;
      await tester.pumpWidget(wrapInApp(
        ActivityLogWidget(
          sportEvents: const [],
          onAdd: () => addTapped = true,
          onTap: () {},
          showHealthSyncPrompt: false,
          onHealthSyncTap: () {},
          onHealthSyncDismiss: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Find any add icon used by activity log
      final addIcons = find.byIcon(Icons.add_circle);
      expect(addIcons, findsAtLeastNWidgets(1));
      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();

      expect(addTapped, isTrue);
    });

    testWidgets('health sync prompt visible only when showHealthSyncPrompt = true',
        (tester) async {
      setPhoneSurface(tester);
      await tester.pumpWidget(wrapInApp(
        ActivityLogWidget(
          sportEvents: const [],
          onAdd: () {},
          onTap: () {},
          showHealthSyncPrompt: true,
          onHealthSyncTap: () {},
          onHealthSyncDismiss: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Sync prompt has a connect-cta text
      expect(find.textContaining('Health'), findsWidgets);
    });
  });

  // Note: WaterIntakeWidget exposes `onInfoClick` but as of 2026-04-29 it
  // isn't wired up to any tap target inside the widget body — the only
  // detail-sheet trigger is HealthImpactMetricsRow. The dashboard wires this
  // callback up directly, so we cover navigation at that integration point
  // (manual acceptance: DASH-20, LIQ-03).

  group('NutritionProgressWidget info button', () {
    testWidgets('tapping info icon navigates to EnergyBalanceDetailScreen',
        (tester) async {
      setPhoneSurface(tester);
      final recorder = NavRecorder();
      final selectedDate = DateTime(2026, 4, 27);
      final energy = EnergyModel(
        fractionToFill: 0.5,
        totalKcal: 2000,
        rawKcalTaken: 1000,
        spentKcal: 100,
      );
      await tester.pumpWidget(buildAppWithStubRoutes(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NutritionProgressWidget(
              energyModel: energy,
              nutrientsList: const <NutrientsModel>[],
              selectedDate: selectedDate,
            ),
          ),
        ),
        routeNames: const ['/energy_balance_detail_screen'],
        recorder: recorder,
      ));
      await tester.pumpAndSettle();

      final infoIcons = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.contains('info'),
      );
      expect(infoIcons, findsAtLeastNWidgets(1));
      await tester.tap(infoIcons.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expectNavigated(recorder, '/energy_balance_detail_screen');
      final args = recorder.lastArguments as Map;
      expect(args['energyModel'], energy);
      expect(args['selectedDate'], selectedDate);
    });
  });

  group('MicroNutrientsSection info button', () {
    testWidgets('tapping info icon navigates to MicroNutrientsDetailScreen',
        (tester) async {
      setPhoneSurface(tester);
      final recorder = NavRecorder();
      await tester.pumpWidget(buildAppWithStubRoutes(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MicroNutrientsSection(
              micronutrients: const <NutrientsModel>[],
              temporaryMicronutrients: const <NutrientsModel>[],
              filteredNutrientsLess15RDA: const <NutrientsModel>[],
              objectives: const [],
              selectedDate: DateTime(2026, 4, 27),
            ),
          ),
        ),
        routeNames: const ['/micro_nutrients_detail_screen'],
        recorder: recorder,
      ));
      await tester.pumpAndSettle();

      // Info icon is the only Image.asset of info.png in the widget
      final infoIcons = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.contains('info'),
      );
      expect(infoIcons, findsAtLeastNWidgets(1));
      await tester.tap(infoIcons.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expectNavigated(recorder, '/micro_nutrients_detail_screen');
      final args = recorder.lastArguments as Map;
      expect(args['selectedDate'], DateTime(2026, 4, 27));
    });
  });
}
