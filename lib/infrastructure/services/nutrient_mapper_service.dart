/// Maps nutrient data from external scan sources (OpenFoodFacts, Passio)
/// into our internal Params key names (per 100g).
///
/// Unmapped nutrients default to 0. The returned map can be JSON-encoded and
/// stored directly in Drift [NutrientCompositions.params].
class NutrientMapperService {
  NutrientMapperService._();

  // ---------------------------------------------------------------------------
  // OpenFoodFacts → Params keys
  // ---------------------------------------------------------------------------

  /// OFF nutriments keys (with `_100g` suffix) → our Params field name.
  static const _offMapping = <String, String>{
    'energy-kcal_100g': 'energyKcal',
    'energy-kj_100g': 'energyKJ',
    'proteins_100g': 'proteinLabel',
    'carbohydrates_100g': 'carbsAvailable',
    'fat_100g': 'fatTotal',
    'fiber_100g': 'fiber',
    'sugars_100g': 'sugarsTotal',
    'starch_100g': 'starch',
    'fructose_100g': 'fructose',
    'glucose_100g': 'glucose',
    'saturated-fat_100g': 'saturated',
    'trans-fat_100g': 'totalTrans',
    'monounsaturated-fat_100g': 'monounsaturated',
    'polyunsaturated-fat_100g': 'polyunsaturated',
    'omega-3-fat_100g': 'omega3',
    'cholesterol_100g': 'cholesterol',
    'sodium_100g': 'sodium',
    'calcium_100g': 'calcium',
    'iron_100g': 'iron',
    'magnesium_100g': 'magnesium',
    'phosphorus_100g': 'phosphorus',
    'potassium_100g': 'potassium',
    'zinc_100g': 'zinc',
    'copper_100g': 'copper',
    'manganese_100g': 'manganese',
    'selenium_100g': 'selenium',
    'chromium_100g': 'chromium',
    'molybdenum_100g': 'molybdenum',
    'iodine_100g': 'iodine',
    'fluoride_100g': 'fluoron',
    'chloride_100g': 'chloride',
    'vitamin-a_100g': 'vitA',
    'vitamin-b1_100g': 'vitB1',
    'vitamin-b2_100g': 'vitB2',
    'vitamin-pp_100g': 'vitB3', // niacin
    'pantothenic-acid_100g': 'vitB5',
    'vitamin-b6_100g': 'vitB6',
    'biotin_100g': 'vitB7',
    'vitamin-b9_100g': 'vitB9',
    'vitamin-b12_100g': 'vitB12',
    'vitamin-c_100g': 'vitC',
    'vitamin-d_100g': 'vitD',
    'vitamin-e_100g': 'vitE',
    'water_100g': 'water',
    'alcohol_100g': 'other',
  };

  /// Convert an OpenFoodFacts `nutriments` JSON object into a per-100g
  /// [Map<String, double>] keyed by our Params field names.
  static Map<String, double> mapFromOpenFoodFacts(
      Map<String, dynamic> nutriments) {
    final result = <String, double>{};
    for (final entry in _offMapping.entries) {
      final value = nutriments[entry.key];
      if (value is num && value > 0) {
        result[entry.value] = value.toDouble();
      }
    }

    // OFF provides salt; convert to sodium if sodium not already present.
    // sodium (g) = salt (g) × 0.4
    if (!result.containsKey('sodium')) {
      final salt = nutriments['salt_100g'];
      if (salt is num && salt > 0) {
        result['sodium'] = salt.toDouble() * 0.4;
      }
    }

    // Duplicate saturated into sumSat, mono into sumMonoUnsat, poly into
    // sumPolyUnsat so both field variants are populated.
    if (result.containsKey('saturated') && !result.containsKey('sumSat')) {
      result['sumSat'] = result['saturated']!;
    }
    if (result.containsKey('monounsaturated') &&
        !result.containsKey('sumMonoUnsat')) {
      result['sumMonoUnsat'] = result['monounsaturated']!;
    }
    if (result.containsKey('polyunsaturated') &&
        !result.containsKey('sumPolyUnsat')) {
      result['sumPolyUnsat'] = result['polyunsaturated']!;
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Passio → Params keys
  // ---------------------------------------------------------------------------

  /// Maps Passio nutrient field names (from PassioNutrients) to our Params
  /// field names. Passio's `nutrientsReference()` returns per-100g values.
  ///
  /// Passio uses UnitEnergy for calories and UnitMass for everything else.
  /// The caller must extract the numeric values before calling this.
  static Map<String, double> mapFromPassio(Map<String, double> passioNutrients) {
    final result = <String, double>{};

    const mapping = <String, String>{
      'calories': 'energyKcal',
      'protein': 'proteinLabel',
      'carbs': 'carbsAvailable',
      'fat': 'fatTotal',
      'saturatedFat': 'saturated',
      'transFat': 'totalTrans',
      'monounsaturatedFat': 'monounsaturated',
      'polyunsaturatedFat': 'polyunsaturated',
      'fiber': 'fiber',
      'sugar': 'sugarsTotal',
      'sodium': 'sodium',
      'calcium': 'calcium',
      'iron': 'iron',
      'potassium': 'potassium',
      'magnesium': 'magnesium',
      'zinc': 'zinc',
      'vitaminA': 'vitA',
      'vitaminB6': 'vitB6',
      'vitaminB12': 'vitB12',
      'vitaminC': 'vitC',
      'vitaminD': 'vitD',
      'vitaminE': 'vitE',
      'cholesterol': 'cholesterol',
    };

    for (final entry in mapping.entries) {
      final value = passioNutrients[entry.key];
      if (value != null && value > 0) {
        result[entry.value] = value;
      }
    }

    // Duplicate saturated into sumSat, etc.
    if (result.containsKey('saturated') && !result.containsKey('sumSat')) {
      result['sumSat'] = result['saturated']!;
    }
    if (result.containsKey('monounsaturated') &&
        !result.containsKey('sumMonoUnsat')) {
      result['sumMonoUnsat'] = result['monounsaturated']!;
    }
    if (result.containsKey('polyunsaturated') &&
        !result.containsKey('sumPolyUnsat')) {
      result['sumPolyUnsat'] = result['polyunsaturated']!;
    }

    return result;
  }

  /// Parse OFF serving_size string (e.g. "52 g", "0.333 PACKAGE (52 g)")
  /// into grams. Returns null if unparseable.
  static double? parseServingGrams(String? servingSize) {
    if (servingSize == null || servingSize.isEmpty) return null;

    // Try to find a parenthesized gram value first: "(52 g)"
    final parenMatch = RegExp(r'\((\d+\.?\d*)\s*g\)').firstMatch(servingSize);
    if (parenMatch != null) {
      return double.tryParse(parenMatch.group(1)!);
    }

    // Try plain "52 g" or "52g"
    final plainMatch = RegExp(r'(\d+\.?\d*)\s*g\b').firstMatch(servingSize);
    if (plainMatch != null) {
      return double.tryParse(plainMatch.group(1)!);
    }

    // Try plain "52 ml" (treat ml as grams for liquids, approximate)
    final mlMatch = RegExp(r'(\d+\.?\d*)\s*ml\b').firstMatch(servingSize);
    if (mlMatch != null) {
      return double.tryParse(mlMatch.group(1)!);
    }

    return null;
  }
}
