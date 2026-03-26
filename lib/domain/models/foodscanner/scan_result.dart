/// Result of scanning a food item (visual or barcode).
///
/// If [matchedFoodId] is non-null the scanned food was successfully matched
/// to a master-database entry and the caller should use that ID.
/// Otherwise the caller should create a custom (negative-ID) food from
/// [scannedNutrientsPer100g].
class ScanResult {
  /// Display name returned by the scan source (English).
  final String scannedName;

  /// Brand (barcode scans only, may be null for visual scans).
  final String? brand;

  /// Where the data came from: 'passio' or 'openfoodfacts'.
  final String source;

  /// How the food was detected: 'visual' or 'barcode'.
  final String detectionMethod;

  /// Master-database food ID if fuzzy-matched, otherwise null.
  final int? matchedFoodId;

  /// The matched master-database English name (null if unmatched).
  final String? matchedNameEn;

  /// The matched master-database Spanish name (null if unmatched).
  final String? matchedNameEs;

  /// The matched master-database food group (null if unmatched).
  final String? matchedGroup;

  /// Fuzzy match confidence score (0.0–1.0), null if unmatched.
  final double? matchScore;

  /// Per-100g nutrient map keyed by our Params field names.
  /// Non-null only for unmatched (custom) foods.
  final Map<String, double>? scannedNutrientsPer100g;

  /// Barcode string (null for visual scans).
  final String? barcode;

  /// Passio food ID (null for barcode scans).
  final String? passioFoodId;

  /// Estimated serving size in grams from the scan source.
  final double? estimatedGrams;

  /// Estimated kcal from the scan source.
  final double? estimatedKcal;

  ScanResult({
    required this.scannedName,
    this.brand,
    required this.source,
    required this.detectionMethod,
    this.matchedFoodId,
    this.matchedNameEn,
    this.matchedNameEs,
    this.matchedGroup,
    this.matchScore,
    this.scannedNutrientsPer100g,
    this.barcode,
    this.passioFoodId,
    this.estimatedGrams,
    this.estimatedKcal,
  });

  bool get isMatched => matchedFoodId != null;
}
