import 'package:nutrenaissance_flutter/data/api/foodscanner/open_food_facts_api.dart';
import 'package:nutrenaissance_flutter/domain/models/foodscanner/barcode_nutrition_provider.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/nutrient_mapper_service.dart';

/// [BarcodeNutritionProvider] backed by the OpenFoodFacts REST API.
class OpenFoodFactsBarcodeProvider implements BarcodeNutritionProvider {
  final OpenFoodFactsApi _api;

  OpenFoodFactsBarcodeProvider({OpenFoodFactsApi? api})
      : _api = api ?? OpenFoodFactsApi();

  @override
  Future<BarcodeProduct?> lookupBarcode(String barcode) async {
    final product = await _api.getProduct(barcode);
    if (product == null) return null;

    final nutrients =
        NutrientMapperService.mapFromOpenFoodFacts(product.nutriments);
    final servingGrams =
        NutrientMapperService.parseServingGrams(product.servingSize);

    return BarcodeProduct(
      name: product.productName ?? barcode,
      brand: product.brands,
      nutrientsPer100g: nutrients,
      servingGrams: servingGrams,
      barcode: barcode,
    );
  }
}
