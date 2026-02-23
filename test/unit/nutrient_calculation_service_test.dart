import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/conversion_factors_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/nutrient_calculation_service.dart';

void main() {
  late ReferenceDatabase db;
  late NutrientCalculationService service;

  setUp(() {
    db = ReferenceDatabase(NativeDatabase.memory());
    service = NutrientCalculationService(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper: insert a nutrient composition into the Drift DB.
  Future<void> _insertComposition({
    required int foodId,
    String group = '1.2.1',
    Map<String, double> params = const {},
    int isFood = 0,
    String nameEn = 'Test Food',
    String nameEs = 'Comida Test',
    int recommendable = 1,
    String? freeSugar,
  }) async {
    await db.into(db.nutrientCompositions).insert(NutrientCompositionsCompanion(
      foodId: Value(foodId),
      isFood: Value(isFood),
      group: Value(group),
      nameEn: Value(nameEn),
      nameEs: Value(nameEs),
      recommendable: Value(recommendable),
      freeSugar: Value(freeSugar),
      params: Value(jsonEncode(params)),
    ));
  }

  Future<void> _insertCookingOil(int cookingMethodId, double percentage) async {
    await db.into(db.cookingMethodOils).insert(CookingMethodOilsCompanion(
      cookingMethodId: Value(cookingMethodId),
      percentage: Value(percentage),
    ));
  }

  Future<void> _insertNutrientLoss(int cookingMethodId, Map<String, double> losses) async {
    await db.into(db.nutrientLosses).insert(NutrientLossesCompanion(
      cookingMethodId: Value(cookingMethodId),
      losses: Value(jsonEncode(losses)),
    ));
  }

  // Standard test data
  final basicUnitsFoods = <UnitFoodEntity>[
    UnitFoodEntity(id: 37, units: '38,1|0,70|1,100|2,150'),
  ];

  final basicConversionFactors = <ConversionFactorInfoEntity>[
    ConversionFactorInfoEntity(
      id: 1,
      value: 'cooked',
      list: [ConversionInfoEntity(g: '1.2.1', v: 2.5)],
    ),
  ];

  group('NutrientCalculationService - Liquid enrichment', () {
    test('computes liquid nutrients with formula: qty * nutrientValue / 100', () async {
      await _insertComposition(
        foodId: 100,
        isFood: 1,
        nameEn: 'Orange Juice',
        params: {'energyKcal': 45.0, 'vitC': 50.0, 'water': 88.0},
      );

      final simple = LiquidEventSimple(
        userId: 'user1',
        date: 20260212,
        drinks: [LiquidInEvent(id: 100, qty: 250)],
      );

      final result = await service.enrichLiquidEvent(simple);

      // 250 * 45 / 100 = 112.5
      expect(result.liquidInfo![0].params!.energyKcal, 112.5);
      // 250 * 50 / 100 = 125.0
      expect(result.liquidInfo![0].params!.vitC, 125.0);
      // 250 * 88 / 100 = 220.0
      expect(result.liquidInfo![0].params!.water, 220.0);
      expect(result.eventKcals, 113); // 112.5 rounded
    });

    test('skips drinks with no composition data', () async {
      final simple = LiquidEventSimple(
        userId: 'user1',
        date: 20260212,
        drinks: [LiquidInEvent(id: 999, qty: 250)],
      );

      final result = await service.enrichLiquidEvent(simple);

      expect(result.liquidInfo, isEmpty);
      expect(result.eventKcals, 0);
    });

    test('sums kcal across multiple drinks', () async {
      await _insertComposition(foodId: 100, params: {'energyKcal': 45.0});
      await _insertComposition(foodId: 101, params: {'energyKcal': 30.0});

      final simple = LiquidEventSimple(
        userId: 'user1',
        date: 20260212,
        drinks: [
          LiquidInEvent(id: 100, qty: 200), // 200 * 45 / 100 = 90
          LiquidInEvent(id: 101, qty: 300), // 300 * 30 / 100 = 90
        ],
      );

      final result = await service.enrichLiquidEvent(simple);

      expect(result.liquidInfo!.length, 2);
      expect(result.eventKcals, 180); // 90 + 90
    });
  });

  group('NutrientCalculationService - Food enrichment', () {
    test('computes basic food nutrients: weight * nutrientValue / 100', () async {
      // Food 37 with unit 0 = 70g per unit
      await _insertComposition(
        foodId: 37,
        group: '3.4',
        params: {'energyKcal': 20.0, 'vitC': 120.0},
      );

      final simple = FoodEventSimple(
        userId: 'user1',
        eventId: 1000,
        eventDate: 20260212,
        mealType: 0,
        foodName: null,
        comment: null,
        ingredients: [
          FoodInEvent(id: 37, qty: 2, unit: 0, cookingMethod: -1),
        ],
      );

      final result = await service.enrichFoodEvent(
        simple,
        unitsFoods: basicUnitsFoods,
        conversionFactorsInfo: [],
      );

      // Weight = 2 * 70 = 140g
      // energyKcal = 140 * 20 / 100 = 28.0
      // vitC = 140 * 120 / 100 = 168.0
      expect(result.foodInfo!.length, 1);
      expect(result.foodInfo![0].params!.energyKcal, 28.0);
      expect(result.foodInfo![0].params!.vitC, 168.0);
      expect(result.eventKcals, 28);
    });

    test('applies conversion factor for cooked food', () async {
      await _insertComposition(
        foodId: 37,
        group: '1.2.1',
        params: {'energyKcal': 100.0},
      );

      final simple = FoodEventSimple(
        userId: 'user1',
        eventId: 1001,
        eventDate: 20260212,
        mealType: 0,
        foodName: null,
        comment: null,
        ingredients: [
          FoodInEvent(id: 37, qty: 1, unit: 0, conversionFactor: 1, cookingMethod: -1),
        ],
      );

      final result = await service.enrichFoodEvent(
        simple,
        unitsFoods: basicUnitsFoods,
        conversionFactorsInfo: basicConversionFactors,
      );

      // Weight = 1 * 70 = 70g, then divided by conversion factor 2.5 = 28g
      // energyKcal = 28 * 100 / 100 = 28.0
      expect(result.foodInfo![0].params!.energyKcal, 28.0);
    });

    test('skips conversion factor for hardcoded skip IDs', () async {
      // Food ID 31 is in _skipConversionFactorIds
      await _insertComposition(
        foodId: 31,
        group: '1.2.1',
        params: {'energyKcal': 100.0},
      );

      final unitsFoods = [UnitFoodEntity(id: 31, units: '38,1')];

      final simple = FoodEventSimple(
        userId: 'user1',
        eventId: 1002,
        eventDate: 20260212,
        mealType: 0,
        foodName: null,
        comment: null,
        ingredients: [
          FoodInEvent(id: 31, qty: 100, unit: 38, conversionFactor: 1, cookingMethod: -1),
        ],
      );

      final result = await service.enrichFoodEvent(
        simple,
        unitsFoods: unitsFoods,
        conversionFactorsInfo: basicConversionFactors,
      );

      // Weight = 100 * 1 = 100g, NO conversion factor applied
      // energyKcal = 100 * 100 / 100 = 100.0
      expect(result.foodInfo![0].params!.energyKcal, 100.0);
    });

    test('forces conversion factor = 3 for food ID 1865', () async {
      await _insertComposition(
        foodId: 1865,
        group: '1.2.1',
        params: {'energyKcal': 300.0},
      );

      final unitsFoods = [UnitFoodEntity(id: 1865, units: '38,1')];

      final simple = FoodEventSimple(
        userId: 'user1',
        eventId: 1003,
        eventDate: 20260212,
        mealType: 0,
        foodName: null,
        comment: null,
        ingredients: [
          FoodInEvent(id: 1865, qty: 300, unit: 38, conversionFactor: 1, cookingMethod: -1),
        ],
      );

      final result = await service.enrichFoodEvent(
        simple,
        unitsFoods: unitsFoods,
        conversionFactorsInfo: basicConversionFactors,
      );

      // Weight = 300 * 1 = 300g, divided by forced factor 3 = 100g
      // energyKcal = 100 * 300 / 100 = 300.0
      expect(result.foodInfo![0].params!.energyKcal, 300.0);
    });

    test('applies cooking oil absorption for fried food', () async {
      await _insertComposition(
        foodId: 37,
        group: '3.4',
        params: {'energyKcal': 20.0},
      );
      // Cooking method 5 = fried, 10% oil absorption
      await _insertCookingOil(5, 0.10);

      final simple = FoodEventSimple(
        userId: 'user1',
        eventId: 1004,
        eventDate: 20260212,
        mealType: 0,
        foodName: null,
        comment: null,
        ingredients: [
          FoodInEvent(id: 37, qty: 1, unit: 0, cookingMethod: 5),
        ],
      );

      final result = await service.enrichFoodEvent(
        simple,
        unitsFoods: basicUnitsFoods,
        conversionFactorsInfo: [],
      );

      // Weight = 1 * 70 = 70g
      // After oil absorption (10%): 70 * 1.10 = 77g
      // energyKcal base = 77 * 20 / 100 = 15.4
      // Oil kcal (fried): originalWeight(70) * 0.10 * 9 = 63.0
      // Total energyKcal = 15.4 + 63.0 = 78.4
      expect(result.foodInfo![0].params!.energyKcal, closeTo(78.4, 0.01));
    });

    test('applies nutrient loss from cooking method', () async {
      await _insertComposition(
        foodId: 37,
        group: '3.4',
        params: {'vitC': 120.0, 'energyKcal': 20.0},
      );
      // Cooking method 1 = baked, 25% loss of vitamin C
      await _insertNutrientLoss(1, {'vitC': 0.25});

      final simple = FoodEventSimple(
        userId: 'user1',
        eventId: 1005,
        eventDate: 20260212,
        mealType: 0,
        foodName: null,
        comment: null,
        ingredients: [
          FoodInEvent(id: 37, qty: 1, unit: 0, cookingMethod: 1),
        ],
      );

      final result = await service.enrichFoodEvent(
        simple,
        unitsFoods: basicUnitsFoods,
        conversionFactorsInfo: [],
      );

      // Weight = 70g
      // vitC base = 70 * 120 / 100 = 84.0
      // After 25% loss: 84 * 0.75 = 63.0
      expect(result.foodInfo![0].params!.vitC, closeTo(63.0, 0.01));
      // energyKcal has no loss entry, so no loss applied
      // energyKcal = 70 * 20 / 100 = 14.0
      expect(result.foodInfo![0].params!.energyKcal, closeTo(14.0, 0.01));
    });

    test('skips food with no composition data', () async {
      final simple = FoodEventSimple(
        userId: 'user1',
        eventId: 1006,
        eventDate: 20260212,
        mealType: 0,
        foodName: null,
        comment: null,
        ingredients: [
          FoodInEvent(id: 9999, qty: 1, unit: 0, cookingMethod: -1),
        ],
      );

      final result = await service.enrichFoodEvent(
        simple,
        unitsFoods: basicUnitsFoods,
        conversionFactorsInfo: [],
      );

      expect(result.foodInfo, isEmpty);
      expect(result.eventKcals, 0);
    });

    test('defaults to 1.0 gram per unit when food not in unitsFoods', () async {
      await _insertComposition(
        foodId: 999,
        group: '1.1',
        params: {'energyKcal': 200.0},
      );

      final simple = FoodEventSimple(
        userId: 'user1',
        eventId: 1007,
        eventDate: 20260212,
        mealType: 0,
        foodName: null,
        comment: null,
        ingredients: [
          FoodInEvent(id: 999, qty: 50, unit: 0, cookingMethod: -1),
        ],
      );

      final result = await service.enrichFoodEvent(
        simple,
        unitsFoods: [], // empty — no unit mapping
        conversionFactorsInfo: [],
      );

      // Weight = 50 * 1.0 (default) = 50g
      // energyKcal = 50 * 200 / 100 = 100.0
      expect(result.foodInfo![0].params!.energyKcal, 100.0);
    });
  });
}
