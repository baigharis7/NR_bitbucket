import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nutrenaissance_flutter/domain/models/foodscanner/visual_food_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';

/// Identifies foods in an image using the LogMeal API.
///
/// Flow:
/// 1. POST image to /v2/image/segmentation/complete → get dish names + imageId
/// 2. Filter by confidence >= [minConfidence], deduplicate same-name dishes
/// 3. POST /v2/image/confirm/dish → confirm detected dishes (improves accuracy)
///
/// Nutrient resolution is handled by the BLoC, not here — this provider only
/// returns detected foods with estimated portions. The BLoC decides whether to
/// use our DB nutrients or fetch from LogMeal for unmatched items.
class LogMealProvider implements VisualFoodProvider {
  static const _baseUrl = 'https://api.logmeal.com';
  static const double minConfidence = 0.5;

  final String _apiToken;
  final http.Client _client;

  /// The imageId from the most recent segmentation — used by the BLoC to fetch
  /// ingredients or nutrition for unmatched dishes.
  int? lastImageId;

  LogMealProvider({
    required String apiToken,
    http.Client? client,
  })  : _apiToken = apiToken,
        _client = client ?? http.Client();

  /// Log to both debugPrint and Crashlytics breadcrumbs.
  void _log(String message) {
    debugPrint('[LogMeal] $message');
    CrashlyticsService.instance.log('LogMeal: $message');
  }

