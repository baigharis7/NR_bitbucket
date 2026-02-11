import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/nutrition_utils.dart';

void main() {
  // ── calculateKcal ───────────────────────────────────────────────────

  group('Calorie Summation (calculateKcal)', () {
    // TS-NUTR-UTIL001
    test('sums eventKcals across multiple food events', () {
      final events = [
        FoodEventComplete(eventKcals: 300),
        FoodEventComplete(eventKcals: 450),
        FoodEventComplete(eventKcals: 250),
      ];

      final result = NutritionUtils.calculateKcal(foodEvents: events);
      expect(result, 1000);
    });

    // TS-NUTR-UTIL002
    test('returns 0 for empty list', () {
      final result = NutritionUtils.calculateKcal(foodEvents: []);
      expect(result, 0);
    });

    test('handles single event', () {
      final events = [
        FoodEventComplete(eventKcals: 500),
      ];

      final result = NutritionUtils.calculateKcal(foodEvents: events);
      expect(result, 500);
    });

    test('handles events with 0 kcal', () {
      final events = [
        FoodEventComplete(eventKcals: 0),
        FoodEventComplete(eventKcals: 300),
        FoodEventComplete(eventKcals: 0),
      ];

      final result = NutritionUtils.calculateKcal(foodEvents: events);
      expect(result, 300);
    });
  });

  // ── millisecondsToYears ─────────────────────────────────────────────

  group('Age Calculation (millisecondsToYears)', () {
    // TS-NUTR-UTIL004
    test('converts milliseconds to correct age', () {
      // Person born on 2000-01-01
      final birthMillis = DateTime(2000, 1, 1).millisecondsSinceEpoch;
      final age = NutritionUtils.millisecondsToYears(birthMillis);
      // Should be 26 in 2026
      expect(age, 26);
    });

    // TS-NUTR-UTIL005
    test('accounts for birthday not yet passed this year', () {
      // Person born on 2000-12-31 — birthday hasn't happened yet in Feb 2026
      final birthMillis = DateTime(2000, 12, 31).millisecondsSinceEpoch;
      final age = NutritionUtils.millisecondsToYears(birthMillis);
      // Should be 25 (birthday not passed yet in Feb 2026)
      expect(age, 25);
    });

    test('returns 0 for current year birth', () {
      // Person born this year, in January
      final birthMillis = DateTime(2026, 1, 1).millisecondsSinceEpoch;
      final age = NutritionUtils.millisecondsToYears(birthMillis);
      expect(age, 0);
    });
  });
}
