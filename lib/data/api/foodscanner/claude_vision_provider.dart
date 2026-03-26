import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:nutrenaissance_flutter/infrastructure/services/nutrient_mapper_service.dart';

/// Identifies foods in an image using Claude Vision API.
///
/// Sends the image to Claude with a structured prompt and parses the
/// JSON response into a list of [VisualFoodResult].
class ClaudeVisionProvider {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-20250514';

  final String _apiKey;
  final http.Client _client;

  ClaudeVisionProvider({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  /// Identify foods in the given image bytes.
  ///
  /// Returns a list of detected foods with names and estimated portions.
  /// Returns empty list on error or if no food is detected.
  Future<List<VisualFoodResult>> identifyFoods(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final response = await _client.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
                {
                  'type': 'text',
                  'text': _prompt,
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode != 200) return [];

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final content = json['content'] as List<dynamic>?;
      if (content == null || content.isEmpty) return [];

      final textBlock = content.firstWhere(
        (block) => block['type'] == 'text',
        orElse: () => null,
      );
      if (textBlock == null) return [];

      final text = textBlock['text'] as String;
      return _parseResponse(text);
    } catch (_) {
      return [];
    }
  }

  static const _prompt = '''Identify all distinct food items visible in this image.

For each food item, provide:
- "name": the common English name (e.g. "scrambled eggs", "steamed broccoli", "white rice")
- "estimated_grams": your best estimate of the weight in grams

Return ONLY a JSON array, no other text:
[{"name": "...", "estimated_grams": ...}]

If no food is visible, return: []''';

  List<VisualFoodResult> _parseResponse(String text) {
    try {
      // Extract JSON array from response (may have markdown fences)
      var jsonStr = text.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr
            .replaceFirst(RegExp(r'^```\w*\n?'), '')
            .replaceFirst(RegExp(r'\n?```$'), '');
      }

      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return VisualFoodResult(
          name: map['name'] as String? ?? '',
          estimatedGrams: (map['estimated_grams'] as num?)?.toDouble(),
        );
      }).where((r) => r.name.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }
}

/// A food detected by Claude Vision.
class VisualFoodResult {
  final String name;
  final double? estimatedGrams;

  VisualFoodResult({required this.name, this.estimatedGrams});
}
