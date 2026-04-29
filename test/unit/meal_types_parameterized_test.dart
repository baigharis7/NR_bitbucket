import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';

/// Parameterized tests for all four meal types (Breakfast=0, Lunch=1,
/// Dinner=2, Snack=3).
///
/// The CRUD logic is identical across meal types — the same FoodFavorite
/// and FoodInFavorite classes are used, with only the integer mealTime
/// field changing. This file exercises the meal-type-specific data paths
/// (mealTime preserved through save → MealTime model → mapper) for all
/// four types via a single set of parameterized tests.
///
/// **Detailed CRUD coverage** (cooking methods, oils, conversion factors,
/// remove ingredient, multi-item dishes, routine creation, favorite
/// creation) lives in `breakfast_models_test.dart` and applies to all
/// meal types since the underlying classes don't branch on mealTime.
///
/// Replaces:
///   - lunch_models_test.dart (283 lines)
///   - dinner_models_test.dart (283 lines)
///   - snack_models_test.dart (247 lines)
void main() {
  // (id, name, default time) per meal type.
  final mealTypes = <({int id, String name, String defaultTime})>[
    (id: 0, name: 'breakfast', defaultTime: '07:30'),
    (id: 1, name: 'lunch', defaultTime: '13:30'),
    (id: 2, name: 'dinner', defaultTime: '20:30'),
    (id: 3, name: 'snack', defaultTime: ''), // Snack has no default time
  ];

  FoodInFavorite makeIngredient({int id = 100, int qty = 100}) {
    return FoodInFavorite(
      id: id,
      qty: qty,
      unit: -1,
      conversionFactor: 0,
      cookingMethod: -1,
      usedOil: null,
    );
  }

  for (final m in mealTypes) {
    group('${m.name} (mealTime ${m.id})', () {
      test('FoodFavorite preserves mealTime ${m.id}', () {
        final entry = FoodFavorite(
          ingredients: [makeIngredient()],
          drinks: [],
          mealTime: m.id,
        );
        expect(entry.mealTime, m.id);
        expect(entry.ingredients.length, 1);
      });

      test('Multi-item dish preserves mealTime ${m.id}', () {
        final entry = FoodFavorite(
          ingredients: [makeIngredient(id: 1), makeIngredient(id: 2)],
          drinks: [],
          mealTime: m.id,
          title: '${m.name} dish',
          dish: true,
        );
        expect(entry.mealTime, m.id);
        expect(entry.ingredients.length, 2);
        expect(entry.title, '${m.name} dish');
      });

      test('Routine preserves mealTime ${m.id} with days/time', () {
        final routine = FoodFavorite(
          userId: 'user1',
          eventId: 1000,
          eventDate: 1700000000,
          ingredients: [makeIngredient()],
          drinks: [],
          mealTime: m.id,
          isRoutine: true,
          daysOfWeek: [1, 3, 5],
          time: m.defaultTime.isEmpty ? '15:00' : m.defaultTime,
          timeZone: 'UTC',
        );
        expect(routine.mealTime, m.id);
        expect(routine.daysOfWeek, [1, 3, 5]);
      });

      test('FoodArgumentsModel carries mealTime ${m.id}', () {
        final model = FoodArgumentsModel(
          mealTime: MealTime(id: m.id, name: m.name, time: m.defaultTime),
          selectedDateTime: DateTime(2024, 1, 15),
        );
        expect(model.mealTime.id, m.id);
        expect(model.mealTime.name, m.name);
        expect(model.mealTime.time, m.defaultTime);
      });

      test('MealTime model has correct id and default time for ${m.name}',
          () {
        final mealTime = MealTime(id: m.id, name: m.name, time: m.defaultTime);
        expect(mealTime.id, m.id);
        expect(mealTime.time, m.defaultTime);
      });

      test('mapToFoodEventSimpleFromFoodFavorite preserves mealType ${m.id}',
          () {
        final favorite = FoodFavorite(
          userId: 'user1',
          eventId: 2000,
          eventDate: 1700000000,
          ingredients: [
            makeIngredient(id: 100, qty: 150),
            makeIngredient(id: 101, qty: 100),
          ],
          drinks: [],
          mealTime: m.id,
          title: '${m.name} plate',
          dish: true,
        );

        final simple = mapToFoodEventSimpleFromFoodFavorite(favorite);

        expect(simple.mealType, m.id);
        expect(simple.foodName, '${m.name} plate');
        expect(simple.ingredients!.length, 2);
      });

      test('mapToFoodRoutineEventFromFoodFavorite preserves mealType ${m.id}',
          () {
        final favorite = FoodFavorite(
          userId: 'user1',
          eventId: 3000,
          eventDate: 1700000000,
          ingredients: [makeIngredient()],
          drinks: [],
          mealTime: m.id,
          title: 'Daily ${m.name}',
          isRoutine: true,
          daysOfWeek: [1, 3, 5],
          time: m.defaultTime.isEmpty ? '15:00' : m.defaultTime,
          timeZone: 'Europe/Madrid',
        );

        final routine = mapToFoodRoutineEventFromFoodFavorite(favorite);

        expect(routine.mealType, m.id);
        expect(routine.foodName, 'Daily ${m.name}');
        expect(routine.daysOfWeek, [1, 3, 5]);
      });
    });
  }
}
