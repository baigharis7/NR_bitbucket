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

  // ---------------------------------------------------------------------------
  // LogMeal → Params keys
  // ---------------------------------------------------------------------------

  // LogMeal's `totalNutrients` object uses Edamam-style nutrient codes. These
  // carry the full micro breakdown (vitamins, minerals) that the simple
  // top-level keys don't, so we read them when present.
  static const _logMealTotalNutrientsMapping = <String, String>{
    'ENERC_KCAL': 'energyKcal',
    'ENERC_KJ': 'energyKJ',
    'PROCNT': 'proteinLabel',
    'CHOCDF': 'carbsAvailable',
    'CHOCDF.net': 'carbsAvailable',
    'CHOAVL': 'carbsAvailable',
    'FAT': 'fatTotal',
    'FIBTG': 'fiber',
    'SUGAR': 'sugarsTotal',
    'SUGAR.added': 'sugarsTotal',
    'STARCH': 'starch',
    'FRUS': 'fructose',
    'GLUS': 'glucose',
    'FASAT': 'saturated',
    'FATRN': 'totalTrans',
    'FAMS': 'monounsaturated',
    'FAPU': 'polyunsaturated',
    'CHOLE': 'cholesterol',
    'NA': 'sodium',
    'CA': 'calcium',
    'FE': 'iron',
    'K': 'potassium',
    'MG': 'magnesium',
    'ZN': 'zinc',
    'CU': 'copper',
    'MN': 'manganese',
    'SE': 'selenium',
    'P': 'phosphorus',
    'VITA_RAE': 'vitA',
    'THIA': 'vitB1',
    'RIBF': 'vitB2',
    'NIA': 'vitB3',
    'PANTAC': 'vitB5',
    'VITB6A': 'vitB6',
    'FOLDFE': 'vitB9',
    'FOLFD': 'vitB9',
    'VITB12': 'vitB12',
    'VITC': 'vitC',
    'VITD': 'vitD',
    'TOCPHA': 'vitE',
    'WATER': 'water',
  };

  /// Extract a flat [Map<String, double>] of per-100g nutrients from a full
  /// LogMeal `/v2/nutrition/recipe/nutritionalInfo` response.
  ///
  /// LogMeal's real API wraps nutrients under `nutritional_info` and reports
  /// them for the *whole image* at a given `serving_size` (grams). This
  /// method unwraps the response, merges both the simple top-level fields
  /// (`calories`, `protein`, ...) and the richer `totalNutrients` codes
  /// (`ENERC_KCAL`, `PROCNT`, ...), then normalizes to per-100g using
  /// `serving_size` when available.
  static Map<String, double> mapFromLogMealResponse(
    Map<String, dynamic> response,
  ) {
    // Response may wrap the info under `nutritional_info` or be flat (older
    // mocks / alternate formats). Dive into the wrapper when present.
    final info = (response['nutritional_info'] is Map<String, dynamic>)
        ? response['nutritional_info'] as Map<String, dynamic>
        : response;

    final result = <String, double>{};

    // Simple top-level fields (calories, protein, fiber, etc).
    result.addAll(mapFromLogMeal(info));

    // `totalNutrients` is a richer breakdown keyed by Edamam codes.
    // Each entry is typically `{ "label": ..., "quantity": <num>, "unit": ... }`.
    final totalNutrients = info['totalNutrients'];
    if (totalNutrients is Map) {
      for (final entry in _logMealTotalNutrientsMapping.entries) {
        final node = totalNutrients[entry.key];
        double? quantity;
        if (node is Map) {
          final q = node['quantity'];
          if (q is num) quantity = q.toDouble();
        } else if (node is num) {
          quantity = node.toDouble();
        }
        if (quantity != null && quantity > 0) {
          result.putIfAbsent(entry.value, () => quantity!);
        }
      }
    }

    // Duplicate fat subtypes so both the label-style and sum-style fields
    // are populated.
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

    // Normalize to per-100g. LogMeal reports nutrients for the whole serving
    // (e.g. 180g), but downstream storage assumes per-100g values.
    final servingSize = (response['serving_size'] as num?)?.toDouble() ??
        (info['serving_size'] as num?)?.toDouble();
    if (servingSize != null && servingSize > 0 && servingSize != 100) {
      final factor = 100.0 / servingSize;
      return result.map((k, v) => MapEntry(k, v * factor));
    }

    return result;
  }

  /// Maps LogMeal nutritional_info field names to our Params field names.
  /// LogMeal returns per-serving values; the caller should normalize to per-100g
  /// if needed before calling this.
  static Map<String, double> mapFromLogMeal(
      Map<String, dynamic> nutritionalInfo) {
    final result = <String, double>{};

    const mapping = <String, String>{
      'calories': 'energyKcal',
      'totalKCal': 'energyKcal',
      'totalKJ': 'energyKJ',
      'protein': 'proteinLabel',
      'total_carbs': 'carbsAvailable',
      'carbs': 'carbsAvailable',
      'total_fat': 'fatTotal',
      'fat': 'fatTotal',
      'fiber': 'fiber',
      'sugar': 'sugarsTotal',
      'saturated_fat': 'saturated',
      'trans_fat': 'totalTrans',
      'monounsaturated_fat': 'monounsaturated',
      'polyunsaturated_fat': 'polyunsaturated',
      'cholesterol': 'cholesterol',
      'sodium': 'sodium',
      'calcium': 'calcium',
      'iron': 'iron',
      'potassium': 'potassium',
      'magnesium': 'magnesium',
      'zinc': 'zinc',
      'phosphorus': 'phosphorus',
      'vitamin_a': 'vitA',
      'vitamin_b1': 'vitB1',
      'vitamin_b2': 'vitB2',
      'vitamin_b3': 'vitB3',
      'vitamin_b5': 'vitB5',
      'vitamin_b6': 'vitB6',
      'vitamin_b9': 'vitB9',
      'vitamin_b12': 'vitB12',
      'vitamin_c': 'vitC',
      'vitamin_d': 'vitD',
      'vitamin_e': 'vitE',
      'water': 'water',
    };

    for (final entry in mapping.entries) {
      final value = nutritionalInfo[entry.key];
      if (value is num && value > 0) {
        // Don't overwrite if already set (e.g. calories vs totalKCal)
        result.putIfAbsent(entry.value, () => value.toDouble());
      }
    }

    // Duplicate fat subtypes
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
