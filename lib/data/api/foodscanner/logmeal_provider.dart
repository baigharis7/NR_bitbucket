import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nutrenaissance_flutter/domain/models/foodscanner/visual_food_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/crashlytics_service.dart';

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
    // Step 1: Image segmentation — identify dishes
    debugPrint('[LogMeal] Sending ${imageBytes.length} bytes for segmentation...');
    final segmentationResult = await _segmentImage(imageBytes);

    final imageId = segmentationResult['imageId'] as int?;
    if (imageId == null) {
      final msg = 'LogMeal: no imageId in response (keys: ${segmentationResult.keys.toList()})';
      debugPrint('[LogMeal] $msg');
      CrashlyticsService.instance.log(msg);
      return [];
    }

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

    // Step 2: Get nutritional info (free for same imageId)
    final nutritionMap = await _getNutritionalInfo(imageId);

    // Build results from segmentation/recognition data + nutrition
    final results = <VisualFoodResult>[];

    for (final item in segments) {
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
        if (kcal != null && segments.length > 1) {
          kcal = kcal / segments.length;
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
  }

  /// POST image for segmentation and food recognition.
  /// Throws on non-200 responses with status and body details.
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

  /// POST imageId to get nutritional information (no extra credit).
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

  /// Extract kcal from the nutrition response.
  double? _extractKcal(Map<String, dynamic> nutrition) {
    final info = nutrition['nutritional_info'] as Map<String, dynamic>?
        ?? nutrition['total_nutritional_info'] as Map<String, dynamic>?;
    if (info == null) return null;

    final calories = info['calories'] as num?
        ?? info['totalKCal'] as num?;
    return calories?.toDouble();
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
