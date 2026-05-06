import 'dart:convert';

import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';
import 'package:nutrenaissance_flutter/data/repository/scannedfoods/scanned_food_repository.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/scan_result.dart';

/// Converts a [ScanResult] into a [FoodInFavorite] ready to save as part
/// of a FoodEvent.
///
/// Matched results resolve directly to their master-DB id. Unmatched
/// results are registered in [ScannedFoodRepository] so their per-100g
/// nutrient data is written into Drift under a locally-allocated
/// negative food id; that id is then used on the FoodInFavorite and the
/// nutrition pipeline resolves it like any DB food. Repeat scans of
/// the same food reuse the previously-allocated local id via
/// [ScannedFoodRepository.findByLookupKey].
class ScanResultToIngredientMapper {
  final ScannedFoodRepository _repository;

  ScanResultToIngredientMapper(this._repository);

  Future<FoodInFavorite> toIngredient(ScanResult scan) async {
    if (scan.isMatched) {
      return FoodInFavorite(
        id: scan.matchedFoodId!,
        name_en: scan.matchedNameEn,
        name_es: scan.matchedNameEs,
        qty: scan.estimatedGrams?.round() ?? 0,
        unit: -2,
        cookingMethod: 0,
      );
    }

    final lookupKey = _lookupKeyFor(scan);
    int localFoodId;
    final existing = await _repository.findByLookupKey(lookupKey);
    if (existing != null) {
      localFoodId = existing.localFoodId;
    } else {
      localFoodId = await _repository.nextLocalFoodId();
      final entity = ScannedFoodEntity(
        lookupKey: lookupKey,
        localFoodId: localFoodId,
        nameEn: scan.scannedName,
        brand: scan.brand,
        source: scan.source,
        paramsJson: jsonEncode(scan.scannedNutrientsPer100g ?? const {}),
        scannedAt: DateTime.now().millisecondsSinceEpoch,
        detectionMethod: scan.detectionMethod,
        isBeverage: scan.isBeverage,
      );
      await _repository.saveScannedFood(entity);
    }

    return FoodInFavorite(
      id: localFoodId,
      name_en: scan.scannedName,
      name_es: scan.scannedName,
      qty: scan.estimatedGrams?.round() ?? 0,
      unit: -2,
      cookingMethod: 0,
    );
  }

  String _lookupKeyFor(ScanResult scan) {
    if (scan.barcode != null && scan.barcode!.isNotEmpty) {
      return scan.barcode!;
    }
    if (scan.passioFoodId != null && scan.passioFoodId!.isNotEmpty) {
      return scan.passioFoodId!;
    }
    final normalized = scan.scannedName.trim().toLowerCase();
    return '${scan.source}-visual-$normalized';
  }
}
