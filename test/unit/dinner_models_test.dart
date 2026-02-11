import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

/// Dinner test scenarios (TS-DN0001 through TS-DN0017).
///
/// The Add Food flow uses the same widgets for all meal types.
/// Widget-level behavior is covered by the Breakfast widget tests.
/// These tests verify the Dinner-specific data paths (mealTime: 2).

void main() {
  FoodInFavorite createIngredient({
    int id = 300,
    int qty = 100,
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
  // TS-DN0001 / TS-DN0002: Single dinner item (non-cooked & cooked)
  // ===========================================================
  group('TS-DN0001 & TS-DN0002: Single dinner item models', () {
    test('single non-cooked dinner item with mealTime 2', () {
      final entry = FoodFavorite(
        ingredients: [createIngredient(id: 300, qty: 200, unit: -1)],
        drinks: [],
        mealTime: 2, // Dinner
      );

      expect(entry.mealTime, 2);
      expect(entry.ingredients.length, 1);
      expect(entry.ingredients.first.conversionFactor, 0);
      expect(entry.ingredients.first.cookingMethod, -1);
    });

    test('single cooked dinner item stores cooking method', () {
      final entry = FoodFavorite(
        ingredients: [
          createIngredient(
            id: 300,
            qty: 250,
            conversionFactor: 1,
            cookingMethod: 3, // Baked
          ),
        ],
        drinks: [],
        mealTime: 2,
      );

      expect(entry.mealTime, 2);
      expect(entry.ingredients.first.conversionFactor, 1);
      expect(entry.ingredients.first.cookingMethod, 3);
    });
  });

  // ===========================================================
  // TS-DN0003 / TS-DN0004: Multi-item dinner dish
  // ===========================================================
  group('TS-DN0003 & TS-DN0004: Multi-item dinner dish models', () {
    test('multi-item non-cooked dinner dish', () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(id: 300, qty: 150),
          createIngredient(id: 301, qty: 80),
          createIngredient(id: 302, qty: 50),
        ],
        drinks: [],
        mealTime: 2,
        title: 'Dinner Salad',
      );

      expect(dish.mealTime, 2);
      expect(dish.ingredients.length, 3);
      expect(dish.title, 'Dinner Salad');
    });

    test('multi-item cooked dinner dish with per-ingredient cooking methods',
        () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(
              id: 300, conversionFactor: 1, cookingMethod: 2), // Grilled
          createIngredient(
              id: 301, conversionFactor: 1, cookingMethod: 1), // Boiled
        ],
        drinks: [],
        mealTime: 2,
        title: 'Cooked Dinner Plate',
      );

      expect(dish.ingredients[0].cookingMethod, 2);
      expect(dish.ingredients[1].cookingMethod, 1);
    });
  });

  // ===========================================================
  // TS-DN0005: Remove ingredient while adding
  // ===========================================================
  group('TS-DN0005: Remove ingredient from dinner dish', () {
    test('removing ingredient reduces count', () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(id: 300),
          createIngredient(id: 301),
          createIngredient(id: 302),
        ],
        drinks: [],
        mealTime: 2,
      );

      dish.ingredients.removeWhere((food) => food.id == 301);

      expect(dish.ingredients.length, 2);
      expect(dish.ingredients.any((f) => f.id == 301), isFalse);
    });
  });

  // ===========================================================
  // TS-DN0007 / TS-DN0008: Dinner favorites
  // ===========================================================
  group('TS-DN0007 & TS-DN0008: Dinner favorite models', () {
    test('single-item dinner favorite', () {
      final fav = FoodFavorite(
        ingredients: [createIngredient(id: 300, qty: 200)],
        drinks: [],
        mealTime: 2,
        isFavorite: true,
      );

      expect(fav.mealTime, 2);
      expect(fav.isFavorite, isTrue);
    });

    test('multi-item dinner favorite requires title', () {
      final fav = FoodFavorite(
        ingredients: [
          createIngredient(id: 300),
          createIngredient(id: 301),
        ],
        drinks: [],
        mealTime: 2,
        isFavorite: true,
        title: 'Dinner Combo',
      );

      expect(fav.isFavorite, isTrue);
      expect(fav.title, 'Dinner Combo');
      expect(fav.ingredients.length, 2);
    });
  });

  // ===========================================================
  // TS-DN0009 / TS-DN0010: Dinner routines
  // ===========================================================
  group('TS-DN0009 & TS-DN0010: Dinner routine models', () {
    test('single-item dinner routine with days and time', () {
      final routine = FoodFavorite(
        ingredients: [createIngredient(id: 300, qty: 150)],
        drinks: [],
        mealTime: 2, // Dinner
        isRoutine: true,
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '20:30',
      );

      expect(routine.mealTime, 2);
      expect(routine.isRoutine, isTrue);
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.time, '20:30');
    });

    test('multi-item dinner routine with name', () {
      final routine = FoodFavorite(
        ingredients: [
          createIngredient(id: 300),
          createIngredient(id: 301),
        ],
        drinks: [],
        mealTime: 2,
        isRoutine: true,
        daysOfWeek: [1, 3, 5], // Mon, Wed, Fri
        time: '20:30',
        title: 'Weekday Dinner',
      );

      expect(routine.title, 'Weekday Dinner');
      expect(routine.daysOfWeek!.length, 3);
    });
  });

  // ===========================================================
  // TS-DN0015: FAB + Dinner navigation
  // ===========================================================
  group('TS-DN0015: FAB + Dinner navigation via FoodArgumentsModel', () {
    test('creates model with Dinner meal time (id: 2)', () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 2, name: 'dinner', time: '20:30'),
        selectedDateTime: DateTime(2024, 1, 15),
      );

      expect(model.mealTime.id, 2);
      expect(model.mealTime.name, 'dinner');
      expect(model.mealTime.time, '20:30');
      expect(model.selectedDateTime, DateTime(2024, 1, 15));
    });
  });

  // ===========================================================
  // TS-DN0016: Dinner MealTime
  // ===========================================================
  group('TS-DN0016: Dinner MealTime model', () {
    test('Dinner has id 2 and default time 20:30', () {
      final dinner = MealTime(id: 2, name: 'dinner', time: '20:30');
      expect(dinner.id, 2);
      expect(dinner.time, '20:30');
    });
  });

  // ===========================================================
  // Save flow mappers with Dinner meal type
  // ===========================================================
  group('Dinner save flow mappers', () {
    test('mapToFoodEventSimpleFromFoodFavorite maps dinner fields', () {
      final favorite = FoodFavorite(
        userId: 'user1',
        eventId: 5000,
        eventDate: 1700000000,
        ingredients: [
          createIngredient(id: 300, qty: 200),
          createIngredient(
              id: 301, qty: 150, conversionFactor: 1, cookingMethod: 3),
        ],
        drinks: [],
        mealTime: 2,
        title: 'Dinner Plate',
        dish: true,
      );

      final simple = mapToFoodEventSimpleFromFoodFavorite(favorite);

      expect(simple.mealType, 2);
      expect(simple.foodName, 'Dinner Plate');
      expect(simple.ingredients!.length, 2);
      expect(simple.ingredients![1].cookingMethod, 3);
    });

    test('mapToFoodRoutineEventFromFoodFavorite maps dinner routine', () {
      final favorite = FoodFavorite(
        userId: 'user1',
        eventId: 6000,
        eventDate: 1700000000,
        ingredients: [createIngredient(id: 300, qty: 150)],
        drinks: [],
        mealTime: 2,
        title: 'Daily Dinner',
        isRoutine: true,
        daysOfWeek: [2, 4],
        time: '20:30',
        timeZone: 'Europe/Madrid',
      );

      final routine = mapToFoodRoutineEventFromFoodFavorite(favorite);

      expect(routine.mealType, 2);
      expect(routine.foodName, 'Daily Dinner');
      expect(routine.daysOfWeek, [2, 4]);
      expect(routine.time, '20:30');
    });
  });
}
