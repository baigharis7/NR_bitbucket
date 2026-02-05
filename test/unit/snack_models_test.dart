import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

/// Snack test scenarios (TS-SN0001 through TS-SN0016).
///
/// The Add Food flow uses the same widgets for all meal types.
/// Widget-level behavior is covered by the Breakfast widget tests.
/// These tests verify the Snack-specific data paths (mealTime: 3).
/// Note: Snack has an empty default time, requiring user input.

void main() {
  FoodInFavorite createIngredient({
    int id = 400,
    int qty = 60,
    int unit = -1,
    int conversionFactor = 0,
    int cookingMethod = -1,
    int? usedOil,
  }) {
    return FoodInFavorite(
      id: id,
      qty: qty,
      unit: unit,
      conversionFactor: conversionFactor,
      cookingMethod: cookingMethod,
      usedOil: usedOil,
    );
  }

  // ===========================================================
  // TS-SN0001: Add single snack item
  // ===========================================================
  group('TS-SN0001: Single snack item model', () {
    test('single snack item with mealTime 3', () {
      final entry = FoodFavorite(
        ingredients: [createIngredient(id: 400, qty: 100, unit: -1)],
        drinks: [],
        mealTime: 3, // Snack
      );

      expect(entry.mealTime, 3);
      expect(entry.ingredients.length, 1);
      expect(entry.ingredients.first.conversionFactor, 0);
      expect(entry.ingredients.first.cookingMethod, -1);
    });
  });

  // ===========================================================
  // TS-SN0002: Add multi snack items
  // ===========================================================
  group('TS-SN0002: Multi-item snack dish model', () {
    test('multi-item snack dish', () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(id: 400, qty: 50),
          createIngredient(id: 401, qty: 30),
        ],
        drinks: [],
        mealTime: 3,
        title: 'Afternoon Snack',
      );

      expect(dish.mealTime, 3);
      expect(dish.ingredients.length, 2);
      expect(dish.title, 'Afternoon Snack');
    });
  });

  // ===========================================================
  // TS-SN0003: Remove ingredient while adding
  // ===========================================================
  group('TS-SN0003: Remove ingredient from snack dish', () {
    test('removing ingredient reduces count', () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(id: 400),
          createIngredient(id: 401),
          createIngredient(id: 402),
        ],
        drinks: [],
        mealTime: 3,
      );

      dish.ingredients.removeWhere((food) => food.id == 401);

      expect(dish.ingredients.length, 2);
      expect(dish.ingredients.any((f) => f.id == 401), isFalse);
    });
  });

  // ===========================================================
  // TS-SN0005 / TS-SN0006: Snack favorites
  // ===========================================================
  group('TS-SN0005 & TS-SN0006: Snack favorite models', () {
    test('single-item snack favorite', () {
      final fav = FoodFavorite(
        ingredients: [createIngredient(id: 400, qty: 100)],
        drinks: [],
        mealTime: 3,
        isFavorite: true,
      );

      expect(fav.mealTime, 3);
      expect(fav.isFavorite, isTrue);
    });

    test('multi-item snack favorite requires title', () {
      final fav = FoodFavorite(
        ingredients: [
          createIngredient(id: 400),
          createIngredient(id: 401),
        ],
        drinks: [],
        mealTime: 3,
        isFavorite: true,
        title: 'Trail Mix',
      );

      expect(fav.isFavorite, isTrue);
      expect(fav.title, 'Trail Mix');
      expect(fav.ingredients.length, 2);
    });
  });

  // ===========================================================
  // TS-SN0007 / TS-SN0008: Snack routines
  // Snack has empty default time — requires user-provided time.
  // ===========================================================
  group('TS-SN0007 & TS-SN0008: Snack routine models', () {
    test('single-item snack routine with user-provided time', () {
      final routine = FoodFavorite(
        ingredients: [createIngredient(id: 400, qty: 50)],
        drinks: [],
        mealTime: 3, // Snack
        isRoutine: true,
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '16:00', // User-provided (Snack has no default)
      );

      expect(routine.mealTime, 3);
      expect(routine.isRoutine, isTrue);
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.time, '16:00');
    });

    test('multi-item snack routine with name and user-provided time', () {
      final routine = FoodFavorite(
        ingredients: [
          createIngredient(id: 400),
          createIngredient(id: 401),
        ],
        drinks: [],
        mealTime: 3,
        isRoutine: true,
        daysOfWeek: [1, 3, 5],
        time: '10:30',
        title: 'Mid-Morning Snack',
      );

      expect(routine.title, 'Mid-Morning Snack');
      expect(routine.time, '10:30');
      expect(routine.daysOfWeek!.length, 3);
    });
  });

  // ===========================================================
  // TS-SN0014: FAB + Snack navigation
  // ===========================================================
  group('TS-SN0014: FAB + Snack navigation via FoodArgumentsModel', () {
    test('creates model with Snack meal time (id: 3, empty time)', () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 3, name: 'snack', time: ''),
        selectedDateTime: DateTime(2024, 1, 15),
      );

      expect(model.mealTime.id, 3);
      expect(model.mealTime.name, 'snack');
      expect(model.mealTime.time, ''); // Empty — user must pick time
      expect(model.selectedDateTime, DateTime(2024, 1, 15));
    });
  });

  // ===========================================================
  // TS-SN0015: Snack MealTime
  // ===========================================================
  group('TS-SN0015: Snack MealTime model', () {
    test('Snack has id 3 and empty default time', () {
      final snack = MealTime(id: 3, name: 'snack', time: '');
      expect(snack.id, 3);
      expect(snack.time, isEmpty);
    });
  });

  // ===========================================================
  // Save flow mappers with Snack meal type
  // ===========================================================
  group('Snack save flow mappers', () {
    test('mapToFoodEventSimpleFromFoodFavorite maps snack fields', () {
      final favorite = FoodFavorite(
        userId: 'user1',
        eventId: 7000,
        eventDate: 1700000000,
        ingredients: [
          createIngredient(id: 400, qty: 100),
          createIngredient(id: 401, qty: 50),
        ],
        drinks: [],
        mealTime: 3,
        title: 'Snack Plate',
        dish: true,
      );

      final simple = mapToFoodEventSimpleFromFoodFavorite(favorite);

      expect(simple.mealType, 3);
      expect(simple.foodName, 'Snack Plate');
      expect(simple.ingredients!.length, 2);
    });

    test('mapToFoodRoutineEventFromFoodFavorite maps snack routine with user time',
        () {
      final favorite = FoodFavorite(
        userId: 'user1',
        eventId: 8000,
        eventDate: 1700000000,
        ingredients: [createIngredient(id: 400, qty: 50)],
        drinks: [],
        mealTime: 3,
        title: 'Daily Snack',
        isRoutine: true,
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '16:00', // User-provided time for Snack
        timeZone: 'Europe/Madrid',
      );

      final routine = mapToFoodRoutineEventFromFoodFavorite(favorite);

      expect(routine.mealType, 3);
      expect(routine.foodName, 'Daily Snack');
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.time, '16:00');
    });
  });
}
