import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:nutrenaissance_flutter/data/api/foodscanner/logmeal_provider.dart';

void main() {
  group('LogMealProvider', () {
    Uint8List fakeImage() => Uint8List.fromList([0xFF, 0xD8, 0xFF]);

    http_testing.MockClient _buildMockClient({
      required int segmentationStatus,
      required String segmentationBody,
      int nutritionStatus = 200,
      String nutritionBody = '{}',
    }) {
      return http_testing.MockClient((request) async {
        if (request.url.path.contains('segmentation')) {
          return http.Response(segmentationBody, segmentationStatus);
        } else if (request.url.path.contains('nutritionalInfo')) {
          return http.Response(nutritionBody, nutritionStatus);
        }
        return http.Response('Not found', 404);
      });
    }

    test('returns foods from successful segmentation response', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({
          'imageId': 12345,
          'segmentation_results': [
            {
              'recognition_results': [
                {'name': 'Pizza', 'id': '001', 'prob': 0.95},
              ],
              'serving_size': 200,
            },
            {
              'recognition_results': [
                {'name': 'Salad', 'id': '002', 'prob': 0.88},
              ],
              'serving_size': 150,
            },
          ],
        }),
        nutritionStatus: 200,
        nutritionBody: jsonEncode({
          'nutritional_info': {'calories': 600.0},
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 2);
      expect(results[0].name, 'Pizza');
      expect(results[0].estimatedGrams, 200.0);
      expect(results[0].estimatedKcal, 300.0); // 600 / 2 dishes
      expect(results[1].name, 'Salad');
      expect(results[1].estimatedGrams, 150.0);
    });

    test('handles flat recognition_results structure', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({
          'imageId': 123,
          'recognition_results': [
            {'name': 'Banana', 'id': '010', 'prob': 0.92},
          ],
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 1);
      expect(results[0].name, 'Banana');
    });

    test('throws LogMealException on non-200 segmentation', () async {
      final client = _buildMockClient(
        segmentationStatus: 401,
        segmentationBody: '{"message": "Invalid token"}',
      );

      final provider = LogMealProvider(apiToken: 'bad-token', client: client);

      expect(
        () => provider.identifyFoods(fakeImage()),
        throwsA(isA<LogMealException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
    });

    test('returns empty list when no imageId in response', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({'error': 'no food detected'}),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results, isEmpty);
    });

    test('returns empty list when no recognition results', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({
          'imageId': 123,
          'segmentation_results': [],
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results, isEmpty);
    });

    test('handles nutrition endpoint failure gracefully', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({
          'imageId': 123,
          'segmentation_results': [
            {
              'recognition_results': [
                {'name': 'Apple', 'id': '005', 'prob': 0.90},
              ],
            },
          ],
        }),
        nutritionStatus: 500,
        nutritionBody: 'Internal Server Error',
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 1);
      expect(results[0].name, 'Apple');
      expect(results[0].estimatedKcal, isNull); // nutrition failed
    });

    test('sends correct authorization header', () async {
      String? capturedAuth;
      final client = http_testing.MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        if (request.url.path.contains('segmentation')) {
          return http.Response(
            jsonEncode({'imageId': 1, 'segmentation_results': []}),
            200,
          );
        }
        return http.Response('', 404);
      });

      final provider =
          LogMealProvider(apiToken: 'my-secret-token', client: client);
      await provider.identifyFoods(fakeImage());

      expect(capturedAuth, 'Bearer my-secret-token');
    });

    test('single dish gets full kcal (no division)', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({
          'imageId': 123,
          'segmentation_results': [
            {
              'recognition_results': [
                {'name': 'Pasta', 'id': '003', 'prob': 0.95},
              ],
              'serving_size': 300,
            },
          ],
        }),
        nutritionStatus: 200,
        nutritionBody: jsonEncode({
          'nutritional_info': {'calories': 450.0},
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 1);
      expect(results[0].estimatedKcal, 450.0); // not divided
    });
  });
}
