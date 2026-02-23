import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/app_color.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/food_event_item.dart';

void main() {
  // Shared test data
  final testUnitsInfo = UnitsInfoMaster(unitsInfoMaster: [
    UnitInfoMaster(id: -1, en: 'grams', es: 'gramos'),
    UnitInfoMaster(id: -2, en: 'milliliters', es: 'mililitros'),
    UnitInfoMaster(id: 1, en: 'units', es: 'unidades'),
  ]);

  final testUnitsFoods = UnitsFoodsMaster(unitsFoodsMaster: [
    UnitFoodMaster(id: 100, units: '1,1'),
  ]);

  final testCookingMethods = CookingMethodsMaster(cookingMethods: [
    CookingMethod(group: '1', methods: [1, 2, 3]),
  ]);

  final testCookingMethodsInfo = CookingMethodsInfoMaster(cookingMethodsInfo: [
    CookingMethodInfo(id: -1, en: 'None', es: 'Ninguno'),
    CookingMethodInfo(id: 1, en: 'Boiled', es: 'Hervido'),
    CookingMethodInfo(id: 2, en: 'Grilled', es: 'A la plancha'),
    CookingMethodInfo(id: 3, en: 'Baked', es: 'Al horno'),
  ]);

  Widget buildTestWidget({
    required FoodInFavorite foodInEvent,
    String foodGroup = '1',
    String options = 'Apple',
    Function? onRemove,
    Function(FoodInFavorite)? onQtyChange,
    Function(FoodInFavorite)? onUnitChange,
    Function(FoodInFavorite)? onCookingMethodChange,
    Function(FoodInFavorite)? onConversionFactorChange,
    Function(FoodInFavorite)? onOilUsedChange,
    CookingMethodsInfoMaster? cookingMethodsInfoOverride,
    bool showValidation = false,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: Scaffold(
        body: SingleChildScrollView(
          child: FoodEventItem(
            foodInEvent: foodInEvent,
            foodGroup: foodGroup,
            cookingMethodsMaster: testCookingMethods,
            oilTypes: null,
            conversionFactors: null,
            cookingMethodsInfoMaster:
                cookingMethodsInfoOverride ?? testCookingMethodsInfo,
            unitsInfoMaster: testUnitsInfo,
            unitsFoodsMaster: testUnitsFoods,
            options: options,
            onRemove: onRemove ?? () {},
            onQtyChange: onQtyChange ?? (_) {},
            onUnitChange: onUnitChange ?? (_) {},
            onCookingMethodChange: onCookingMethodChange ?? (_) {},
            onConversionFactorChange: onConversionFactorChange ?? (_) {},
            onOilUsedChange: onOilUsedChange ?? (_) {},
            showValidation: showValidation,
          ),
        ),
      ),
    );
  }

  group('TS-BF0001: Add single non-cooked item', () {
    testWidgets('renders food name, amount field, and unit dropdown',
        (tester) async {
      final food = FoodInFavorite(
        id: 100,
        qty: 0,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 0,
      );

      await tester.pumpWidget(buildTestWidget(
        foodInEvent: food,
        options: 'Café Soluble',
      ));
      await tester.pumpAndSettle();

      // Food name is displayed
      expect(find.text('Café Soluble'), findsOneWidget);

      // "Amount" label
      expect(find.text('Amount'), findsOneWidget);

      // Quantity text field present
      expect(find.byType(TextField), findsOneWidget);

      // Unit dropdown present with "grams" default
      expect(find.text('grams'), findsOneWidget);
    });

    testWidgets('cooked toggle is OFF by default (conversionFactor: 0)',
        (tester) async {
      final food = FoodInFavorite(
        id: 100,
        qty: 50,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 0,
      );

      await tester.pumpWidget(buildTestWidget(foodInEvent: food));
      await tester.pumpAndSettle();

      // "Preparation Method" label is shown
      expect(find.text('Preparation Method'), findsOneWidget);

      // Switch exists and is OFF
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);

      // "Cooked" label next to switch
      expect(find.text('Cooked'), findsOneWidget);
    });

    testWidgets('no cooking method dropdown when cooked toggle is OFF',
        (tester) async {
      final food = FoodInFavorite(
        id: 100,
        qty: 50,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 0,
      );

      await tester.pumpWidget(buildTestWidget(foodInEvent: food));
      await tester.pumpAndSettle();

      // Should NOT show cooking method dropdown items
      expect(find.text('Boiled'), findsNothing);
      expect(find.text('Grilled'), findsNothing);
    });

    testWidgets('entering quantity calls onQtyChange callback',
        (tester) async {
      FoodInFavorite? changedFood;

      final food = FoodInFavorite(
        id: 100,
        qty: 0,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 0,
      );

      await tester.pumpWidget(buildTestWidget(
        foodInEvent: food,
        onQtyChange: (f) => changedFood = f,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '150');
      await tester.pumpAndSettle();

      expect(changedFood, isNotNull);
      expect(changedFood!.qty, 150);
    });
  });

  group('TS-BF0002: Add single cooked item', () {
    testWidgets(
        'enabling cooked toggle shows cooking method dropdown',
        (tester) async {
      // Start with cooked already ON (conversionFactor: 1)
      final food = FoodInFavorite(
        id: 100,
        qty: 100,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 1,
      );

      await tester.pumpWidget(buildTestWidget(foodInEvent: food));
      await tester.pumpAndSettle();

      // Switch should be ON
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);

      // Cooking method dropdown should be visible
      // The dropdown shows "None" as the default label for value -1
      expect(find.byType(DropdownButton<int>), findsOneWidget);
    });

    testWidgets('toggling cooked switch calls onConversionFactorChange',
        (tester) async {
      FoodInFavorite? changedFood;

      final food = FoodInFavorite(
        id: 100,
        qty: 100,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 0,
      );

      await tester.pumpWidget(buildTestWidget(
        foodInEvent: food,
        onConversionFactorChange: (f) => changedFood = f,
      ));
      await tester.pumpAndSettle();

      // Tap the cooked switch to enable it
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(changedFood, isNotNull);
      expect(changedFood!.conversionFactor, 1);
    });

    testWidgets('shows error border when cooked but no cooking method selected',
        (tester) async {
      // Cooked (1) but cookingMethod still -1 → error
      final food = FoodInFavorite(
        id: 100,
        qty: 100,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 1,
      );

      await tester.pumpWidget(buildTestWidget(foodInEvent: food, showValidation: true));
      await tester.pumpAndSettle();

      // The cooking method dropdown container should have a red error border
      final containers = find.byType(Container);
      bool hasErrorBorder = false;
      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration && decoration.border != null) {
          final border = decoration.border;
          if (border is Border && border.top.color == AppColors.errorRed) {
            hasErrorBorder = true;
            break;
          }
        }
      }

      // Error state should exist (cooked with cookingMethod -1 triggers error)
      expect(hasErrorBorder, isTrue);
    });
  });

  group('TS-BF0005 & TS-BF0006: Remove ingredient', () {
    testWidgets('X button is displayed and calls onRemove when tapped',
        (tester) async {
      bool removeCalled = false;

      final food = FoodInFavorite(
        id: 100,
        qty: 50,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 0,
      );

      await tester.pumpWidget(buildTestWidget(
        foodInEvent: food,
        options: 'Banana',
        onRemove: () => removeCalled = true,
      ));
      await tester.pumpAndSettle();

      // Find the cancel/remove icon
      final removeIcon = find.byIcon(Icons.cancel_outlined);
      expect(removeIcon, findsOneWidget);

      await tester.tap(removeIcon);
      await tester.pumpAndSettle();

      expect(removeCalled, isTrue);
    });
  });

  group('TS-BF0011: Edit logged item - amount and unit changes', () {
    testWidgets('pre-populates quantity when editing existing item',
        (tester) async {
      final food = FoodInFavorite(
        id: 100,
        qty: 200,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 0,
      );

      await tester.pumpWidget(buildTestWidget(foodInEvent: food));
      await tester.pumpAndSettle();

      // Quantity should be pre-filled with "200"
      expect(find.text('200'), findsOneWidget);
    });
  });
}
