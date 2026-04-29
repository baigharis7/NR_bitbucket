import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

void main() {
  // ---- Helper: create a test ingredient ----
  FoodInFavorite createIngredient({
    int id = 100,
    int qty = 50,
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
  // TS-BF0001 / TS-BF0002: Single item models (non-cooked & cooked)
  // ===========================================================
  group('TS-BF0001 & TS-BF0002: Single food item models', () {
    test('FoodInFavorite defaults to raw (conversionFactor: 0, cookingMethod: -1)',
        () {
      final ingredient = createIngredient();

      expect(ingredient.conversionFactor, 0);
      expect(ingredient.cookingMethod, -1);
      expect(ingredient.usedOil, isNull);
    });

    test('FoodInFavorite with cooked flag stores cooking method', () {
      final ingredient = createIngredient(
        conversionFactor: 1,
        cookingMethod: 2, // Grilled
      );

      expect(ingredient.conversionFactor, 1);
      expect(ingredient.cookingMethod, 2);
    });

    test('FoodFavorite holds single ingredient for a single-item entry', () {
      final entry = FoodFavorite(
        ingredients: [createIngredient(id: 100, qty: 150, unit: -1)],
        drinks: [],
        mealTime: 0, // Breakfast
      );

      expect(entry.ingredients.length, 1);
      expect(entry.ingredients.first.id, 100);
      expect(entry.ingredients.first.qty, 150);
      expect(entry.mealTime, 0);
    });
  });

  // ===========================================================
  // TS-BF0003 / TS-BF0004: Multi-item dish models
  // ===========================================================
  group('TS-BF0003 & TS-BF0004: Multi-item dish models', () {
    test('FoodFavorite holds multiple ingredients for a multi-item dish', () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(id: 100, qty: 50),
          createIngredient(id: 101, qty: 30),
          createIngredient(id: 102, qty: 20),
        ],
        drinks: [],
        mealTime: 0,
        title: 'My Breakfast Bowl',
      );

      expect(dish.ingredients.length, 3);
      expect(dish.title, 'My Breakfast Bowl');
    });

    test('multi-item cooked dish stores cooking method per ingredient', () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(id: 100, conversionFactor: 1, cookingMethod: 1),
          createIngredient(id: 101, conversionFactor: 1, cookingMethod: 3),
        ],
        drinks: [],
        mealTime: 0,
        title: 'Cooked Combo',
      );

      expect(dish.ingredients[0].conversionFactor, 1);
      expect(dish.ingredients[0].cookingMethod, 1); // Boiled
      expect(dish.ingredients[1].cookingMethod, 3); // Baked
    });

    test('removing ingredient from list reduces count (TS-BF0005)', () {
      final dish = FoodFavorite(
        ingredients: [
          createIngredient(id: 100),
          createIngredient(id: 101),
          createIngredient(id: 102),
        ],
        drinks: [],
        mealTime: 0,
      );

      expect(dish.ingredients.length, 3);

      // Simulate removing by id (same logic as bloc)
      dish.ingredients.removeWhere((food) => food.id == 101);

      expect(dish.ingredients.length, 2);
      expect(dish.ingredients.any((f) => f.id == 101), isFalse);
    });
  });

  // ===========================================================
  // TS-BF0007 / TS-BF0008: Favorite models
  // ===========================================================
  group('TS-BF0007 & TS-BF0008: Favorite creation models', () {
    test('single-item favorite has isFavorite flag set', () {
      final fav = FoodFavorite(
        ingredients: [createIngredient(id: 100, qty: 200, unit: -1)],
        drinks: [],
        mealTime: 0,
        isFavorite: true,
      );

      expect(fav.isFavorite, isTrue);
      expect(fav.ingredients.length, 1);
    });

    test('multi-item favorite requires a title', () {
      final fav = FoodFavorite(
        ingredients: [
          createIngredient(id: 100),
          createIngredient(id: 101),
        ],
        drinks: [],
        mealTime: 0,
        isFavorite: true,
        title: 'My Morning Mix',
      );

      expect(fav.isFavorite, isTrue);
      expect(fav.title, 'My Morning Mix');
      expect(fav.ingredients.length, 2);
    });

  });

  // ===========================================================
  // TS-BF0009 / TS-BF0010: Routine models
  // ===========================================================
  group('TS-BF0009 & TS-BF0010: Routine creation models', () {
    test('single-item routine stores days of week and meal time', () {
      final routine = FoodFavorite(
        ingredients: [createIngredient(id: 100, qty: 100)],
        drinks: [],
        mealTime: 0, // Breakfast
        isRoutine: true,
        daysOfWeek: [1, 3, 5], // Mon, Wed, Fri
        time: '07:30',
      );

      expect(routine.isRoutine, isTrue);
      expect(routine.daysOfWeek, [1, 3, 5]);
      expect(routine.mealTime, 0);
      expect(routine.time, '07:30');
    });

    test('multi-item routine requires a name', () {
      final routine = FoodFavorite(
        ingredients: [
          createIngredient(id: 100),
          createIngredient(id: 101),
        ],
        drinks: [],
        mealTime: 0,
        isRoutine: true,
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '07:30',
        title: 'Weekday Breakfast',
      );

      expect(routine.isRoutine, isTrue);
      expect(routine.title, 'Weekday Breakfast');
      expect(routine.daysOfWeek!.length, 5);
    });

    test('toggling a day adds/removes it from daysOfWeek list', () {
      final daysOfWeek = <int>[1, 3, 5];

      // Toggle day 3 (remove)
      final day = 3;
      daysOfWeek.contains(day)
          ? daysOfWeek.remove(day)
          : daysOfWeek.add(day);
      expect(daysOfWeek, [1, 5]);

      // Toggle day 2 (add)
      final day2 = 2;
      daysOfWeek.contains(day2)
          ? daysOfWeek.remove(day2)
          : daysOfWeek.add(day2);
      expect(daysOfWeek, [1, 5, 2]);
    });
  });

  // ===========================================================
  // TS-BF0016: FAB navigation - FoodArgumentsModel
  // ===========================================================
  group('TS-BF0016: FAB + Breakfast navigation via FoodArgumentsModel', () {
    test('creates model with Breakfast meal time (id: 0)', () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'breakfast', time: '07:30'),
        selectedDateTime: DateTime(2024, 1, 15),
      );

      expect(model.mealTime.id, 0);
      expect(model.mealTime.name, 'breakfast');
      expect(model.selectedDateTime, DateTime(2024, 1, 15));
      expect(model.preSelectFavorite, isFalse);
      expect(model.preSelectRoutine, isFalse);
    });

    test('preSelectFavorite flag is passed through (from Favorites screen)',
        () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'breakfast', time: '07:30'),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectFavorite: true,
      );

      expect(model.preSelectFavorite, isTrue);
      expect(model.preSelectRoutine, isFalse);
    });

    test('preSelectRoutine flag is passed through (from Routines screen)', () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'breakfast', time: '07:30'),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectRoutine: true,
      );

      expect(model.preSelectRoutine, isTrue);
      expect(model.preSelectFavorite, isFalse);
    });
  });

  // ===========================================================
  // TS-BF0017: MealTime model
  // ===========================================================
  group('TS-BF0017: MealTime model', () {
    test('MealTime can represent Breakfast with id 0 and time 07:30', () {
      final breakfast = MealTime(id: 0, name: 'breakfast', time: '07:30');
      expect(breakfast.id, 0);
      expect(breakfast.name, 'breakfast');
      expect(breakfast.time, '07:30');
    });

    test('MealTime can represent all 4 meal types', () {
      final meals = [
        MealTime(id: 0, name: 'breakfast', time: '07:30'),
        MealTime(id: 1, name: 'lunch', time: '13:30'),
        MealTime(id: 2, name: 'dinner', time: '20:30'),
        MealTime(id: 3, name: 'snack', time: ''),
      ];

      expect(meals.length, 4);
      expect(meals[0].id, 0);
      expect(meals[1].id, 1);
      expect(meals[2].id, 2);
      expect(meals[3].id, 3);
    });

    test('Snack has empty time (requires user time input)', () {
      final snack = MealTime(id: 3, name: 'snack', time: '');
      expect(snack.time, '');
    });
  });

  // ===========================================================
  // Mapper tests: FoodFavorite → FoodEventSimple / FoodRoutineEvent
  // ===========================================================
  group('Save flow mappers', () {
    test('mapToFoodEventSimpleFromFoodFavorite maps all fields correctly', () {
      final favorite = FoodFavorite(
        userId: 'user1',
        eventId: 1000,
        eventDate: 1700000000,
        ingredients: [
          createIngredient(id: 100, qty: 150, unit: -1, conversionFactor: 0),
          createIngredient(id: 101, qty: 200, unit: 1, conversionFactor: 1, cookingMethod: 2),
        ],
        drinks: [],
        mealTime: 0,
        title: 'Test Meal',
        dish: true,
      );

      final simple = mapToFoodEventSimpleFromFoodFavorite(favorite);

      expect(simple.userId, 'user1');
      expect(simple.eventDate, 1700000000);
      expect(simple.eventId, 1000);
      expect(simple.foodName, 'Test Meal');
      expect(simple.mealType, 0);
      expect(simple.ingredients!.length, 2);
      expect(simple.ingredients![0].id, 100);
      expect(simple.ingredients![0].qty, 150);
      expect(simple.ingredients![1].conversionFactor, 1);
      expect(simple.ingredients![1].cookingMethod, 2);
    });

    test('mapToFoodRoutineEventFromFoodFavorite maps routine fields', () {
      final favorite = FoodFavorite(
        userId: 'user1',
        eventId: 2000,
        eventDate: 1700000000,
        ingredients: [createIngredient(id: 100, qty: 100)],
        drinks: [],
        mealTime: 0,
        title: 'Daily Breakfast',
        isRoutine: true,
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '07:30',
        timeZone: 'Europe/Madrid',
      );

      final routine = mapToFoodRoutineEventFromFoodFavorite(favorite);

      expect(routine.userId, 'user1');
      expect(routine.foodName, 'Daily Breakfast');
      expect(routine.mealType, 0);
      expect(routine.isRoutine, isTrue);
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.time, '07:30');
      expect(routine.timeZone, 'Europe/Madrid');
      expect(routine.ingredients!.length, 1);
      expect(routine.ingredients![0].id, 100);
    });
  });
}
