import 'package:nutrenaissance_flutter/data/local/models/scannedfoods/scanned_food_entity.dart';

/// Manages local persistence of scanned (custom) foods.
abstract class ScannedFoodRepository {
  /// Find a previously-scanned food by its barcode or Passio ID.
  Future<ScannedFoodEntity?> findByLookupKey(String lookupKey);

  /// Persist a scanned food to Hive and register it in Drift so the
  /// enrichment pipeline can look it up by [localFoodId].
  Future<void> saveScannedFood(ScannedFoodEntity entity);

  /// Get the next available negative food ID (e.g. -1, -2, ...).
  Future<int> nextLocalFoodId();
}
