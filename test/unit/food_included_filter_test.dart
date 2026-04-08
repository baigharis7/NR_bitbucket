import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/foods_and_drinks_names_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/master_files_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/reference_data_service.dart';

void main() {
  group('FoodItemEntity - included field', () {
    test('defaults to 0', () {
      final entity = FoodItemEntity(id: 1, en: 'Apple', es: 'Manzana', g: 'fruits', units: 'g');
      expect(entity.included, 0);
    });

    test('can be set to 1', () {
      final entity = FoodItemEntity(id: 1, en: 'Apple', es: 'Manzana', g: 'fruits', units: 'g', included: 1);
      expect(entity.included, 1);
    });

    test('JSON round-trip preserves included', () {
      final entity = FoodItemEntity(id: 1, en: 'Apple', es: 'Manzana', g: 'fruits', units: 'g', included: 1);
      final json = entity.toJson();
      expect(json['included'], 1);

      final restored = FoodItemEntity.fromJson(json);
      expect(restored.included, 1);
    });

    test('JSON deserialization defaults missing included to 0', () {
      final json = {'id': 1, 'en': 'Apple', 'es': 'Manzana', 'g': 'fruits', 'units': 'g'};
      final entity = FoodItemEntity.fromJson(json);
      expect(entity.included, 0);
    });
  });

  group('FoodItemMaster - included field', () {
    test('defaults to 0', () {
      final master = FoodItemMaster(id: 1, en: 'Apple', es: 'Manzana', group: 'fruits', units: 'g');
      expect(master.included, 0);
    });

    test('JSON round-trip preserves included', () {
      final master = FoodItemMaster(id: 1, en: 'Apple', es: 'Manzana', group: 'fruits', units: 'g', included: 1);
      final json = master.toJson();
      expect(json['included'], 1);

      final restored = FoodItemMaster.fromJson(json);
      expect(restored.included, 1);
    });

    test('FoodItemMaster.empty() defaults included to 0', () {
      final master = FoodItemMaster.empty();
      expect(master.included, 0);
    });
  });

  group('Mapper - included field carried through', () {
    test('mapToFoodsAndDrinksNamesMaster preserves included from entity', () {
      final entity = FoodsAndDrinksNamesEntity(
        id: 0,
        v: 1,
        data: FoodsAndDrinkListsEntity(
          foodNames: [
            FoodItemEntity(id: 1, en: 'Apple', es: 'Manzana', g: 'fruits', units: 'g', included: 0),
            FoodItemEntity(id: 2, en: 'Rare Berry', es: 'Baya Rara', g: 'fruits', units: 'g', included: 1),
          ],
          drinkNames: [
            FoodItemEntity(id: 3, en: 'Water', es: 'Agua', g: 'drinks', units: 'ml', included: 0),
          ],
        ),
      );

      final master = mapToFoodsAndDrinksNamesMaster(entity);

      expect(master.foodsAndDrinksNames!.foodNames![0].included, 0);
      expect(master.foodsAndDrinksNames!.foodNames![1].included, 1);
      expect(master.foodsAndDrinksNames!.drinkNames![0].included, 0);
    });
  });

  group('Filtering included foods', () {
    test('removeWhere included==1 filters out excluded foods', () {
      final foods = [
        FoodItemMaster(id: 1, en: 'Apple', es: 'Manzana', included: 0),
        FoodItemMaster(id: 2, en: 'Rare Berry', es: 'Baya Rara', included: 1),
        FoodItemMaster(id: 3, en: 'Banana', es: 'Plátano', included: 0),
        FoodItemMaster(id: 4, en: 'Secret Herb', es: 'Hierba Secreta', included: 1),
      ];

      foods.removeWhere((f) => f.included == 1);

      expect(foods.length, 2);
      expect(foods.map((f) => f.id).toList(), [1, 3]);
    });

    test('all foods with included==0 are retained', () {
      final foods = [
        FoodItemMaster(id: 1, en: 'Apple', included: 0),
        FoodItemMaster(id: 2, en: 'Rice', included: 0),
      ];

      foods.removeWhere((f) => f.included == 1);

      expect(foods.length, 2);
    });

    test('all foods with included==1 are removed', () {
      final foods = [
        FoodItemMaster(id: 1, en: 'Rare A', included: 1),
        FoodItemMaster(id: 2, en: 'Rare B', included: 1),
      ];

      foods.removeWhere((f) => f.included == 1);

      expect(foods, isEmpty);
    });
  });

  group('ReferenceDataService - onNutrientsUpdated callback', () {
    late ReferenceDatabase db;
    late ReferenceDataService service;

    setUp(() {
      db = ReferenceDatabase(NativeDatabase.memory());
      service = ReferenceDataService(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('onNutrientsUpdated is called after loadNutrientsJson', () async {
      var callbackCalled = false;
      service.onNutrientsUpdated = () async {
        callbackCalled = true;
      };

      final json = jsonEncode([
        {'id': 1, 'isFood': 0, 'g': 'a', 'en': 'Test', 'es': 'Prueba', 'params': {}, 'included': 1},
      ]);

      await service.loadNutrientsJson(json);

      expect(callbackCalled, true);
    });

    test('loadNutrientsJson stores included field in Drift', () async {
      final json = jsonEncode([
        {'id': 1, 'isFood': 0, 'g': 'a', 'en': 'Visible', 'es': 'Visible', 'params': {}, 'included': 0},
        {'id': 2, 'isFood': 0, 'g': 'a', 'en': 'Hidden', 'es': 'Oculto', 'params': {}, 'included': 1},
      ]);

      await service.loadNutrientsJson(json);

      final comp1 = await db.getNutrientComposition(1);
      final comp2 = await db.getNutrientComposition(2);
      expect(comp1!.included, 0);
      expect(comp2!.included, 1);
    });

    test('onNutrientsUpdated is not called when callback is null', () async {
      // No callback set — should not throw
      final json = jsonEncode([
        {'id': 1, 'isFood': 0, 'g': 'a', 'en': 'Test', 'es': 'Prueba', 'params': {}},
      ]);

      await service.loadNutrientsJson(json);
      // No assertion needed — just verifying it doesn't throw
    });
  });
}
