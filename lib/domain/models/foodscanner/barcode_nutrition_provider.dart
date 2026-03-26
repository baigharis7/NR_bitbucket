/// Abstraction over barcode-based food lookup.
///
/// Two implementations exist:
///  - [PassioBarcodeProvider] (default) — uses Passio Nutrition AI SDK
///  - [OpenFoodFactsBarcodeProvider] — uses OpenFoodFacts REST API
///
/// Swap the concrete implementation in DI to trial either provider.
abstract class BarcodeNutritionProvider {
  /// Look up a product by its barcode string.
  ///
  /// Returns null if the barcode is not found in the provider's database.
  /// The returned [BarcodeProduct] contains the product name, brand, and
  /// per-100g nutrient values already mapped to our Params keys.
  Future<BarcodeProduct?> lookupBarcode(String barcode);
}

/// Normalized product data returned by any [BarcodeNutritionProvider].
class BarcodeProduct {
  /// Product name (English).
  final String name;

  /// Brand name, if available.
  final String? brand;

  /// Per-100g nutrient values keyed by our Params field names
  /// (e.g. 'energyKcal', 'proteinLabel', 'fatTotal').
  final Map<String, double> nutrientsPer100g;

  /// Serving size in grams, if available.
  final double? servingGrams;

  /// The raw barcode string.
  final String barcode;

  BarcodeProduct({
    required this.name,
    this.brand,
    required this.nutrientsPer100g,
    this.servingGrams,
    required this.barcode,
  });
}
