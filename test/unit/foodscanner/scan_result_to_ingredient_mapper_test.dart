import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/scannedfoods/scanned_food_repository.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/scan_result_to_ingredient_mapper.dart';

class _FakeScannedFoodRepository implements ScannedFoodRepository {
  final Map<String, ScannedFoodEntity> _store = {};
  int _nextId = -1;
  int saveCount = 0;
  int nextIdCalls = 0;

  @override
  Future<ScannedFoodEntity?> findByLookupKey(String lookupKey) async =>
      _store[lookupKey];

  @override
  Future<void> saveScannedFood(ScannedFoodEntity entity) async {
    _store[entity.lookupKey] = entity;
    saveCount++;
  }

  @override
  Future<int> nextLocalFoodId() async {
    nextIdCalls++;
    final id = _nextId;
    _nextId--;
    return id;
  }
}

void main() {
  late _FakeScannedFoodRepository repo;
  late ScanResultToIngredientMapper mapper;

  setUp(() {
    repo = _FakeScannedFoodRepository();
    mapper = ScanResultToIngredientMapper(repo);
  });

  group('matched scans', () {
    test('resolve directly to master food id without touching the repo', () async {
      final scan = ScanResult(
        scannedName: 'banana',
        source: 'logmeal',
        detectionMethod: 'visual',
        matchedFoodId: 42,
        matchedNameEn: 'Banana',
        matchedNameEs: 'Plátano',
        estimatedGrams: 188,
      );

      final ingredient = await mapper.toIngredient(scan);

      expect(ingredient.id, 42);
      expect(ingredient.name_en, 'Banana');
      expect(ingredient.name_es, 'Plátano');
      expect(ingredient.qty, 188);
      expect(ingredient.unit, -2);
      expect(repo.saveCount, 0);
      expect(repo.nextIdCalls, 0);
    });

    test('use 0 qty when the scan has no gram estimate', () async {
      final scan = ScanResult(
        scannedName: 'banana',
        source: 'logmeal',
        detectionMethod: 'visual',
        matchedFoodId: 42,
        matchedNameEn: 'Banana',
      );

      final ingredient = await mapper.toIngredient(scan);

      expect(ingredient.qty, 0);
    });
  });

  group('unmatched scans', () {
    test('allocate a fresh local id and persist nutrients to the repo', () async {
      final nutrients = {'energyKcal': 89.0, 'protein': 1.1};
      final scan = ScanResult(
        scannedName: 'Exotic Fruit',
        source: 'logmeal',
        detectionMethod: 'visual',
        scannedNutrientsPer100g: nutrients,
        estimatedGrams: 120,
      );

      final ingredient = await mapper.toIngredient(scan);

      expect(ingredient.id, -1);
      expect(ingredient.name_en, 'Exotic Fruit');
      expect(ingredient.qty, 120);
      expect(repo.saveCount, 1);

      final persisted = await repo.findByLookupKey('logmeal-visual-exotic fruit');
      expect(persisted, isNotNull);
      expect(persisted!.localFoodId, -1);
      expect(persisted.nameEn, 'Exotic Fruit');
      expect(jsonDecode(persisted.paramsJson), nutrients);
    });

    test('reuse the existing local id on a second scan of the same food', () async {
      final scan = ScanResult(
        scannedName: 'Exotic Fruit',
        source: 'logmeal',
        detectionMethod: 'visual',
        scannedNutrientsPer100g: {'energyKcal': 89.0},
        estimatedGrams: 120,
      );

      final first = await mapper.toIngredient(scan);
      final second = await mapper.toIngredient(scan);

      expect(first.id, -1);
      expect(second.id, -1);
      expect(repo.saveCount, 1);
      expect(repo.nextIdCalls, 1);
    });

    test('normalize name casing when building the lookup key', () async {
      final first = await mapper.toIngredient(ScanResult(
        scannedName: 'Mango',
        source: 'logmeal',
        detectionMethod: 'visual',
        scannedNutrientsPer100g: {'energyKcal': 60.0},
        estimatedGrams: 100,
      ));
      final second = await mapper.toIngredient(ScanResult(
        scannedName: '  mango  ',
        source: 'logmeal',
        detectionMethod: 'visual',
        scannedNutrientsPer100g: {'energyKcal': 60.0},
        estimatedGrams: 100,
      ));

      expect(first.id, second.id);
      expect(repo.saveCount, 1);
    });

    test('prefer barcode as the lookup key when present', () async {
      final scan = ScanResult(
        scannedName: 'Some Protein Bar',
        source: 'openfoodfacts',
        detectionMethod: 'barcode',
        barcode: '0123456789012',
        scannedNutrientsPer100g: {'energyKcal': 400.0},
      );

      await mapper.toIngredient(scan);

      expect(await repo.findByLookupKey('0123456789012'), isNotNull);
    });

    test('prefer passioFoodId over the name when no barcode is present', () async {
      final scan = ScanResult(
        scannedName: 'Grilled Chicken',
        source: 'passio',
        detectionMethod: 'visual',
        passioFoodId: 'passio-abc-123',
        scannedNutrientsPer100g: {'energyKcal': 165.0},
      );

      await mapper.toIngredient(scan);

      expect(await repo.findByLookupKey('passio-abc-123'), isNotNull);
    });
  });
}
