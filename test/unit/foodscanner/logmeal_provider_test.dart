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
      int confirmStatus = 200,
      String confirmBody = '{}',
      int ingredientsStatus = 200,
      String ingredientsBody = '{}',
      int nutritionStatus = 200,
      String nutritionBody = '{}',
    }) {
      return http_testing.MockClient((request) async {
        if (request.url.path.contains('segmentation')) {
          return http.Response(segmentationBody, segmentationStatus);
        } else if (request.url.path.contains('confirm/dish')) {
          return http.Response(confirmBody, confirmStatus);
        } else if (request.url.path.contains('ingredients')) {
          return http.Response(ingredientsBody, ingredientsStatus);
        } else if (request.url.path.contains('nutritionalInfo')) {
          return http.Response(nutritionBody, nutritionStatus);
        }
        return http.Response('Not found', 404);
      });
    }

    // -----------------------------------------------------------------------
    // identifyFoods — segmentation + filter + dedup + confirm
    // -----------------------------------------------------------------------

    test('returns foods from successful segmentation response', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({
          'imageId': 12345,
          'segmentation_results': [
            {
              'recognition_results': [
                {'name': 'Pizza', 'id': 1, 'prob': 0.95},
              ],
              'serving_size': 200,
            },
            {
              'recognition_results': [
                {'name': 'Salad', 'id': 2, 'prob': 0.88},
              ],
              'serving_size': 150,
            },
          ],
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 2);
      expect(results[0].name, 'Pizza');
      expect(results[0].estimatedGrams, 200.0);
      expect(results[0].confidence, 0.95);
      expect(results[0].logmealDishId, 1);
      expect(results[0].estimatedKcal, isNull); // No nutrition fetch
      expect(results[1].name, 'Salad');
      expect(results[1].estimatedGrams, 150.0);
      expect(provider.lastImageId, 12345);
    });

    test('filters out low-confidence results', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({
          'imageId': 100,
          'segmentation_results': [
            {
              'recognition_results': [
                {'name': 'Apple', 'id': 1, 'prob': 0.85},
              ],
            },
            {
              'recognition_results': [
                {'name': 'Ham meat', 'id': 2, 'prob': 0.3},
              ],
            },
            {
              'recognition_results': [
                {'name': 'Cream brioche', 'id': 3, 'prob': 0.2},
              ],
            },
          ],
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 1);
      expect(results[0].name, 'Apple');
    });

    test('deduplicates same-name results keeping highest confidence', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({
          'imageId': 100,
          'segmentation_results': [
            {
              'recognition_results': [
                {'name': 'Apple', 'id': 1, 'prob': 0.7},
              ],
              'serving_size': 100,
            },
            {
              'recognition_results': [
                {'name': 'Apple', 'id': 1, 'prob': 0.9},
              ],
              'serving_size': 150,
            },
            {
              'recognition_results': [
                {'name': 'apple', 'id': 1, 'prob': 0.6},
              ],
              'serving_size': 80,
            },
          ],
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 1);
      expect(results[0].confidence, 0.9); // Highest confidence kept
      expect(results[0].estimatedGrams, 150.0); // From highest confidence entry
    });

    test('handles flat recognition_results structure', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: jsonEncode({
          'imageId': 123,
          'recognition_results': [
            {'name': 'Banana', 'id': 10, 'prob': 0.92},
          ],
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final results = await provider.identifyFoods(fakeImage());

      expect(results.length, 1);
      expect(results[0].name, 'Banana');
      expect(results[0].logmealDishId, 10);
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

    test('sends correct authorization header', () async {
      String? capturedAuth;
      final client = http_testing.MockClient((request) async {
        if (request.url.path.contains('segmentation')) {
          capturedAuth = request.headers['Authorization'];
          return http.Response(
            jsonEncode({'imageId': 1, 'segmentation_results': []}),
            200,
          );
        }
        return http.Response('', 200);
      });

      final provider =
          LogMealProvider(apiToken: 'my-secret-token', client: client);
      await provider.identifyFoods(fakeImage());

      expect(capturedAuth, 'Bearer my-secret-token');
    });

    test('confirms dishes after successful segmentation', () async {
      bool confirmCalled = false;
      Map<String, dynamic>? confirmBody;

      final client = http_testing.MockClient((request) async {
        if (request.url.path.contains('segmentation')) {
          return http.Response(
            jsonEncode({
              'imageId': 42,
              'segmentation_results': [
                {
                  'recognition_results': [
                    {'name': 'Pizza', 'id': 7, 'prob': 0.95},
                  ],
                },
              ],
            }),
            200,
          );
        } else if (request.url.path.contains('confirm/dish')) {
          confirmCalled = true;
          confirmBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{}', 200);
        }
        return http.Response('', 200);
      });

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      await provider.identifyFoods(fakeImage());

      expect(confirmCalled, true);
      expect(confirmBody?['imageId'], 42);
      expect(confirmBody?['dishes'], [7]);
    });

    // -----------------------------------------------------------------------
    // getIngredients
    // -----------------------------------------------------------------------

    test('getIngredients returns ingredient list', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: '{}',
        ingredientsStatus: 200,
        ingredientsBody: jsonEncode({
          'ingredient_list': [
            {'name': 'Tomato', 'quantity': 50},
            {'name': 'Cheese', 'quantity': 30},
          ],
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final ingredients = await provider.getIngredients(42);

      expect(ingredients.length, 2);
      expect(ingredients[0]['name'], 'Tomato');
      expect(ingredients[1]['name'], 'Cheese');
    });

    test('getIngredients returns empty on error', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: '{}',
        ingredientsStatus: 500,
        ingredientsBody: 'Server Error',
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final ingredients = await provider.getIngredients(42);

      expect(ingredients, isEmpty);
    });

    // -----------------------------------------------------------------------
    // getNutritionForImage
    // -----------------------------------------------------------------------

    test('getNutritionForImage returns nutrition map', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: '{}',
        nutritionStatus: 200,
        nutritionBody: jsonEncode({
          'calories': 250.0,
          'protein': 12.0,
        }),
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final nutrition = await provider.getNutritionForImage(42);

      expect(nutrition, isNotNull);
      expect(nutrition!['calories'], 250.0);
    });

    test('getNutritionForImage returns null on error', () async {
      final client = _buildMockClient(
        segmentationStatus: 200,
        segmentationBody: '{}',
        nutritionStatus: 500,
        nutritionBody: 'Error',
      );

      final provider = LogMealProvider(apiToken: 'test-token', client: client);
      final nutrition = await provider.getNutritionForImage(42);

      expect(nutrition, isNull);
    });
  });
}
