import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_arguments_model.dart';

void main() {
  group('FoodArgumentsModel Tests', () {
    test('should have preSelectFavorite default to false', () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'Breakfast'),
        selectedDateTime: DateTime.now(),
      );

      expect(model.preSelectFavorite, false);
    });

    test('should set preSelectFavorite to true when specified', () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'Breakfast'),
        selectedDateTime: DateTime.now(),
        preSelectFavorite: true,
      );

      expect(model.preSelectFavorite, true);
    });

    test('should have preSelectRoutine default to false', () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'Breakfast'),
        selectedDateTime: DateTime.now(),
      );

      expect(model.preSelectRoutine, false);
    });

    test('should set preSelectRoutine to true when specified', () {
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'Breakfast'),
        selectedDateTime: DateTime.now(),
        preSelectRoutine: true,
      );

      expect(model.preSelectRoutine, true);
    });

    test('should allow both preSelectFavorite and preSelectRoutine to be set independently', () {
      final modelWithFavorite = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'Breakfast'),
        selectedDateTime: DateTime.now(),
        preSelectFavorite: true,
        preSelectRoutine: false,
      );

      final modelWithRoutine = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'Breakfast'),
        selectedDateTime: DateTime.now(),
        preSelectFavorite: false,
        preSelectRoutine: true,
      );

      expect(modelWithFavorite.preSelectFavorite, true);
      expect(modelWithFavorite.preSelectRoutine, false);
      expect(modelWithRoutine.preSelectFavorite, false);
      expect(modelWithRoutine.preSelectRoutine, true);
    });

    test('should store mealTime correctly', () {
      final mealTime = MealTime(id: 1, name: 'Lunch');
      final model = FoodArgumentsModel(
        mealTime: mealTime,
        selectedDateTime: DateTime.now(),
      );

      expect(model.mealTime.id, 1);
      expect(model.mealTime.name, 'Lunch');
    });

    test('should store selectedDateTime correctly', () {
      final dateTime = DateTime(2024, 1, 15, 12, 30);
      final model = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'Breakfast'),
        selectedDateTime: dateTime,
      );

      expect(model.selectedDateTime.year, 2024);
      expect(model.selectedDateTime.month, 1);
      expect(model.selectedDateTime.day, 15);
    });
  });

  group('SportArgumentsModel Tests', () {
    test('should have preSelectFavorite default to false', () {
      final model = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
      );

      expect(model.preSelectFavorite, false);
    });

    test('should set preSelectFavorite to true when specified', () {
      final model = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
        preSelectFavorite: true,
      );

      expect(model.preSelectFavorite, true);
    });

    test('should have preSelectRoutine default to false', () {
      final model = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
      );

      expect(model.preSelectRoutine, false);
    });

    test('should set preSelectRoutine to true when specified', () {
      final model = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
        preSelectRoutine: true,
      );

      expect(model.preSelectRoutine, true);
    });

    test('should allow both preSelectFavorite and preSelectRoutine to be set independently', () {
      final modelWithFavorite = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
        preSelectFavorite: true,
        preSelectRoutine: false,
      );

      final modelWithRoutine = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
        preSelectFavorite: false,
        preSelectRoutine: true,
      );

      expect(modelWithFavorite.preSelectFavorite, true);
      expect(modelWithFavorite.preSelectRoutine, false);
      expect(modelWithRoutine.preSelectFavorite, false);
      expect(modelWithRoutine.preSelectRoutine, true);
    });

    test('should store selectedDateTime correctly', () {
      final dateTime = DateTime(2024, 1, 15, 14, 45);
      final model = SportArgumentsModel(
        selectedDateTime: dateTime,
      );

      expect(model.selectedDateTime.year, 2024);
      expect(model.selectedDateTime.month, 1);
      expect(model.selectedDateTime.day, 15);
      expect(model.selectedDateTime.hour, 14);
      expect(model.selectedDateTime.minute, 45);
    });
  });

  group('MealTime Tests', () {
    test('MealTime can be created with id and name', () {
      final mealTime = MealTime(id: 0, name: 'Breakfast');

      expect(mealTime.id, 0);
      expect(mealTime.name, 'Breakfast');
    });

    test('MealTime can represent different meal types', () {
      final breakfast = MealTime(id: 0, name: 'Breakfast');
      final lunch = MealTime(id: 1, name: 'Lunch');
      final dinner = MealTime(id: 2, name: 'Dinner');
      final snack = MealTime(id: 3, name: 'Snack');

      expect(breakfast.id, 0);
      expect(lunch.id, 1);
      expect(dinner.id, 2);
      expect(snack.id, 3);
    });
  });

  group('FAB Navigation Logic Tests', () {
    test('favorites screen should create FoodArgumentsModel with preSelectFavorite true for meals', () {
      // Simulate what the favorites screen does when FAB is pressed on Meal tab
      final mealTime = MealTime(id: 0, name: 'Breakfast');
      final model = FoodArgumentsModel(
        mealTime: mealTime,
        selectedDateTime: DateTime.now(),
        preSelectFavorite: true, // Favorites screen sets this to true
      );

      expect(model.preSelectFavorite, true);
    });

    test('favorites screen should create SportArgumentsModel with preSelectFavorite true for sports', () {
      // Simulate what the favorites screen does when FAB is pressed on Physical Activity tab
      final model = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
        preSelectFavorite: true, // Favorites screen sets this to true
      );

      expect(model.preSelectFavorite, true);
    });

    test('routines screen should create FoodArgumentsModel with preSelectRoutine true for meals', () {
      // Simulate what the routines screen does when FAB is pressed on Meal tab
      final mealTime = MealTime(id: 0, name: 'Breakfast');
      final model = FoodArgumentsModel(
        mealTime: mealTime,
        selectedDateTime: DateTime.now(),
        preSelectRoutine: true, // Routines screen sets this to true
      );

      expect(model.preSelectRoutine, true);
      expect(model.preSelectFavorite, false); // Should not affect favorite
    });

    test('routines screen should create SportArgumentsModel with preSelectRoutine true for sports', () {
      // Simulate what the routines screen does when FAB is pressed on Physical Activity tab
      final model = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
        preSelectRoutine: true, // Routines screen sets this to true
      );

      expect(model.preSelectRoutine, true);
      expect(model.preSelectFavorite, false); // Should not affect favorite
    });

    test('favorites and routines screens should have mutually exclusive pre-selections', () {
      final mealTime = MealTime(id: 0, name: 'Breakfast');

      // When coming from favorites screen
      final favoritesFoodModel = FoodArgumentsModel(
        mealTime: mealTime,
        selectedDateTime: DateTime.now(),
        preSelectFavorite: true,
      );
      final favoritesSportModel = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
        preSelectFavorite: true,
      );

      // When coming from routines screen
      final routinesFoodModel = FoodArgumentsModel(
        mealTime: mealTime,
        selectedDateTime: DateTime.now(),
        preSelectRoutine: true,
      );
      final routinesSportModel = SportArgumentsModel(
        selectedDateTime: DateTime.now(),
        preSelectRoutine: true,
      );

      // Verify favorites models
      expect(favoritesFoodModel.preSelectFavorite, true);
      expect(favoritesFoodModel.preSelectRoutine, false);
      expect(favoritesSportModel.preSelectFavorite, true);
      expect(favoritesSportModel.preSelectRoutine, false);

      // Verify routines models
      expect(routinesFoodModel.preSelectFavorite, false);
      expect(routinesFoodModel.preSelectRoutine, true);
      expect(routinesSportModel.preSelectFavorite, false);
      expect(routinesSportModel.preSelectRoutine, true);
    });
  });
}
