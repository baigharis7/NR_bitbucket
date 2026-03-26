import 'package:nutrenaissance_flutter/domain/models/foodscanner/barcode_nutrition_provider.dart';

/// [BarcodeNutritionProvider] backed by the Passio Nutrition AI SDK.
///
/// Uses Passio's barcode lookup which returns a [PassioFoodItem].
/// The SDK must be initialized before using this provider.
///
/// TODO: Replace placeholder implementation once `nutrition_ai` package
/// is added and configured with an SDK key.
class PassioBarcodeProvider implements BarcodeNutritionProvider {
  @override
  Future<BarcodeProduct?> lookupBarcode(String barcode) async {
    // TODO: Implement with Passio SDK:
    //
    // final foodItem = await NutritionAI.instance
    //     .fetchFoodItemForProductCode(barcode);
    // if (foodItem == null) return null;
    //
    // final refNutrients = foodItem.nutrientsReference();
    // final passioMap = <String, double>{};
    // passioMap['calories'] = refNutrients.calories?.value ?? 0;
    // passioMap['protein'] = refNutrients.protein?.value ?? 0;
    // passioMap['carbs'] = refNutrients.carbs?.value ?? 0;
    // passioMap['fat'] = refNutrients.fat?.value ?? 0;
    // passioMap['saturatedFat'] = refNutrients.saturatedFat?.value ?? 0;
    // passioMap['transFat'] = refNutrients.transFat?.value ?? 0;
    // passioMap['fiber'] = refNutrients.fiber?.value ?? 0;
    // passioMap['sugar'] = refNutrients.sugars?.value ?? 0;
    // passioMap['sodium'] = refNutrients.sodium?.value ?? 0;
    // passioMap['cholesterol'] = refNutrients.cholesterol?.value ?? 0;
    // passioMap['calcium'] = refNutrients.calcium?.value ?? 0;
    // passioMap['iron'] = refNutrients.iron?.value ?? 0;
    // passioMap['potassium'] = refNutrients.potassium?.value ?? 0;
    // passioMap['vitaminA'] = refNutrients.vitaminA?.value ?? 0;
    // passioMap['vitaminC'] = refNutrients.vitaminC?.value ?? 0;
    // passioMap['vitaminD'] = refNutrients.vitaminD?.value ?? 0;
    //
    // final nutrients = NutrientMapperService.mapFromPassio(passioMap);
    // final servingGrams = foodItem.amount.weight().value;
    //
    // return BarcodeProduct(
    //   name: foodItem.name,
    //   brand: foodItem.details,
    //   nutrientsPer100g: nutrients,
    //   servingGrams: servingGrams,
    //   barcode: barcode,
    // );

    // Placeholder: return null until SDK is wired up.
    // When null is returned, the BLoC can fall back to OFF provider.
    return null;
  }
}
