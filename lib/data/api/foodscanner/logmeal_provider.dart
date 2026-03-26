import 'dart:convert';
import 'dart:typed_data';

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
      final segmentationResult = await _segmentImage(imageBytes);
      if (segmentationResult == null) return [];

      final imageId = segmentationResult['imageId'] as int?;
      final segments = segmentationResult['segmentation_results'] as List<dynamic>?;
      if (imageId == null || segments == null || segments.isEmpty) return [];

      // Step 2: Get nutritional info (free for same imageId)
      final nutritionMap = await _getNutritionalInfo(imageId);

      // Build results from segmentation data + nutrition
      final results = <VisualFoodResult>[];
      for (final segment in segments) {
        final recognition = segment['recognition_results'] as List<dynamic>?;
        if (recognition == null || recognition.isEmpty) continue;

        // Take the top prediction
        final top = recognition.first as Map<String, dynamic>;
        final name = top['name'] as String? ?? '';
        if (name.isEmpty) continue;

        // Serving size from segmentation (if available)
        final servingSize = segment['serving_size'] as num?;

        // Nutrition for this dish (keyed by segment index or aggregated)
        double? kcal;
        if (nutritionMap != null) {
          kcal = _extractKcal(nutritionMap);
        }

        results.add(VisualFoodResult(
          name: name,
          estimatedGrams: servingSize?.toDouble(),
          estimatedKcal: kcal != null && segments.length > 1
              ? kcal / segments.length // approximate per-dish split
              : kcal,
        ));
      }

      return results;
    } catch (_) {
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

    if (response.statusCode != 200) return null;
    return jsonDecode(response.body) as Map<String, dynamic>;
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

    if (response.statusCode != 200) return null;
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Extract kcal from the nutrition response.
  double? _extractKcal(Map<String, dynamic> nutrition) {
    // LogMeal returns nutrition under "nutritional_info" or "total_nutritional_info"
    final info = nutrition['nutritional_info'] as Map<String, dynamic>?
        ?? nutrition['total_nutritional_info'] as Map<String, dynamic>?;
    if (info == null) return null;

    final calories = info['calories'] as num?
        ?? info['totalKCal'] as num?;
    return calories?.toDouble();
  }
}
