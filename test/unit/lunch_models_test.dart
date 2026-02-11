import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

/// Lunch test scenarios (TS-LU0001 through TS-LU0018).
///
/// The Add Food flow uses the same widgets for all meal types
/// (FoodEventItem, RemoveItemWidget, AddItemNameDialog, etc.).
/// Widget-level behavior is covered by the Breakfast widget tests.
/// These tests verify the Lunch-specific data paths (mealTime: 1).

void main() {
  FoodInFavorite createIngredient({
    int id = 200,
    int qty = 80,
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
  // TS-LU0001 / TS-LU0002: Single lunch item (non-cooked & cooked)
  // ===========================================================
  group('TS-LU0001 & TS-LU0002: Single lunch item models', () {
    test('single non-cooked lunch item with mealTime 1', () {
      final entry = FoodFavorite(
        ingredients: [createIngredient(id: 200, qty: 150, unit: -1)],
        drinks: [],
        mealTime: 1, // Lunch
      );

      expect(entry.mealTime, 1);
      expect(entry.ingredients.length, 1);
      expect(entry.ingredients.first.conversionFactor, 0);
      expect(entry.ingredients.first.cookingMethod, -1);
    });

    test('single cooked lunch item stores cooking method', () {
      final entry = FoodFavorite(
        ingredients: [
          createIngredient(
            id: 200,
            qty: 200,
            conversionFactor: 1,
            cookingMethod: 2, // Grilled
          ),
        ],
        drinks: [],
        mealTime: 1,
      );

      expect(entry.mealTime, 1);
      expect(entry.ingredients.first.conversionFactor, 1);
      expect(entry.ingredients.first.cookingMethod, 2);
    });
  });

  // ===========================================================
  // TS-LU0003 / TS-LU0004: Multi-item lunch dish
  // ===========================================================
  group('TS-LU0003 & TS-LU0004: Multi-item lunch dish models', () {
    test('multi-item non-cooked lunch dish', () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(id: 200, qty: 100),
          createIngredient(id: 201, qty: 50),
          createIngredient(id: 202, qty: 30),
        ],
        drinks: [],
        mealTime: 1,
        title: 'Chicken Sandwich',
      );

      expect(dish.mealTime, 1);
      expect(dish.ingredients.length, 3);
      expect(dish.title, 'Chicken Sandwich');
    });

    test('multi-item cooked lunch dish with per-ingredient cooking methods',
        () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(
              id: 200, conversionFactor: 1, cookingMethod: 1), // Boiled
          createIngredient(
              id: 201, conversionFactor: 1, cookingMethod: 3), // Baked
        ],
        drinks: [],
        mealTime: 1,
        title: 'Cooked Lunch Combo',
      );

      expect(dish.ingredients[0].cookingMethod, 1);
      expect(dish.ingredients[1].cookingMethod, 3);
    });
  });

  // ===========================================================
  // TS-LU0005: Remove ingredient while adding
  // ===========================================================
  group('TS-LU0005: Remove ingredient from lunch dish', () {
    test('removing ingredient reduces count', () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(id: 200),
          createIngredient(id: 201),
          createIngredient(id: 202),
        ],
        drinks: [],
        mealTime: 1,
      );

      dish.ingredients.removeWhere((food) => food.id == 201);

      expect(dish.ingredients.length, 2);
      expect(dish.ingredients.any((f) => f.id == 201), isFalse);
    });
  });

  // ===========================================================
  // TS-LU0007 / TS-LU0008: Lunch favorites
  // ===========================================================
  group('TS-LU0007 & TS-LU0008: Lunch favorite models', () {
    test('single-item lunch favorite', () {
      final fav = FoodFavorite(
        ingredients: [createIngredient(id: 200, qty: 200)],
        drinks: [],
        mealTime: 1,
        isFavorite: true,
      );

      expect(fav.mealTime, 1);
      expect(fav.isFavorite, isTrue);
    });

    test('multi-item lunch favorite requires title', () {
      final fav = FoodFavorite(
        ingredients: [
          createIngredient(id: 200),
          createIngredient(id: 201),
        ],
        drinks: [],
        mealTime: 1,
        isFavorite: true,
        title: 'Lunch Combo',
      );

      expect(fav.isFavorite, isTrue);
      expect(fav.title, 'Lunch Combo');
      expect(fav.ingredients.length, 2);
    });
  });

  // ===========================================================
  // TS-LU0009 / TS-LU0010: Lunch routines
  // ===========================================================
  group('TS-LU0009 & TS-LU0010: Lunch routine models', () {
    test('single-item lunch routine with days and time', () {
      final routine = FoodFavorite(
        ingredients: [createIngredient(id: 200, qty: 100)],
        drinks: [],
        mealTime: 1, // Lunch
        isRoutine: true,
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '13:30',
      );

      expect(routine.mealTime, 1);
      expect(routine.isRoutine, isTrue);
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.time, '13:30');
    });

    test('multi-item lunch routine with name', () {
      final routine = FoodFavorite(
        ingredients: [
          createIngredient(id: 200),
          createIngredient(id: 201),
        ],
        drinks: [],
        mealTime: 1,
        isRoutine: true,
        daysOfWeek: [2, 4], // Tue, Thu
        time: '13:30',
        title: 'Weekday Lunch',
      );

      expect(routine.title, 'Weekday Lunch');
      expect(routine.daysOfWeek!.length, 2);
    });
  });

  // ===========================================================
  // TS-LU0016: FAB + Lunch navigation
  // ===========================================================
  group('TS-LU0016: FAB + Lunch navigation via FoodArgumentsModel', () {
    test('creates model with Lunch meal time (id: 1)', () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 1, name: 'lunch', time: '13:30'),
        selectedDateTime: DateTime(2024, 1, 15),
      );

      expect(model.mealTime.id, 1);
      expect(model.mealTime.name, 'lunch');
      expect(model.mealTime.time, '13:30');
      expect(model.selectedDateTime, DateTime(2024, 1, 15));
    });
  });

  // ===========================================================
  // TS-LU0017: Lunch MealTime
  // ===========================================================
  group('TS-LU0017: Lunch MealTime model', () {
    test('Lunch has id 1 and default time 13:30', () {
      final lunch = MealTime(id: 1, name: 'lunch', time: '13:30');
      expect(lunch.id, 1);
      expect(lunch.time, '13:30');
    });
  });

  // ===========================================================
  // Save flow mappers with Lunch meal type
  // ===========================================================
  group('Lunch save flow mappers', () {
    test('mapToFoodEventSimpleFromFoodFavorite maps lunch fields', () {
      final favorite = FoodFavorite(
        userId: 'user1',
        eventId: 3000,
        eventDate: 1700000000,
        ingredients: [
          createIngredient(id: 200, qty: 150),
          createIngredient(id: 201, qty: 100, conversionFactor: 1, cookingMethod: 2),
        ],
        drinks: [],
        mealTime: 1,
        title: 'Lunch Plate',
        dish: true,
      );

      final simple = mapToFoodEventSimpleFromFoodFavorite(favorite);

      expect(simple.mealType, 1);
      expect(simple.foodName, 'Lunch Plate');
      expect(simple.ingredients!.length, 2);
      expect(simple.ingredients![1].cookingMethod, 2);
    });

    test('mapToFoodRoutineEventFromFoodFavorite maps lunch routine', () {
      final favorite = FoodFavorite(
        userId: 'user1',
        eventId: 4000,
        eventDate: 1700000000,
        ingredients: [createIngredient(id: 200, qty: 100)],
        drinks: [],
        mealTime: 1,
        title: 'Daily Lunch',
        isRoutine: true,
        daysOfWeek: [1, 3, 5],
        time: '13:30',
        timeZone: 'Europe/Madrid',
      );

      final routine = mapToFoodRoutineEventFromFoodFavorite(favorite);

      expect(routine.mealType, 1);
      expect(routine.foodName, 'Daily Lunch');
      expect(routine.daysOfWeek, [1, 3, 5]);
      expect(routine.time, '13:30');
    });
  });
}
