import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_dialog.dart';

void main() {
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

  Widget buildTestApp({required void Function(FoodInEvent?) onResult}) {
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
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await showDialog<FoodInEvent>(
                context: context,
                builder: (_) => Dialog(
                  child: SingleChildScrollView(
                    child: AddFoodEventDialog(
                      foodInEvent: FoodInEvent(id: 100, qty: 0, unit: -1, cookingMethod: -1),
                      currentLanguage: 'en',
                      foodGroup: '1',
                      cookingMethodsMaster: testCookingMethods,
                      cookingMethodsInfoMaster: testCookingMethodsInfo,
                      unitsInfoMaster: testUnitsInfo,
                      unitsFoodsMaster: testUnitsFoods,
                    ),
                  ),
                ),
              );
              onResult(result);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  group('Cooking options hidden (Constants.cookingOptionsEnabled = false)', () {
    // These tests describe the hidden state introduced by workstream C.
    // When cooking options are re-enabled (flag flipped to true), rewrite
    // them against the fixed cooking model together with the flag change.
    testWidgets('does not render the cooking method selector', (tester) async {
      await tester.pumpWidget(buildTestApp(onResult: (_) {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Cooking method'), findsNothing);
      expect(find.byType(DropdownButton<String>), findsOneWidget); // unit selector only
    });

    testWidgets('finishing the dialog returns a raw ingredient', (tester) async {
      FoodInEvent? result;

      await tester.pumpWidget(buildTestApp(onResult: (r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '100');
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.cookingMethod, -1);
      expect(result!.conversionFactor, isNull);
      expect(result!.usedOil, isNull);
    });
  });
}
