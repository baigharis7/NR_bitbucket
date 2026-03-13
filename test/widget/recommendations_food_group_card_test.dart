import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recommendations_food_group_card.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/recommendations_item.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/square_checkbox.dart';

void main() {
  // ---------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------
  RecommendationGroup _group({String en = 'Test Group', String es = 'Grupo Test'}) {
    return RecommendationGroup(id: 1, groups: ['grains'], size: 5, en: en, es: es);
  }

  FoodItemMaster _food({int? id, String en = 'Apple', String es = 'Manzana'}) {
    return FoodItemMaster(id: id, en: en, es: es, group: 'grains');
  }

  RecommendationFoodInfo _foodInfo(FoodItemMaster food) {
    return RecommendationFoodInfo(foodItemMaster: food, foodNutrients: []);
  }

  UsualFoodsItem _usualItem(FoodItemMaster food, {List<RecommendationFoodInfo>? altHealthy}) {
    return UsualFoodsItem(
      foodInfo: _foodInfo(food),
      alternativeUsualHealthyFoods: altHealthy ?? [],
      alternativeUsualUnHealthyFoods: [],
    );
  }

  Widget buildTestWidget({
    required RecommendationsFoodItem item,
    Function? onAdd,
    Function? isChecked,
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
        body: SingleChildScrollView(
          child: RecommendationsFoodGroupCard(
            recommendationsFoodItem: item,
            onAdd: onAdd ?? (_) {},
            isChecked: isChecked ?? (_) => false,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------
  group('RecommendationsFoodGroupCard', () {
    testWidgets('displays group name and starts collapsed (CrossFadeState.showFirst)', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Cereals & Grains'),
        objFoods: [_foodInfo(_food(id: 1, en: 'Rice'))],
        deficitFoods: [],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      expect(find.text('Cereals & Grains'), findsOneWidget);
      // AnimatedCrossFade keeps both children in tree, but collapsed shows first (SizedBox.shrink)
      final crossFade = tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
      expect(crossFade.crossFadeState, CrossFadeState.showFirst);
    });

    testWidgets('expands on tap to show food items as RecommendationsItem widgets', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Cereals & Grains'),
        objFoods: [_foodInfo(_food(id: 1, en: 'Rice'))],
        deficitFoods: [_foodInfo(_food(id: 2, en: 'Oats'))],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      // Tap to expand
      await tester.tap(find.text('Cereals & Grains'));
      await tester.pumpAndSettle();

      // Both obj and deficit foods should be rendered as RecommendationsItem
      expect(find.byType(RecommendationsItem), findsNWidgets(2));
      expect(find.text('Rice'), findsOneWidget);
      expect(find.text('Oats'), findsOneWidget);
    });

    testWidgets('filters out foods with null id from objFoods', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Veggies'),
        objFoods: [
          _foodInfo(_food(id: 1, en: 'Carrot')),
          _foodInfo(_food(id: null, en: 'NullIdFood')),
          _foodInfo(_food(id: 3, en: 'Spinach')),
        ],
        deficitFoods: [],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Veggies'));
      await tester.pumpAndSettle();

      // Only 2 RecommendationsItem widgets (null-id filtered out)
      expect(find.byType(RecommendationsItem), findsNWidgets(2));
      expect(find.text('Carrot'), findsOneWidget);
      expect(find.text('Spinach'), findsOneWidget);
      expect(find.text('NullIdFood'), findsNothing);
    });

    testWidgets('filters out foods with null id from deficitFoods', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Fruits'),
        objFoods: [],
        deficitFoods: [
          _foodInfo(_food(id: 5, en: 'Banana')),
          _foodInfo(_food(id: null, en: 'NullDeficit')),
        ],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fruits'));
      await tester.pumpAndSettle();

      expect(find.byType(RecommendationsItem), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('NullDeficit'), findsNothing);
    });

    testWidgets('filters out usualUnHealthyFoods with null id', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Mixed'),
        objFoods: [],
        deficitFoods: [],
        usualUnHealthyFoods: [
          _usualItem(_food(id: 10, en: 'Chips')),
          _usualItem(_food(id: null, en: 'NullUsual')),
        ],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mixed'));
      await tester.pumpAndSettle();

      expect(find.byType(RecommendationsItem), findsOneWidget);
      expect(find.text('Chips'), findsOneWidget);
      expect(find.text('NullUsual'), findsNothing);
    });

    testWidgets('renders ALL foods without .take() limit (more than old limit of 5)', (tester) async {
      // Create 12 foods - more than the old RECOMMENDATION_LIST_SIZE (5)
      final manyFoods = List.generate(
        12,
        (i) => _foodInfo(_food(id: i + 1, en: 'Food${i + 1}')),
      );

      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'BigGroup'),
        objFoods: manyFoods,
        deficitFoods: [],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      await tester.tap(find.text('BigGroup'));
      await tester.pumpAndSettle();

      // All 12 RecommendationsItem widgets should be rendered
      expect(find.byType(RecommendationsItem), findsNWidgets(12));
      for (int i = 1; i <= 12; i++) {
        expect(find.text('Food$i'), findsOneWidget);
      }
    });

    testWidgets('calls onAdd with correct FoodItemMaster when checkbox tapped', (tester) async {
      FoodItemMaster? addedFood;
      final food = _food(id: 1, en: 'Rice');
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Grains'),
        objFoods: [_foodInfo(food)],
        deficitFoods: [],
      );

      await tester.pumpWidget(buildTestWidget(
        item: item,
        onAdd: (f) => addedFood = f,
        isChecked: (_) => false,
      ));
      await tester.pumpAndSettle();

      // Expand
      await tester.tap(find.text('Grains'));
      await tester.pumpAndSettle();

      // Tap the checkbox (InkWell inside SquareCheckbox)
      final checkbox = find.byType(SquareCheckbox);
      expect(checkbox, findsOneWidget);
      final inkwell = find.descendant(of: checkbox, matching: find.byType(InkWell));
      await tester.tap(inkwell);
      await tester.pumpAndSettle();

      expect(addedFood, isNotNull);
      expect(addedFood!.id, 1);
      expect(addedFood!.en, 'Rice');
    });

    testWidgets('renders SquareCheckbox for each food item when expanded', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Test'),
        objFoods: [
          _foodInfo(_food(id: 1, en: 'Food1')),
          _foodInfo(_food(id: 2, en: 'Food2')),
        ],
        deficitFoods: [_foodInfo(_food(id: 3, en: 'Food3'))],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test'));
      await tester.pumpAndSettle();

      expect(find.byType(SquareCheckbox), findsNWidgets(3));
    });

    testWidgets('handles null usualUnHealthyFoods gracefully', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Safe'),
        objFoods: [_foodInfo(_food(id: 1, en: 'Apple'))],
        deficitFoods: [],
        usualUnHealthyFoods: null,
        usualHealthyFoods: null,
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Safe'));
      await tester.pumpAndSettle();

      // Should not crash; Apple should still render
      expect(find.text('Apple'), findsOneWidget);
      expect(find.byType(RecommendationsItem), findsOneWidget);
    });

    testWidgets('toggle expand/collapse changes AnimatedCrossFade state', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Toggle'),
        objFoods: [_foodInfo(_food(id: 1, en: 'Rice'))],
        deficitFoods: [],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      // Initially collapsed (showFirst)
      AnimatedCrossFade crossFade = tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
      expect(crossFade.crossFadeState, CrossFadeState.showFirst);

      // Expand
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      crossFade = tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
      expect(crossFade.crossFadeState, CrossFadeState.showSecond);

      // Collapse
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      crossFade = tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));
      expect(crossFade.crossFadeState, CrossFadeState.showFirst);
    });

    testWidgets('empty food lists show no RecommendationsItem when expanded', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Empty'),
        objFoods: [],
        deficitFoods: [],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Empty'));
      await tester.pumpAndSettle();

      expect(find.text('Empty'), findsOneWidget);
      expect(find.byType(RecommendationsItem), findsNothing);
    });

    testWidgets('arrow icon rotates when expanded', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Arrow'),
        objFoods: [_foodInfo(_food(id: 1, en: 'Rice'))],
        deficitFoods: [],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // Verify AnimatedRotation exists
      final rotationFinder = find.byType(AnimatedRotation);
      expect(rotationFinder, findsOneWidget);

      // Collapsed: turns = 0.0
      AnimatedRotation rotation = tester.widget<AnimatedRotation>(rotationFinder);
      expect(rotation.turns, 0.0);

      // Expand
      await tester.tap(find.text('Arrow'));
      await tester.pumpAndSettle();

      // Expanded: turns = 0.5
      rotation = tester.widget<AnimatedRotation>(rotationFinder);
      expect(rotation.turns, 0.5);
    });

    testWidgets('passes correct isChecked value to RecommendationsItem', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'Check'),
        objFoods: [_foodInfo(_food(id: 42, en: 'Checked Food'))],
        deficitFoods: [],
      );

      await tester.pumpWidget(buildTestWidget(
        item: item,
        isChecked: (id) => id == 42,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      final recItem = tester.widget<RecommendationsItem>(find.byType(RecommendationsItem));
      expect(recItem.isChecked, isTrue);
    });

    testWidgets('combined: objFoods + deficitFoods + usualUnHealthyFoods all render', (tester) async {
      final item = RecommendationsFoodItem(
        recommendationGroup: _group(en: 'All Types'),
        objFoods: [_foodInfo(_food(id: 1, en: 'ObjFood'))],
        deficitFoods: [_foodInfo(_food(id: 2, en: 'DefFood'))],
        usualUnHealthyFoods: [_usualItem(_food(id: 3, en: 'UsualFood'))],
      );

      await tester.pumpWidget(buildTestWidget(item: item));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All Types'));
      await tester.pumpAndSettle();

      expect(find.byType(RecommendationsItem), findsNWidgets(3));
      expect(find.text('ObjFood'), findsOneWidget);
      expect(find.text('DefFood'), findsOneWidget);
      expect(find.text('UsualFood'), findsOneWidget);
    });
  });
}
