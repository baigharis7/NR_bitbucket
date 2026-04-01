import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';

/// Matches scanned food names against the master food database.
///
/// Uses normalized exact/substring matching with a high threshold to avoid
/// false positives. Only returns matches we are confident about.
class FoodFuzzyMatcher {
  /// Pre-built index: lowercase normalized name → FoodItemMaster.
  /// Built once per app session from the master food list.
  final Map<String, FoodItemMaster> _exactIndex = {};
  final List<_IndexedFood> _tokenIndex = [];

  FoodFuzzyMatcher(List<FoodItemMaster> masterFoods) {
    for (final food in masterFoods) {
      final normalized = _normalize(food.en ?? '');
      if (normalized.isEmpty) continue;
      _exactIndex[normalized] = food;
      _tokenIndex.add(_IndexedFood(
        food: food,
        normalized: normalized,
        tokens: _tokenize(normalized),
      ));
    }
  }

  /// Find the best match for [scannedName] in the master database.
  ///
  /// Returns null if no match meets the confidence threshold.
  /// [maxResults] limits how many candidates to return (for debugging;
  /// in production we only use the top result).
  FuzzyMatchResult? findBestMatch(String scannedName) {
    final normalized = _normalize(scannedName);
    if (normalized.isEmpty) return null;

    // 1. Exact match (highest confidence)
    final exact = _exactIndex[normalized];
    if (exact != null) {
      return FuzzyMatchResult(food: exact, score: 1.0);
    }

    // 2. Exact substring: our DB name is contained in scanned name or vice versa
    //    e.g. scanned "french omelette" contains DB "omelette"
    //    Only count if the DB name is at least 4 chars (avoid matching "oil" in "olive oil cake")
    FuzzyMatchResult? bestSubstring;
    for (final indexed in _tokenIndex) {
      if (indexed.normalized.length < 4) continue;

      double score = 0;
      if (normalized.contains(indexed.normalized)) {
        // DB name is substring of scanned name
        score = indexed.normalized.length / normalized.length;
        // Bonus if it's a word-boundary match
        if (normalized == indexed.normalized ||
            normalized.startsWith('${indexed.normalized} ') ||
            normalized.endsWith(' ${indexed.normalized}') ||
            normalized.contains(' ${indexed.normalized} ')) {
          score = (score + 1.0) / 2.0; // average toward 1.0
        }
      } else if (indexed.normalized.contains(normalized) &&
          normalized.length >= 4) {
        // Scanned name is substring of DB name
        score = normalized.length / indexed.normalized.length;
      }

      if (score >= 0.85 &&
          (bestSubstring == null || score > bestSubstring.score)) {
        bestSubstring = FuzzyMatchResult(food: indexed.food, score: score);
      }
    }
    if (bestSubstring != null) return bestSubstring;

    // 3. Token overlap: split into words, count shared tokens
    final scannedTokens = _tokenize(normalized);
    if (scannedTokens.isEmpty) return null;

    FuzzyMatchResult? bestToken;
    for (final indexed in _tokenIndex) {
      if (indexed.tokens.isEmpty) continue;

      int shared = 0;
      for (final token in scannedTokens) {
        if (indexed.tokens.contains(token)) {
          shared++;
        }
      }

      if (shared == 0) continue;

      // If ALL DB tokens are found in the scanned name, it's a strong match
      // e.g. DB "chicken breast" (2 tokens) all found in scanned
      // "grilled chicken breast with herbs" (4 tokens) → containment match
      final allDbTokensFound = shared == indexed.tokens.length;

      double score;
      if (allDbTokensFound && indexed.tokens.length >= 2) {
        // Score based on how much of the scanned name the DB name covers
        score = indexed.tokens.length / scannedTokens.length;
        // Boost: all DB tokens present is a strong signal
        score = (score + 1.0) / 2.0; // average toward 1.0
      } else {
        // Standard: shared tokens / max(scanned tokens, DB tokens)
        final maxTokens = scannedTokens.length > indexed.tokens.length
            ? scannedTokens.length
            : indexed.tokens.length;
        score = shared / maxTokens;
      }

      if (score >= 0.70 && (bestToken == null || score > bestToken.score)) {
        bestToken = FuzzyMatchResult(food: indexed.food, score: score);
      }
    }

    return bestToken;
  }

