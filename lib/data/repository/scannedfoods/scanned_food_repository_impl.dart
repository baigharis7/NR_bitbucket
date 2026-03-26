import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:hive/hive.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/scannedfoods/scanned_food_repository.dart';

class ScannedFoodRepositoryImpl implements ScannedFoodRepository {
  final ReferenceDatabase _db;

  ScannedFoodRepositoryImpl(this._db);

  Box<ScannedFoodEntity> get _box => Hive.box<ScannedFoodEntity>(ScannedFoodEntity.boxName);

  @override
  Future<ScannedFoodEntity?> findByLookupKey(String lookupKey) async {
    return _box.get(lookupKey);
  }

  @override
  Future<void> saveScannedFood(ScannedFoodEntity entity) async {
    // 1. Cache in Hive keyed by lookupKey (barcode or passioId)
    await _box.put(entity.lookupKey, entity);

    // 2. Insert into Drift NutrientCompositions so the enrichment pipeline
    //    can look it up by the negative localFoodId.
    final nutrientMap = jsonDecode(entity.paramsJson) as Map<String, dynamic>;
    final paramsJsonForDrift = jsonEncode(
      nutrientMap.map((k, v) => MapEntry(k, (v as num).toDouble())),
    );

    await _db.upsertNutrientComposition(
      NutrientCompositionsCompanion(
        foodId: Value(entity.localFoodId),
        isFood: const Value(0), // treat scanned foods as "food" (0 in S3 convention)
        group: Value(entity.detectionMethod == 'barcode' ? 'scanned_barcode' : 'scanned_visual'),
        nameEn: Value(entity.nameEn),
        nameEs: Value(entity.nameEn), // no Spanish translation for scanned foods
        recommendable: const Value(0),
        freeSugar: const Value(null),
        params: Value(paramsJsonForDrift),
      ),
    );
  }

  @override
  Future<int> nextLocalFoodId() async {
    if (_box.isEmpty) return -1;

    int minId = 0;
    for (final entity in _box.values) {
      if (entity.localFoodId < minId) {
        minId = entity.localFoodId;
      }
    }
    return minId - 1;
  }
}
