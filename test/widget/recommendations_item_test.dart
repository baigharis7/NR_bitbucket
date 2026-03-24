import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recommendations_item.dart';

void main() {
  // ---------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------
  FoodItemMaster _food({int? id, String en = 'Apple', String es = 'Manzana'}) {
    return FoodItemMaster(id: id, en: en, es: es, group: 'fruits');
  }

  RecommendationFoodInfo _foodInfo(FoodItemMaster food) {
    return RecommendationFoodInfo(foodItemMaster: food, foodNutrients: []);
  }

  Widget buildTestWidget({
    required FoodItemMaster foodItemMaster,
    bool isChecked = false,
    Color? checkBoxColor,
    List<RecommendationFoodInfo>? alternativeUsualHealthyFoods,
    Function? onAdd,
    Function(RecommendationFoodInfo?)? onAlternativeAdd,
    bool? Function(int)? isAlternativeChecked,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: Scaffold(
        body: RecommendationsItem(
          foodItemMaster: foodItemMaster,
          isChecked: isChecked,
          checkBoxColor: checkBoxColor,
          alternativeUsualHealthyFoods: alternativeUsualHealthyFoods,
          onAdd: onAdd ?? () {},
          onAlternativeAdd: onAlternativeAdd ?? (_) {},
          isAlternativeChecked: isAlternativeChecked ?? (_) => false,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------
  group('RecommendationsItem', () {
    testWidgets('displays food name', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'Banana'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('uses Clip.antiAlias on outer container', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1),
      ));
      await tester.pumpAndSettle();

      final containerFinder = find.byWidgetPredicate((widget) =>
        widget is Container && widget.clipBehavior == Clip.antiAlias,
      );
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('contains IntrinsicHeight widget for row layout', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(IntrinsicHeight), findsOneWidget);
    });

    testWidgets('shows add_circle_outline icon when unchecked', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1),
        isChecked: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('shows check_circle icon when isChecked=true', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1),
        isChecked: true,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows add_circle_outline icon when isChecked=false', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1),
        isChecked: false,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('calls onAdd when add icon is tapped', (tester) async {
      bool addCalled = false;
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1),
        onAdd: () => addCalled = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      expect(addCalled, isTrue);
    });

    testWidgets('does NOT show alternatives button when alternativeUsualHealthyFoods is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'Rice'),
        alternativeUsualHealthyFoods: [],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.swap_horiz), findsNothing);
    });

    testWidgets('does NOT show alternatives button when alternativeUsualHealthyFoods is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'Rice'),
        alternativeUsualHealthyFoods: null,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.swap_horiz), findsNothing);
    });

    testWidgets('shows alternatives button with swap_horiz icon when alternatives are non-empty', (tester) async {
      final alternatives = [
        _foodInfo(_food(id: 10, en: 'Brown Rice')),
        _foodInfo(_food(id: 11, en: 'Quinoa')),
      ];

      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'White Rice'),
        alternativeUsualHealthyFoods: alternatives,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      expect(find.text('Alternatives'), findsOneWidget);
    });

    testWidgets('tapping alternatives button opens bottom sheet with alternative food names', (tester) async {
      final alternatives = [
        _foodInfo(_food(id: 10, en: 'Brown Rice')),
        _foodInfo(_food(id: 11, en: 'Quinoa')),
      ];

      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'White Rice'),
        alternativeUsualHealthyFoods: alternatives,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alternatives'));
      await tester.pumpAndSettle();

      expect(find.text('Brown Rice'), findsOneWidget);
      expect(find.text('Quinoa'), findsOneWidget);
    });

    testWidgets('bottom sheet has "Alternatives" title', (tester) async {
      final alternatives = [
        _foodInfo(_food(id: 10, en: 'Brown Rice')),
      ];

      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'White Rice'),
        alternativeUsualHealthyFoods: alternatives,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alternatives'));
      await tester.pumpAndSettle();

      // "Alternatives" appears twice: once on the button and once as sheet title
      expect(find.text('Alternatives'), findsNWidgets(2));
    });

    testWidgets('tapping an alternative calls onAlternativeAdd and closes sheet', (tester) async {
      RecommendationFoodInfo? addedAlt;
      final alternatives = [
        _foodInfo(_food(id: 10, en: 'Brown Rice')),
      ];

      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'White Rice'),
        alternativeUsualHealthyFoods: alternatives,
        onAlternativeAdd: (alt) => addedAlt = alt,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alternatives'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Brown Rice'));
      await tester.pumpAndSettle();

      expect(addedAlt, isNotNull);
      expect(addedAlt!.foodItemMaster.en, 'Brown Rice');
      // Bottom sheet should be closed - "Brown Rice" no longer visible
      expect(find.text('Brown Rice'), findsNothing);
    });

    testWidgets('bottom sheet shows check_circle icon for selected alternative', (tester) async {
      final alternatives = [
        _foodInfo(_food(id: 10, en: 'Brown Rice')),
      ];

      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'White Rice'),
        alternativeUsualHealthyFoods: alternatives,
        isAlternativeChecked: (id) => id == 10 ? true : false,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alternatives'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('bottom sheet does NOT show check_circle for unselected alternative', (tester) async {
      final alternatives = [
        _foodInfo(_food(id: 10, en: 'Brown Rice')),
      ];

      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'White Rice'),
        alternativeUsualHealthyFoods: alternatives,
        isAlternativeChecked: (id) => false,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alternatives'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('add icon uses provided checkBoxColor', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1),
        isChecked: false,
        checkBoxColor: AppColors.peacockBlue,
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.add_circle_outline));
      expect(icon.color, AppColors.peacockBlue);
    });

    testWidgets('add icon uses default color when checkBoxColor is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1),
        isChecked: false,
        checkBoxColor: null,
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.add_circle_outline));
      // The default color is `widget.checkBoxColor ?? AppColors.yellowishGreen`
      expect(icon.color, AppColors.yellowishGreen);
    });

    testWidgets('food name has maxLines: 2 and TextOverflow.ellipsis', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        foodItemMaster: _food(id: 1, en: 'Very Long Food Name That Might Wrap'),
      ));
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Very Long Food Name That Might Wrap'));
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
