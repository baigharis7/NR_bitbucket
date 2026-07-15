import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

/// Display policy for macronutrient quantities (domain expert, 15-Jul-2026):
/// 1 decimal, half-up. See proteinas/specs/decision-redondeo-display.md.
/// These cases are the policy's contract — if they fail, the display
/// convention changed and the expert must sign off again.
void main() {
  group('toNutrientDisplay — 1 decimal, half-up', () {
    test('rounds 8.76 to "8.8" (omelette case: neither "8" nor "9")', () {
      expect(8.76.toNutrientDisplay(), '8.8');
    });

    test('rounds 76.25 half-up to "76.3" (ham case from expert guide)', () {
      expect(76.25.toNutrientDisplay(), '76.3');
    });

    test('keeps one decimal on whole numbers ("57.0", as in the guide)', () {
      expect(57.0.toNutrientDisplay(), '57.0');
    });

    test('rounds down when below the midpoint', () {
      expect(11.04.toNutrientDisplay(), '11.0');
    });

    test('null-safe: null renders as "0.0"', () {
      double? none;
      expect(none.toNutrientDisplay(), '0.0');
    });
  });
}
