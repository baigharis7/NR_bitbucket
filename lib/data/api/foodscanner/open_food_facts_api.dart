import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutrenaissance_flutter/data/api/foodscanner/model/open_food_facts_product.dart';

/// REST client for the OpenFoodFacts product API.
///
/// No authentication required — only a User-Agent header.
class OpenFoodFactsApi {
  static const _baseUrl = 'https://world.openfoodfacts.net/api/v2/product';
  static const _userAgent = 'NutreNaissance/1.1.0 (Flutter)';

  final http.Client _client;

  OpenFoodFactsApi({http.Client? client}) : _client = client ?? http.Client();

  /// Look up a product by barcode.
  /// Returns null on network error or if product not found.
  Future<OpenFoodFactsProduct?> getProduct(String barcode) async {
    try {
      final uri = Uri.parse('$_baseUrl/$barcode.json');
      final response = await _client.get(uri, headers: {
        'User-Agent': _userAgent,
      });

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as int?;
      if (status != 1) return null;

      final product = OpenFoodFactsProduct.fromJson(barcode, json);
      return product.isFound ? product : null;
    } catch (_) {
      return null;
    }
  }
}
