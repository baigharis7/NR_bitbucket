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

  @override
  Future<List<VisualFoodResult>> identifyFoods(Uint8List imageBytes) async {
    // Step 1: Image segmentation
    debugPrint('[LogMeal] Sending ${imageBytes.length} bytes for segmentation...');
    final segmentationResult = await _segmentImage(imageBytes);

    final imageId = segmentationResult['imageId'] as int?;
    if (imageId == null) {
      final msg = 'LogMeal: no imageId in response (keys: ${segmentationResult.keys.toList()})';
      debugPrint('[LogMeal] $msg');
      CrashlyticsService.instance.log(msg);
      return [];
    }
    lastImageId = imageId;

    // Try both response structures
    final segments = segmentationResult['segmentation_results'] as List<dynamic>?
        ?? segmentationResult['recognition_results'] as List<dynamic>?;

    if (segments == null || segments.isEmpty) {
      final msg = 'LogMeal: no food segments found (keys: ${segmentationResult.keys.toList()})';
      debugPrint('[LogMeal] $msg');
      CrashlyticsService.instance.log(msg);
      return [];
    }

    debugPrint('[LogMeal] Found ${segments.length} segments, imageId=$imageId');
    debugPrint('[LogMeal] Response keys: ${segmentationResult.keys.toList()}');
    CrashlyticsService.instance.log(
      'LogMeal response keys: ${segmentationResult.keys.toList()}',
    );
    if (segments.isNotEmpty) {
      debugPrint('[LogMeal] First segment: ${segments.first}');
      CrashlyticsService.instance.log(
        'LogMeal first segment keys: ${(segments.first as Map).keys.toList()}',
      );
    }

    // Step 2: Parse segments, extract confidence, filter, deduplicate
    final rawResults = <VisualFoodResult>[];

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

      // Filter by confidence
      if (prob != null && prob < minConfidence) {
        debugPrint('[LogMeal] Filtered: $name (confidence ${prob.toStringAsFixed(2)} < $minConfidence)');
        continue;
      }

      // LogMeal may return portion info under different keys
      debugPrint('[LogMeal] Segment keys for $name: ${itemMap.keys.toList()}');
      CrashlyticsService.instance.log(
        'LogMeal segment "$name" keys: ${itemMap.keys.toList()}',
      );
      final servingSize = (itemMap['serving_size'] as num?)
          ?? (itemMap['quantity'] as num?)
          ?? (itemMap['weight'] as num?)
          ?? (itemMap['portion_size'] as num?);

      debugPrint('[LogMeal] Detected: $name (${servingSize}g, confidence=${prob?.toStringAsFixed(2)})');
      rawResults.add(VisualFoodResult(
        name: name,
        estimatedGrams: servingSize?.toDouble(),
        confidence: prob,
        logmealDishId: dishId,
      ));
    }

    // Step 3: Deduplicate — keep highest-confidence entry per name
    final deduped = _deduplicateResults(rawResults);
    debugPrint('[LogMeal] After filter+dedup: ${deduped.length} results (from ${segments.length} segments)');

    // Step 4: Confirm dishes with LogMeal (improves accuracy over time)
    final dishIds = deduped
        .where((r) => r.logmealDishId != null)
        .map((r) => r.logmealDishId!)
        .toList();
    if (dishIds.isNotEmpty) {
      await _confirmDishes(imageId, dishIds);
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

      debugPrint('[LogMeal] Ingredients status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('[LogMeal] Ingredients error: ${response.body}');
        return [];
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('[LogMeal] Ingredients keys: ${json.keys.toList()}');

      // Response contains ingredient_list or similar
      final ingredients = json['ingredient_list'] as List<dynamic>?
          ?? json['ingredients'] as List<dynamic>?;
      if (ingredients == null) return [];

      return ingredients
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('[LogMeal] Ingredients fetch error: $e');
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
      Uri.parse('$_baseUrl/v2/image/segmentation/complete/quantity'),
    );
    request.headers['Authorization'] = 'Bearer $_apiToken';
    request.files.add(http.MultipartFile.fromBytes(
      'sequence',
      imageBytes,
      filename: 'photo.jpg',
    ));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('[LogMeal] Segmentation status: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw LogMealException(
        'Segmentation failed',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('[LogMeal] Segmentation keys: ${json.keys.toList()}');
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
      debugPrint('[LogMeal] Dish confirmation status: ${response.statusCode}');
    } catch (e) {
      debugPrint('[LogMeal] Dish confirmation error: $e');
      // Non-critical — don't fail the scan if confirmation fails
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

      debugPrint('[LogMeal] Nutrition status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('[LogMeal] Nutrition error: ${response.body}');
        return null;
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[LogMeal] Nutrition fetch error: $e');
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