  @override
  Future<List<VisualFoodResult>> identifyFoods(Uint8List imageBytes) async {
    // Step 1: Image segmentation
    _log('Segmenting image (${imageBytes.length} bytes)');
    final segmentationResult = await _segmentImage(imageBytes);

    final imageId = segmentationResult['imageId'] as int?;
    if (imageId == null) {
      _log('No imageId in response (keys: ${segmentationResult.keys.toList()})');
      return [];
    }
    lastImageId = imageId;

    // Try both response structures
    final segments = segmentationResult['segmentation_results'] as List<dynamic>?
        ?? segmentationResult['recognition_results'] as List<dynamic>?;

    if (segments == null || segments.isEmpty) {
      _log('No food segments found (keys: ${segmentationResult.keys.toList()})');
      return [];
    }

    _log('Found ${segments.length} segments, imageId=$imageId');

    // Step 2: Parse segments, extract confidence, deduplicate
    final allParsed = <VisualFoodResult>[];

    for (final item in segments) {
      final itemMap = item as Map<String, dynamic>;

      // Handle both structures:
      // Structure A (segmentation): { recognition_results: [{name, id, prob}] }
      // Structure B (flat): { name, id, prob }
      String? name;
      double? prob;
      int? dishId;

      if (itemMap.containsKey('recognition_results')) {
        final recognition = itemMap['recognition_results'] as List<dynamic>?;
        if (recognition != null && recognition.isNotEmpty) {
          final top = recognition.first as Map<String, dynamic>;
          name = top['name'] as String?;
          prob = (top['prob'] as num?)?.toDouble();
          dishId = top['id'] is int ? top['id'] as int : null;
        }
      } else if (itemMap.containsKey('name')) {
        name = itemMap['name'] as String?;
        prob = (itemMap['prob'] as num?)?.toDouble();
        dishId = itemMap['id'] is int ? itemMap['id'] as int : null;
      }

      if (name == null || name.isEmpty) continue;

      final servingSize = (itemMap['serving_size'] as num?)
          ?? (itemMap['quantity'] as num?)
          ?? (itemMap['weight'] as num?)
          ?? (itemMap['portion_size'] as num?);

      allParsed.add(VisualFoodResult(
        name: name,
        estimatedGrams: servingSize?.toDouble(),
        confidence: prob,
        logmealDishId: dishId,
      ));
    }

    if (allParsed.isEmpty) {
      _log('WARNING: ${segments.length} segments but 0 parsed results');
      return [];
    }

    // Soft confidence filter: prefer high-confidence results, but if ALL
    // are below threshold, keep them anyway — never discard named foods.
    final confident = allParsed.where((r) => (r.confidence ?? 1.0) >= minConfidence).toList();
    final rawResults = confident.isNotEmpty ? confident : allParsed;
    if (confident.isEmpty) {
      _log('All ${allParsed.length} results below confidence $minConfidence — keeping best');
    } else {
      _log('${confident.length}/${allParsed.length} results above confidence $minConfidence');
    }

    // Step 3: Deduplicate — keep highest-confidence entry per name
    final deduped = _deduplicateResults(rawResults);
    _log('After dedup: ${deduped.length} results');

    // Step 4: Confirm dishes with LogMeal (improves accuracy over time)
    final dishIds = deduped
        .where((r) => r.logmealDishId != null)
        .map((r) => r.logmealDishId!)
        .toList();
    if (dishIds.isNotEmpty) {
      await _confirmDishes(imageId, dishIds);
    }

    // Step 5: Estimate grams from ingredients endpoint
    // The segmentation endpoint doesn't return portion sizes. The ingredients
    // endpoint returns a "recipe" array with per-food weights.
    final needsGrams = deduped.any((r) => r.estimatedGrams == null);
    _log('Needs grams: $needsGrams');
    if (needsGrams) {
      final ingredients = await getIngredients(imageId);
      if (ingredients.isNotEmpty) {
        // Build name→weight map from recipe items
        final weightByName = <String, double>{};
        for (final ing in ingredients) {
          final name = (ing['name'] as String?)?.toLowerCase().trim();
          final weight = (ing['weight'] as num?)?.toDouble()
              ?? (ing['quantity'] as num?)?.toDouble()
              ?? (ing['measure'] is Map
                  ? ((ing['measure'] as Map)['metric'] is Map
                      ? ((ing['measure'] as Map)['metric']['quantity'] as num?)?.toDouble()
                      : null)
                  : null);
          if (name != null && weight != null && weight > 0) {
            weightByName[name] = weight;
          }
        }
        _log('Ingredient weights: $weightByName');

        if (weightByName.isNotEmpty) {
          // Try to match each deduped food to its recipe weight by name
          double totalWeight = weightByName.values.fold(0, (a, b) => a + b);
          final fallbackGrams = totalWeight / deduped.length;

          final updated = deduped.map((r) {
            final key = r.name.toLowerCase().trim();
            final matched = weightByName[key];
            final grams = r.estimatedGrams ?? matched ?? fallbackGrams;
            return VisualFoodResult(
              name: r.name,
              estimatedGrams: grams,
              confidence: r.confidence,
              logmealDishId: r.logmealDishId,
              estimatedKcal: r.estimatedKcal,
            );
          }).toList();
          return updated;
        }
      }

      // Fallback: try nutrition endpoint for weight
      final nutritionWeight = await _estimateGramsFromNutrition(imageId);
      _log('Nutrition weight fallback: ${nutritionWeight}g');
      if (nutritionWeight != null && nutritionWeight > 0) {
        final gramsPerFood = nutritionWeight / deduped.length;
        final updated = deduped.map((r) => VisualFoodResult(
          name: r.name,
          estimatedGrams: r.estimatedGrams ?? gramsPerFood,
          confidence: r.confidence,
          logmealDishId: r.logmealDishId,
          estimatedKcal: r.estimatedKcal,
        )).toList();
        return updated;
      }
    }

    return deduped;
  }

  // ---------------------------------------------------------------------------
  // Public methods for BLoC to call on unmatched foods
  // ---------------------------------------------------------------------------

  /// Fetch ingredients for an image (for breaking down unmatched dishes).
  /// Returns a list of ingredient maps with name, quantity, unit fields.
  Future<List<Map<String, dynamic>>> getIngredients(int imageId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/v2/nutrition/recipe/ingredients'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'imageId': imageId}),
      );

      _log('Ingredients status: ${response.statusCode}');
      if (response.statusCode != 200) {
        _log('Ingredients error: ${response.body}');
        return [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      _log('Ingredients keys: ${json.keys.toList()}');

      // Response key varies: recipe, ingredient_list, or ingredients
      final ingredients = json['recipe'] as List<dynamic>?
          ?? json['ingredient_list'] as List<dynamic>?
          ?? json['ingredients'] as List<dynamic>?;
      if (ingredients == null) {
        _log('No recipe/ingredient_list key (keys: ${json.keys.toList()})');
        return [];
      }

      return ingredients
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _log('Ingredients fetch error: $e');
      return [];
    }
  }

