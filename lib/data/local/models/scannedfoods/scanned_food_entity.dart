import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/hive_type_ids.dart';

part 'scanned_food_entity.g.dart';

/// Locally cached scanned food, keyed by barcode or Passio food ID.
///
/// Stores per-100g nutrient data as JSON so we can insert it into Drift
/// [NutrientCompositions] on demand and avoid re-fetching from the API.
@JsonSerializable(explicitToJson: true)
@HiveType(typeId: HiveTypeIds.scannedFoodEntity)
class ScannedFoodEntity extends HiveObject {
  static const boxName = 'scanned_foods';

  /// Barcode string or Passio food ID — used as the Hive key.
  @HiveField(0)
  String lookupKey;

  /// Locally-assigned negative food ID for the Drift pipeline.
  @HiveField(1)
  int localFoodId;

  /// English product name.
  @HiveField(2)
  String nameEn;

  /// Brand name (barcode scans), may be null.
  @HiveField(3)
  String? brand;

  /// Source: 'passio' or 'openfoodfacts'.
  @HiveField(4)
  String source;

  /// JSON-encoded Map<String, double> of per-100g nutrients
  /// keyed by our Params field names.
  @HiveField(5)
  String paramsJson;

  /// Unix timestamp (milliseconds) when this food was first scanned.
  @HiveField(6)
  int scannedAt;

  /// Detection method: 'visual' or 'barcode'.
  @HiveField(7)
  String detectionMethod;

  /// Whether the source classifies this product as a beverage. Used to
  /// route the food into the FoodEvent's drinks slot on save and on
  /// re-scan from cache. Optional for backward compatibility with cache
  /// entries written before this field existed.
  @HiveField(8, defaultValue: false)
  bool isBeverage;

  ScannedFoodEntity({
    required this.lookupKey,
    required this.localFoodId,
    required this.nameEn,
    this.brand,
    required this.source,
    required this.paramsJson,
    required this.scannedAt,
    required this.detectionMethod,
    this.isBeverage = false,
  });

  factory ScannedFoodEntity.fromJson(Map<String, dynamic> json) =>
      _$ScannedFoodEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ScannedFoodEntityToJson(this);
}
