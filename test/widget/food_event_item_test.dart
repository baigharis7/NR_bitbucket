import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/oil_types_response.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';
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
    OilTypesResponse? oilTypes,
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
            oilTypes: oilTypes,
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

  group('Cooking options hidden (Constants.cookingOptionsEnabled = false)', () {
    // These tests describe the hidden state introduced by workstream C.
    // When cooking options are re-enabled (flag flipped to true), rewrite
    // them against the fixed cooking model together with the flag change.
    testWidgets('does not render cooked switch, cooking method dropdown or oil selector',
        (tester) async {
      // A cooked+fried legacy ingredient with oil types available would
      // render all three controls if the flag were on.
      final food = FoodInFavorite(
        id: 100,
        qty: 100,
        unit: -1,
        cookingMethod: Constants.COOKING_METHOD_FRIED,
        conversionFactor: Constants.CONVERSION_FACTOR_COOKED,
        usedOil: 0,
      );

      await tester.pumpWidget(buildTestWidget(
        foodInEvent: food,
        oilTypes: OilTypesResponse(v: 1, data: [
          OilTypeResponse(id: 0, en: 'Extra virgin olive oil', es: 'Aceite de oliva virgen extra'),
        ]),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsNothing);
      expect(find.text('Preparation Method'), findsNothing);
      expect(find.text('Cooked'), findsNothing);
      // Cooking method and oil selectors are DropdownButton<int>;
      // the unit selector is DropdownButton<String> and must remain.
      expect(find.byType(DropdownButton<int>), findsNothing);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('editing quantity preserves cooking fields of a legacy cooked ingredient',
        (tester) async {
      FoodInFavorite? changedFood;

      final food = FoodInFavorite(
        id: 100,
        qty: 100,
        unit: -1,
        cookingMethod: Constants.COOKING_METHOD_FRIED,
        conversionFactor: Constants.CONVERSION_FACTOR_COOKED,
        usedOil: 0,
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
      expect(changedFood!.cookingMethod, Constants.COOKING_METHOD_FRIED);
      expect(changedFood!.conversionFactor, Constants.CONVERSION_FACTOR_COOKED);
      expect(changedFood!.usedOil, 0);
    });

    testWidgets('legacy cooked item without cooking method shows no validation error',
        (tester) async {
      // Cooked (1) with cookingMethod -1 used to trigger the missing-method
      // error; with the selector hidden the user could never fix it, so the
      // check is skipped.
      final food = FoodInFavorite(
        id: 100,
        qty: 100,
        unit: -1,
        cookingMethod: -1,
        conversionFactor: 1,
      );

      await tester.pumpWidget(buildTestWidget(foodInEvent: food, showValidation: true));
      await tester.pumpAndSettle();

      expect(find.text('Please select a cooking method'), findsNothing);
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