  /// Find top N matches above threshold (for UI display if needed).
  List<FuzzyMatchResult> findTopMatches(String scannedName,
      {int maxResults = 3, double threshold = 0.85}) {
    final normalized = _normalize(scannedName);
    if (normalized.isEmpty) return [];

    final scannedTokens = _tokenize(normalized);
    final results = <FuzzyMatchResult>[];

    for (final indexed in _tokenIndex) {
      double score = 0;

      // Exact
      if (normalized == indexed.normalized) {
        score = 1.0;
      }
      // Substring
      else if (indexed.normalized.length >= 4 &&
          normalized.contains(indexed.normalized)) {
        score = indexed.normalized.length / normalized.length;
        if (normalized.startsWith('${indexed.normalized} ') ||
            normalized.endsWith(' ${indexed.normalized}') ||
            normalized.contains(' ${indexed.normalized} ')) {
          score = (score + 1.0) / 2.0;
        }
      }
      // Token overlap
      else if (scannedTokens.isNotEmpty && indexed.tokens.isNotEmpty) {
        int shared = 0;
        for (final token in scannedTokens) {
          if (indexed.tokens.contains(token)) shared++;
        }
        final maxTokens = scannedTokens.length > indexed.tokens.length
            ? scannedTokens.length
            : indexed.tokens.length;
        score = shared / maxTokens;
      }

      if (score >= threshold) {
        results.add(FuzzyMatchResult(food: indexed.food, score: score));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(maxResults).toList();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Common cooking method keywords that may appear in scanned food names.
  /// These are stripped before matching to improve results.
  /// The map keys are normalized keywords, values are display names that can
  /// be matched against CookingMethodInfo.en at runtime.
  static const cookingKeywords = <String, String>{
    'grilled': 'Grilled',
    'grilling': 'Grilled',
    'fried': 'Fried',
    'deep fried': 'Fried',
    'pan fried': 'Fried',
    'stir fried': 'Fried',
    'baked': 'Baked',
    'roasted': 'Roasted',
    'roast': 'Roasted',
    'steamed': 'Steamed',
    'boiled': 'Boiled',
    'poached': 'Boiled',
    'sauteed': 'Sautéed',
    'braised': 'Braised',
    'smoked': 'Smoked',
    'breaded': 'Breaded',
    'breadcrumbs': 'Breaded',
    'raw': 'Raw',
  };

  /// Strip cooking method keywords from a food name.
  /// Returns (cleanedName, detectedCookingKeyword) where the keyword is the
  /// display name (e.g. "Grilled") or null if none found.
  static (String, String?) extractCookingMethod(String name) {
    final lower = name.toLowerCase().trim();

    // Check multi-word keywords first (e.g. "deep fried")
    final sortedKeys = cookingKeywords.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final keyword in sortedKeys) {
      if (lower.contains(keyword)) {
        final cleaned = lower
            .replaceAll(keyword, '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        if (cleaned.isNotEmpty) {
          return (cleaned, cookingKeywords[keyword]!);
        }
      }
    }
    return (name, null);
  }

  /// Lowercase, remove diacritics/accents, strip punctuation and articles.
  static String _normalize(String input) {
    var s = input.toLowerCase().trim();
    // Remove common diacritics
    s = s
        .replaceAll(RegExp('[áàâä]'), 'a')
        .replaceAll(RegExp('[éèêë]'), 'e')
        .replaceAll(RegExp('[íìîï]'), 'i')
        .replaceAll(RegExp('[óòôö]'), 'o')
        .replaceAll(RegExp('[úùûü]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ç', 'c');
    // Remove punctuation
    s = s.replaceAll(RegExp(r'[^\w\s]'), '');
    // Collapse whitespace
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  /// Split into meaningful tokens, removing very short words and articles.
  static Set<String> _tokenize(String normalized) {
    const stopWords = {
      'a', 'an', 'the', 'of', 'with', 'and', 'or', 'in', 'on', 'de', 'con',
      'y', 'el', 'la', 'los', 'las', 'en', 'al', 'del',
    };
    return normalized
        .split(' ')
        .where((t) => t.length >= 2 && !stopWords.contains(t))
        .toSet();
  }
}

class FuzzyMatchResult {
  final FoodItemMaster food;
  final double score;

  FuzzyMatchResult({required this.food, required this.score});
}

class _IndexedFood {
  final FoodItemMaster food;
  final String normalized;
  final Set<String> tokens;

  _IndexedFood({
    required this.food,
    required this.normalized,
    required this.tokens,
  });
}
