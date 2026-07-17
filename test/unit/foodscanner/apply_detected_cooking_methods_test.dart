import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/scanner_result.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/view/add_food_event_screen.dart';

void main() {
  group('applyDetectedCookingMethods with cooking options hidden', () {
    // These tests describe the hidden state introduced by workstream C.
    // When cooking options are re-enabled (flag flipped to true), rewrite
    // them against the fixed cooking model together with the flag change.
    test('scanned foods stay raw even when a cooking method is detected', () {
      final result = ScannerResult(
        foods: [
          FoodInFavorite(id: 1, qty: 100, unit: -1, cookingMethod: -1),
          FoodInFavorite(id: 2, qty: 50, unit: -1, cookingMethod: -1),
        ],
        directLog: false,
        detectedCookingMethods: ['Fried', 'Grilled'],
      );
      final master = CookingMethodsInfoMaster(cookingMethodsInfo: [
        CookingMethodInfo(id: 5, en: 'Fried', es: 'Frito'),
        CookingMethodInfo(id: -2, en: 'Grilled', es: 'A la plancha'),
      ]);

      applyDetectedCookingMethods(result, master);

      for (final food in result.foods) {
        expect(food.cookingMethod, -1);
        expect(food.conversionFactor, isNull);
        expect(food.usedOil, isNull);
      }
    });
  });
}
