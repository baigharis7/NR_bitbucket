import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nutrenaissance_flutter/domain/models/foodscanner/visual_food_provider.dart';

/// Identifies foods in an image using the LogMeal API.
///
/// Flow:
/// 1. POST image to /v2/image/segmentation/complete → get dish names + imageId
/// 2. POST imageId to /v2/nutrition/recipe/nutritionalInfo → get kcal per dish
///
/// Step 2 is free (no extra credit) for the same imageId.
class LogMealProvider implements VisualFoodProvider {
  static const _baseUrl = 'https://api.logmeal.com';

  final String _apiToken;
  final http.Client _client;

  LogMealProvider({
    required String apiToken,
    http.Client? client,
  })  : _apiToken = apiToken,
        _client = client ?? http.Client();

  @override
  Future<List<VisualFoodResult>> identifyFoods(Uint8List imageBytes) async {
    try {
      // Step 1: Image segmentation — identify dishes
      debugPrint('[LogMeal] Sending ${imageBytes.length} bytes for segmentation...');
      final segmentationResult = await _segmentImage(imageBytes);
      if (segmentationResult == null) {
        debugPrint('[LogMeal] Segmentation returned null');
        return [];
      }

      final imageId = segmentationResult['imageId'] as int?;
      final segments = segmentationResult['segmentation_results'] as List<dynamic>?;

      // Some responses use 'foodType' at the top level with recognition results
      // nested differently — handle both structures
      if (imageId == null) {
        debugPrint('[LogMeal] No imageId in response: ${segmentationResult.keys}');
        return [];
      }

      // If no segmentation_results, try recognition_results at top level
      final recognitionResults = segments
          ?? segmentationResult['recognition_results'] as List<dynamic>?;

      if (recognitionResults == null || recognitionResults.isEmpty) {
        debugPrint('[LogMeal] No recognition results found. Keys: ${segmentationResult.keys}');
        return [];
      }

      debugPrint('[LogMeal] Found ${recognitionResults.length} segments, imageId=$imageId');

      // Step 2: Get nutritional info (free for same imageId)
      final nutritionMap = await _getNutritionalInfo(imageId);

      // Build results from segmentation/recognition data + nutrition
      final results = <VisualFoodResult>[];

      for (final item in recognitionResults) {
        final itemMap = item as Map<String, dynamic>;

        // Handle both structures:
        // Structure A (segmentation): { recognition_results: [{name, id, prob}] }
        // Structure B (flat): { name, id, prob }
        String? name;
        if (itemMap.containsKey('recognition_results')) {
          final recognition = itemMap['recognition_results'] as List<dynamic>?;
          if (recognition != null && recognition.isNotEmpty) {
            final top = recognition.first as Map<String, dynamic>;
            name = top['name'] as String?;
          }
        } else if (itemMap.containsKey('name')) {
          name = itemMap['name'] as String?;
        }

        if (name == null || name.isEmpty) continue;

        // Serving size from segmentation (if available)
        final servingSize = itemMap['serving_size'] as num?;

        // Nutrition for this dish
        double? kcal;
        if (nutritionMap != null) {
          kcal = _extractKcal(nutritionMap);
          // Approximate per-dish split if multiple dishes detected
          if (kcal != null && recognitionResults.length > 1) {
            kcal = kcal / recognitionResults.length;
          }
        }

        debugPrint('[LogMeal] Detected: $name (${servingSize}g, ${kcal}kcal)');
        results.add(VisualFoodResult(
          name: name,
          estimatedGrams: servingSize?.toDouble(),
          estimatedKcal: kcal,
        ));
      }

      debugPrint('[LogMeal] Total results: ${results.length}');
      return results;
    } catch (e) {
      debugPrint('[LogMeal] Error: $e');
      return [];
    }
  }

  /// POST image for segmentation and food recognition.
  Future<Map<String, dynamic>?> _segmentImage(Uint8List imageBytes) async {
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

    debugPrint('[LogMeal] Segmentation status: ${response.statusCode}');
    if (response.statusCode != 200) {
      debugPrint('[LogMeal] Segmentation error: ${response.body}');
      return null;
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('[LogMeal] Segmentation keys: ${json.keys.toList()}');
    return json;
  }

  /// POST imageId to get nutritional information (no extra credit).
  Future<Map<String, dynamic>?> _getNutritionalInfo(int imageId) async {
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
  }

  /// Extract kcal from the nutrition response.
  double? _extractKcal(Map<String, dynamic> nutrition) {
    // LogMeal returns nutrition under various keys depending on the response
    final info = nutrition['nutritional_info'] as Map<String, dynamic>?
        ?? nutrition['total_nutritional_info'] as Map<String, dynamic>?;
    if (info == null) return null;

    final calories = info['calories'] as num?
        ?? info['totalKCal'] as num?;
    return calories?.toDouble();
  }
}
