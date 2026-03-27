import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:nutrenaissance_flutter/data/api/foodscanner/claude_vision_provider.dart';

void main() {
  group('ClaudeVisionProvider', () {
    Uint8List fakeImage() => Uint8List.fromList([0xFF, 0xD8, 0xFF]);

    http_testing.MockClient _buildMockClient(int statusCode, String body) {
      return http_testing.MockClient(
          (_) async => http.Response(body, statusCode));
    }

    test('parses successful response with foods', () async {
      final responseBody = jsonEncode({
        'content': [
          {
            'type': 'text',
            'text':
                '[{"name": "scrambled eggs", "estimated_grams": 150}, {"name": "toast", "estimated_grams": 60}]',
          }
        ],
      });

      final client = _buildMockClient(200, responseBody);
      final provider =
          ClaudeVisionProvider(apiKey: 'test-key', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 2);
      expect(results[0].name, 'scrambled eggs');
      expect(results[0].estimatedGrams, 150.0);
      expect(results[1].name, 'toast');
      expect(results[1].estimatedGrams, 60.0);
    });

    test('handles markdown-fenced JSON response', () async {
      final responseBody = jsonEncode({
        'content': [
          {
            'type': 'text',
            'text':
                '```json\n[{"name": "rice", "estimated_grams": 200}]\n```',
          }
        ],
      });

      final client = _buildMockClient(200, responseBody);
      final provider =
          ClaudeVisionProvider(apiKey: 'test-key', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 1);
      expect(results[0].name, 'rice');
      expect(results[0].estimatedGrams, 200.0);
    });

    test('returns empty list for empty JSON array response', () async {
      final responseBody = jsonEncode({
        'content': [
          {'type': 'text', 'text': '[]'}
        ],
      });

      final client = _buildMockClient(200, responseBody);
      final provider =
          ClaudeVisionProvider(apiKey: 'test-key', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results, isEmpty);
    });

    test('returns empty list on non-200 status', () async {
      final client = _buildMockClient(429, 'Rate limited');
      final provider =
          ClaudeVisionProvider(apiKey: 'test-key', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results, isEmpty);
    });

    test('returns empty list when content is empty', () async {
      final responseBody = jsonEncode({'content': []});
      final client = _buildMockClient(200, responseBody);
      final provider =
          ClaudeVisionProvider(apiKey: 'test-key', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results, isEmpty);
    });

    test('returns empty list on malformed JSON', () async {
      final responseBody = jsonEncode({
        'content': [
          {'type': 'text', 'text': 'This is not JSON at all'}
        ],
      });

      final client = _buildMockClient(200, responseBody);
      final provider =
          ClaudeVisionProvider(apiKey: 'test-key', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results, isEmpty);
    });

    test('filters out empty-name results', () async {
      final responseBody = jsonEncode({
        'content': [
          {
            'type': 'text',
            'text':
                '[{"name": "banana", "estimated_grams": 120}, {"name": "", "estimated_grams": 50}]',
          }
        ],
      });

      final client = _buildMockClient(200, responseBody);
      final provider =
          ClaudeVisionProvider(apiKey: 'test-key', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 1);
      expect(results[0].name, 'banana');
    });

    test('handles null estimated_grams', () async {
      final responseBody = jsonEncode({
        'content': [
          {
            'type': 'text',
            'text': '[{"name": "soup"}]',
          }
        ],
      });

      final client = _buildMockClient(200, responseBody);
      final provider =
          ClaudeVisionProvider(apiKey: 'test-key', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 1);
      expect(results[0].name, 'soup');
      expect(results[0].estimatedGrams, isNull);
    });

    test('sends correct headers and model', () async {
      http.Request? capturedRequest;
      final client = http_testing.MockClient((request) async {
        capturedRequest = request;
        return http.Response(jsonEncode({'content': []}), 200);
      });

      final provider =
          ClaudeVisionProvider(apiKey: 'sk-test-123', client: client);
      await provider.identifyFoods(fakeImage());

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.headers['x-api-key'], 'sk-test-123');
      expect(capturedRequest!.headers['anthropic-version'], '2023-06-01');

      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['model'], contains('claude'));
    });

    test('returns empty list on network exception', () async {
      final client = http_testing.MockClient(
          (_) async => throw Exception('Network error'));
      final provider =
          ClaudeVisionProvider(apiKey: 'test-key', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results, isEmpty);
    });
  });
}
