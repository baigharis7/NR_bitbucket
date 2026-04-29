import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/i10n_helper.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/view/meal_time_details_screen.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/meal_time_section.dart';

import 'test_navigation_helpers.dart';

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

  Widget buildHarness({
    required DateTime selectedDateTime,
    NavRecorder? recorder,
  }) {
    return buildAppWithStubRoutes(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MealTimeSection(
            foodEvents: const [],
            totalKcal: 0,
            selectedDateTime: selectedDateTime,
          ),
        ),
      ),
      routeNames: [
        MealTimeDetailScreen.routeName,
        AddFoodEventScreen.routeName,
      ],
      recorder: recorder,
    );
  }

  group('MealTimeSection navigation', () {
    final selectedDateTime = DateTime(2026, 4, 27, 12);

    Future<void> ensureExpanded(WidgetTester tester) async {
      // The section starts expanded, but if anything ever changes that,
      // tap the title to expand.
      if (find.text('Breakfast').evaluate().isEmpty) {
        await tester.tap(find.text('Feeding'));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('Breakfast card tap navigates to MealTimeDetailScreen',
        (tester) async {
      setPhoneSurface(tester);
      final recorder = NavRecorder();
      await tester.pumpWidget(
          buildHarness(selectedDateTime: selectedDateTime, recorder: recorder));
      await tester.pumpAndSettle();
      await ensureExpanded(tester);

      // Tap the card body (the meal name/text area)
      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();

      expectNavigated(recorder, MealTimeDetailScreen.routeName);
      final args = recorder.lastArguments as FoodArgumentsModel;
      expect(args.mealTime, isA<Breakfast>());
      expect(args.selectedDateTime, selectedDateTime);
    });

    testWidgets('Lunch card tap navigates to MealTimeDetailScreen',
        (tester) async {
      setPhoneSurface(tester);
      final recorder = NavRecorder();
      await tester.pumpWidget(
          buildHarness(selectedDateTime: selectedDateTime, recorder: recorder));
      await tester.pumpAndSettle();
      await ensureExpanded(tester);

      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();

      expectNavigated(recorder, MealTimeDetailScreen.routeName);
      final args = recorder.lastArguments as FoodArgumentsModel;
      expect(args.mealTime, isA<Lunch>());
    });

    testWidgets('Dinner card tap navigates to MealTimeDetailScreen',
        (tester) async {
      setPhoneSurface(tester);
      final recorder = NavRecorder();
      await tester.pumpWidget(
          buildHarness(selectedDateTime: selectedDateTime, recorder: recorder));
      await tester.pumpAndSettle();
      await ensureExpanded(tester);

      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();

      expectNavigated(recorder, MealTimeDetailScreen.routeName);
      final args = recorder.lastArguments as FoodArgumentsModel;
      expect(args.mealTime, isA<Dinner>());
    });

    testWidgets('Snack card tap navigates to MealTimeDetailScreen',
        (tester) async {
      setPhoneSurface(tester);
      final recorder = NavRecorder();
      await tester.pumpWidget(
          buildHarness(selectedDateTime: selectedDateTime, recorder: recorder));
      await tester.pumpAndSettle();
      await ensureExpanded(tester);

      await tester.tap(find.text('Snack'));
      await tester.pumpAndSettle();

      expectNavigated(recorder, MealTimeDetailScreen.routeName);
      final args = recorder.lastArguments as FoodArgumentsModel;
      expect(args.mealTime, isA<Snack>());
    });

    testWidgets('+ button on Breakfast card navigates to AddFoodEventScreen',
        (tester) async {
      setPhoneSurface(tester);
      final recorder = NavRecorder();
      await tester.pumpWidget(
          buildHarness(selectedDateTime: selectedDateTime, recorder: recorder));
      await tester.pumpAndSettle();
      await ensureExpanded(tester);

      // The first add_circle icon belongs to the first card (Breakfast).
      final addIcons = find.byIcon(Icons.add_circle);
      expect(addIcons, findsNWidgets(4));

      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();

      expectNavigated(recorder, AddFoodEventScreen.routeName);
      final args = recorder.lastArguments as FoodArgumentsModel;
      expect(args.mealTime, isA<Breakfast>());
      expect(args.selectedDateTime, selectedDateTime);
    });

    testWidgets('+ button on Snack (last) card navigates to AddFoodEventScreen with Snack',
        (tester) async {
      setPhoneSurface(tester);
      final recorder = NavRecorder();
      await tester.pumpWidget(
          buildHarness(selectedDateTime: selectedDateTime, recorder: recorder));
      await tester.pumpAndSettle();
      await ensureExpanded(tester);

      // 4 add icons, one per meal — last one is Snack
      final addIcons = find.byIcon(Icons.add_circle);
      await tester.tap(addIcons.last);
      await tester.pumpAndSettle();

      expectNavigated(recorder, AddFoodEventScreen.routeName);
      final args = recorder.lastArguments as FoodArgumentsModel;
      expect(args.mealTime, isA<Snack>());
    });

  });
}