  /// Fetch nutritional info for an image (only for unmatched items).
  /// Returns the raw nutrition response map.
  Future<Map<String, dynamic>?> getNutritionForImage(int imageId) async {
    return _getNutritionalInfo(imageId);
  }

  // ---------------------------------------------------------------------------
  // Private API methods
  // ---------------------------------------------------------------------------

  /// POST image for segmentation and food recognition.
  Future<Map<String, dynamic>> _segmentImage(Uint8List imageBytes) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/v2/image/segmentation/complete'),
    );
    request.headers['Authorization'] = 'Bearer $_apiToken';
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      imageBytes,
      filename: 'photo.jpg',
    ));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    _log('Segmentation status: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw LogMealException(
        'Segmentation failed',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _log('Segmentation keys: ${json.keys.toList()}');
    return json;
  }

  /// Confirm detected dishes with LogMeal (improves ML accuracy).
  Future<void> _confirmDishes(int imageId, List<int> dishIds) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/v2/image/confirm/dish'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'imageId': imageId, 'dishes': dishIds}),
      );
      _log('Dish confirmation status: ${response.statusCode}');
    } catch (e) {
      _log('Dish confirmation error: $e');
      // Non-critical — don't fail the scan if confirmation fails
    }
  }

  /// Try to extract total weight from the nutrition endpoint response.
  /// LogMeal nutrition responses may include serving_size, total_weight,
  /// or per-dish weight fields.
  Future<double?> _estimateGramsFromNutrition(int imageId) async {
    try {
      final nutrition = await _getNutritionalInfo(imageId);
      if (nutrition == null) return null;

      _log('Nutrition keys: ${nutrition.keys.toList()}');

      // Try common weight fields
      final weight = (nutrition['serving_size'] as num?)?.toDouble()
          ?? (nutrition['total_weight'] as num?)?.toDouble()
          ?? (nutrition['totalWeight'] as num?)?.toDouble()
          ?? (nutrition['weight'] as num?)?.toDouble()
          ?? (nutrition['serving_weight_grams'] as num?)?.toDouble()
          ?? (nutrition['quantity'] as num?)?.toDouble();

      if (weight != null && weight > 0) {
        _log('Weight from nutrition: ${weight}g');
        return weight;
      }

      // Check if there's a per-dish breakdown with weights
      final dishes = nutrition['dishes'] as List<dynamic>?
          ?? nutrition['foodItems'] as List<dynamic>?;
      if (dishes != null && dishes.isNotEmpty) {
        double total = 0;
        for (final dish in dishes) {
          if (dish is Map) {
            final w = (dish['serving_size'] as num?)?.toDouble()
                ?? (dish['weight'] as num?)?.toDouble()
                ?? (dish['quantity'] as num?)?.toDouble();
            if (w != null && w > 0) total += w;
          }
        }
        if (total > 0) return total;
      }

      _log('No weight found in nutrition response');
      return null;
    } catch (e) {
      _log('Gram estimation error: $e');
      return null;
    }
  }

  /// POST imageId to get nutritional information.
  Future<Map<String, dynamic>?> _getNutritionalInfo(int imageId) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/v2/nutrition/recipe/nutritionalInfo'),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'imageId': imageId}),
      );

      _log('Nutrition status: ${response.statusCode}');
      if (response.statusCode != 200) {
        _log('Nutrition error: ${response.body}');
        return null;
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      _log('Nutrition fetch error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Deduplicate same-name results: keep the entry with highest confidence.
  List<VisualFoodResult> _deduplicateResults(List<VisualFoodResult> results) {
    final Map<String, VisualFoodResult> best = {};

    for (final r in results) {
      final key = r.name.toLowerCase().trim();
      final existing = best[key];
      if (existing == null ||
          (r.confidence ?? 0) > (existing.confidence ?? 0)) {
        best[key] = r;
      }
    }

    return best.values.toList();
  }
}

/// Exception with LogMeal API response details.
class LogMealException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  LogMealException(this.message, {required this.statusCode, required this.responseBody});

  @override
  String toString() => 'LogMealException($statusCode): $message — $responseBody';
}
