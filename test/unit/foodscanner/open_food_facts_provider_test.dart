import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:nutrenaissance_flutter/data/api/foodscanner/open_food_facts_api.dart';
import 'package:nutrenaissance_flutter/data/api/foodscanner/open_food_facts_barcode_provider.dart';

void main() {
  group('OpenFoodFactsApi', () {
    test('returns product for valid barcode', () async {
      final client = http_testing.MockClient((request) async {
        expect(request.url.path, contains('737628064502'));
        return http.Response(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': 'Nutella',
              'brands': 'Ferrero',
              'nutriments': {
                'energy-kcal_100g': 539,
                'proteins_100g': 6.3,
                'fat_100g': 30.9,
              },
              'serving_size': '15 g',
            },
          }),
          200,
        );
      });

      final api = OpenFoodFactsApi(client: client);
      final product = await api.getProduct('737628064502');

      expect(product, isNotNull);
      expect(product!.productName, 'Nutella');
      expect(product.brands, 'Ferrero');
      expect(product.nutriments['energy-kcal_100g'], 539);
      expect(product.servingSize, '15 g');
    });

    test('returns null for product not found', () async {
      final client = http_testing.MockClient((_) async {
        return http.Response(jsonEncode({'status': 0}), 200);
      });

      final api = OpenFoodFactsApi(client: client);
      final product = await api.getProduct('0000000000');

      expect(product, isNull);
    });

    test('returns null on HTTP error', () async {
      final client =
          http_testing.MockClient((_) async => http.Response('', 500));

      final api = OpenFoodFactsApi(client: client);
      final product = await api.getProduct('123');

      expect(product, isNull);
    });

    test('returns null on network exception', () async {
      final client = http_testing.MockClient(
          (_) async => throw Exception('No internet'));

      final api = OpenFoodFactsApi(client: client);
      final product = await api.getProduct('123');

      expect(product, isNull);
    });

    test('returns null when product_name is empty', () async {
      final client = http_testing.MockClient((_) async {
        return http.Response(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': '',
              'nutriments': {},
            },
          }),
          200,
        );
      });

      final api = OpenFoodFactsApi(client: client);
      final product = await api.getProduct('123');

      expect(product, isNull);
    });
  });

  group('OpenFoodFactsBarcodeProvider', () {
    test('maps OFF product to BarcodeProduct with nutrients', () async {
      final client = http_testing.MockClient((_) async {
        return http.Response(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': 'Granola Bar',
              'brands': 'Nature Valley',
              'nutriments': {
                'energy-kcal_100g': 450,
                'proteins_100g': 8.0,
                'carbohydrates_100g': 62.0,
                'fat_100g': 18.0,
                'saturated-fat_100g': 2.5,
                'sodium_100g': 0.3,
              },
              'serving_size': '42 g',
            },
          }),
          200,
        );
      });

      final api = OpenFoodFactsApi(client: client);
      final provider = OpenFoodFactsBarcodeProvider(api: api);
      final product = await provider.lookupBarcode('016000275867');

      expect(product, isNotNull);
      expect(product!.name, 'Granola Bar');
      expect(product.brand, 'Nature Valley');
      expect(product.barcode, '016000275867');
      expect(product.servingGrams, 42.0);

      // Verify nutrient mapping
      expect(product.nutrientsPer100g['energyKcal'], 450.0);
      expect(product.nutrientsPer100g['proteinLabel'], 8.0);
      expect(product.nutrientsPer100g['carbsAvailable'], 62.0);
      expect(product.nutrientsPer100g['fatTotal'], 18.0);
      expect(product.nutrientsPer100g['saturated'], 2.5);
      expect(product.nutrientsPer100g['sumSat'], 2.5); // duplicated
      expect(product.nutrientsPer100g['sodium'], 0.3);
    });

    test('returns null when OFF product not found', () async {
      final client = http_testing.MockClient((_) async {
        return http.Response(jsonEncode({'status': 0}), 200);
      });

      final api = OpenFoodFactsApi(client: client);
      final provider = OpenFoodFactsBarcodeProvider(api: api);
      final product = await provider.lookupBarcode('0000000');

      expect(product, isNull);
    });

    test('uses barcode as name when product_name missing', () async {
      final client = http_testing.MockClient((_) async {
        return http.Response(
          jsonEncode({
            'status': 1,
            'product': {
              'product_name': null,
              'nutriments': {'energy-kcal_100g': 100},
            },
          }),
          200,
        );
      });

      final api = OpenFoodFactsApi(client: client);
      // Product has null name → isFound returns false → api returns null
      final product = await api.getProduct('999');
      expect(product, isNull);
    });
  });
}
