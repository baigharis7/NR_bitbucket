import 'dart:convert';

import 'package:nutrenaissance_flutter/data/api/foodevents/model/upload_food_event.dart'
    as food_model;
import 'package:nutrenaissance_flutter/data/api/liquidevents/model/upload_liquid_event.dart'
    as liquid_model;
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/conversion_factors_info_entity.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_simple.dart';

/// Ports the food-event-amplify and liquid-event-amplify Lambda logic to Dart.
///
/// All reference data is looked up from the local Drift database (nutrients,
/// nutrient losses, cooking method oils) and existing Hive data (units foods,
/// conversion factors info).
class NutrientCalculationService {
  final ReferenceDatabase _db;

  NutrientCalculationService(this._db);

  // -- Food IDs that skip the conversion factor (from Lambda hardcoded list)
  static const _skipConversionFactorIds = {
    31, 272, 1271, 1752, 1794, 1812, 1813, 1827, 1847
  };

  // Food ID that forces conversion factor = 3
  static const _forceConversionFactorId = 1865;
  static const _forcedConversionFactor = 3.0;

  // Cooking method ID for "fried"
  static const _friedCookingMethodId = 5;

  // Kcal per gram of fat (oil)
  static const _oilKcalPerGram = 9.0;

  // -------------------------------------------------------------------------
  // Food event enrichment
  // -------------------------------------------------------------------------

  /// Computes a fully enriched [food_model.UploadFoodEvent] from a
  /// [FoodEventSimple], replicating the food-event-amplify Lambda.
  ///
  /// [unitsFoods] and [conversionFactorsInfo] come from existing Hive data.
  Future<food_model.UploadFoodEvent> enrichFoodEvent(
    FoodEventSimple simple, {
    required List<UnitFoodEntity> unitsFoods,
    required List<ConversionFactorInfoEntity> conversionFactorsInfo,
  }) async {
    final List<food_model.FoodInfo> enrichedFoods = [];
    int totalEventKcals = 0;

    // Process ingredients (foods)
    for (final ingredient in simple.ingredients ?? <FoodInEvent>[]) {
      final result = await _enrichFoodItem(
        foodId: ingredient.id,
        qty: ingredient.qty,
        unitId: ingredient.unit,
        conversionFactorId: ingredient.conversionFactor,
        cookingMethodId: ingredient.cookingMethod,
        usedOilId: ingredient.usedOil,
        isFood: true,
        unitsFoods: unitsFoods,
        conversionFactorsInfo: conversionFactorsInfo,
      );
      if (result != null) {
        enrichedFoods.add(result);
        totalEventKcals += (result.params?.energyKcal ?? 0).round();
      }
    }

    // Process drinks
    for (final drink in simple.drinks ?? <FoodInEvent>[]) {
      final result = await _enrichFoodItem(
        foodId: drink.id,
        qty: drink.qty,
        unitId: drink.unit,
        conversionFactorId: drink.conversionFactor,
        cookingMethodId: drink.cookingMethod,
        usedOilId: drink.usedOil,
        isFood: false,
        unitsFoods: unitsFoods,
        conversionFactorsInfo: conversionFactorsInfo,
      );
      if (result != null) {
        enrichedFoods.add(result);
        totalEventKcals += (result.params?.energyKcal ?? 0).round();
      }
    }

    return food_model.UploadFoodEvent(
      simple.userId,
      simple.eventDate,
      simple.eventId,
      simple.mealType,
      simple.foodName,
      simple.comment,
      enrichedFoods,
      simple.dish,
      totalEventKcals,
      uploadSuccess: true,
    );
  }

  // -------------------------------------------------------------------------
  // Liquid event enrichment
  // -------------------------------------------------------------------------

  /// Computes a fully enriched [liquid_model.UploadLiquidEvent] from a
  /// [LiquidEventSimple], replicating the liquid-event-amplify Lambda.
  Future<liquid_model.UploadLiquidEvent> enrichLiquidEvent(
    LiquidEventSimple simple,
  ) async {
    final List<liquid_model.LiquidInfo> enrichedDrinks = [];
    int totalEventKcals = 0;

    for (final drink in simple.drinks ?? <LiquidInEvent>[]) {
      final composition = await _db.getNutrientComposition(drink.id);
      if (composition == null) continue;

      final nutrientMap = _decodeParams(composition.params);
      final double qty = drink.qty.toDouble();

      // Liquid formula: qty * nutrientValue / 100
      final Map<String, double> computed = {};
      for (final entry in nutrientMap.entries) {
        computed[entry.key] = qty * entry.value / 100.0;
      }

      final params = _mapToLiquidParams(computed);
      final energyKcal = computed['energyKcal'] ?? 0.0;
      totalEventKcals += energyKcal.round();

      enrichedDrinks.add(liquid_model.LiquidInfo(
        liquid_model.EventInfo(null, qty, null, null),
        composition.group,
        drink.id,
        composition.nameEn,
        composition.nameEs,
        composition.recommendable,
        params,
        composition.freeSugar,
      ));
    }

    return liquid_model.UploadLiquidEvent(
      simple.userId,
      simple.date,
      enrichedDrinks,
      totalEventKcals,
      uploadSuccess: true,
    );
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  Future<food_model.FoodInfo?> _enrichFoodItem({
    required int foodId,
    required int qty,
    required int unitId,
    required int? conversionFactorId,
    required int cookingMethodId,
    required int? usedOilId,
    required bool isFood,
    required List<UnitFoodEntity> unitsFoods,
    required List<ConversionFactorInfoEntity> conversionFactorsInfo,
  }) async {
    final composition = await _db.getNutrientComposition(foodId);
    if (composition == null) return null;

    final nutrientMap = _decodeParams(composition.params);

    // 1. Resolve unit value (grams per unit)
    final unitValue = _unitValueByQuantity(foodId, unitId, unitsFoods);
    double foodWeight = qty.toDouble() * unitValue;
    final double originalWeight = foodWeight;

    double oilKcal = 0;

    if (isFood) {
      // 2. Apply conversion factor (raw→cooked weight adjustment)
      if (conversionFactorId != null &&
          !_skipConversionFactorIds.contains(foodId)) {
        double factor;
        if (foodId == _forceConversionFactorId) {
          factor = _forcedConversionFactor;
        } else {
          factor = _lookupConversionFactor(
            conversionFactorId,
            composition.group,
            conversionFactorsInfo,
          );
        }
        if (factor > 0) {
          foodWeight /= factor;
        }
      }

      // 3. Apply cooking method oil absorption
      if (cookingMethodId > 0) {
        final cookingOil = await _db.getCookingMethodOil(cookingMethodId);
        if (cookingOil != null && cookingOil.percentage > 0) {
          foodWeight *= (1.0 + cookingOil.percentage);

          // Fried foods get extra oil kcal
          if (cookingMethodId == _friedCookingMethodId) {
            oilKcal = originalWeight * cookingOil.percentage * _oilKcalPerGram;
          }
        }
      }
    }

    // 4. Compute each nutrient: foodWeight * nutrientValue / 100
    final Map<String, double> computed = {};
    for (final entry in nutrientMap.entries) {
      double nutrientQty = foodWeight * entry.value / 100.0;

      // 5. Apply nutrient loss for cooking method
      if (isFood && cookingMethodId > 0) {
        final loss = await _getNutrientLoss(cookingMethodId, entry.key);
        if (loss > 0) {
          nutrientQty *= (1.0 - loss);
        }
      }

      computed[entry.key] = nutrientQty;
    }

    // Add oil kcal to energyKcal for fried foods
    if (oilKcal > 0) {
      computed['energyKcal'] = (computed['energyKcal'] ?? 0) + oilKcal;
    }

    final params = _mapToFoodParams(computed);

    return food_model.FoodInfo(
      food_model.EventInfo(
        cookingMethodId,
        qty.toDouble(),
        unitId,
        conversionFactorId,
        usedOilId,
        null, // waste
      ),
      composition.freeSugar,
      composition.group,
      foodId,
      composition.nameEn,
      composition.nameEs,
      composition.recommendable,
      params,
    );
  }

  /// Resolve unit-to-gram conversion for a food.
  /// The `units` field in UnitFoodEntity is a pipe-delimited string:
  ///   "unitId,grams|unitId,grams|..."
  /// or a single "unitId,grams" with no pipe.
  double _unitValueByQuantity(
    int foodId,
    int unitId,
    List<UnitFoodEntity> unitsFoods,
  ) {
    final entry = unitsFoods.where((e) => e.id == foodId).firstOrNull;
    if (entry == null) return 1.0;

    if (entry.units.contains('|')) {
      for (final pair in entry.units.split('|')) {
        final commaIdx = pair.indexOf(',');
        if (commaIdx < 0) continue;
        final unitKey = int.tryParse(pair.substring(0, commaIdx));
        if (unitKey == unitId) {
          return double.tryParse(pair.substring(commaIdx + 1)) ?? 1.0;
        }
      }
    } else {
      final commaIdx = entry.units.indexOf(',');
      if (commaIdx >= 0) {
        return double.tryParse(entry.units.substring(commaIdx + 1)) ?? 1.0;
      }
    }

    return 1.0;
  }

  /// Look up the conversion factor value for a given factorId and food group.
  double _lookupConversionFactor(
    int factorId,
    String foodGroup,
    List<ConversionFactorInfoEntity> factors,
  ) {
    final factorInfo = factors.where((f) => f.id == factorId).firstOrNull;
    if (factorInfo == null) return 1.0;

    // Find the entry matching this food's group
    for (final item in factorInfo.list) {
      if (item.g == foodGroup) {
        return item.v.toDouble();
      }
    }

    // Fallback: return the first value if no group match
    if (factorInfo.list.isNotEmpty) {
      return factorInfo.list.first.v.toDouble();
    }
    return 1.0;
  }

  /// Get the nutrient loss fraction for a cooking method and nutrient key.
  Future<double> _getNutrientLoss(
    int cookingMethodId,
    String nutrientKey,
  ) async {
    final lossEntry = await _db.getNutrientLoss(cookingMethodId);
    if (lossEntry == null) return 0.0;

    final losses = _decodeLosses(lossEntry.losses);
    return losses[nutrientKey] ?? 0.0;
  }

  Map<String, double> _decodeParams(String json) {
    final decoded = jsonDecode(json);
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(
        k.toString(),
        (v is num) ? v.toDouble() : 0.0,
      ));
    }
    return {};
  }

  Map<String, double> _decodeLosses(String json) {
    final decoded = jsonDecode(json);
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(
        k.toString(),
        (v is num) ? v.toDouble() : 0.0,
      ));
    }
    return {};
  }

  /// Converts computed nutrient map → typed Params for food events.
  food_model.Params _mapToFoodParams(Map<String, double> m) {
    return food_model.Params(
      m['alanine'],
      m['arginine'],
      m['arsenic'],
      m['ash'],
      m['asparticAcid'],
      m['benzoicAcid'],
      m['betacaroteneVitA'],
      m['c16_0'],
      m['c18_0'],
      m['c18_1N_9'],
      m['c18_2N_6'],
      m['c18_3N_3'],
      m['cadmium'],
      m['calcium'],
      m['carbsAvailable'],
      m['carbsByDiff'],
      m['carbsDeclared'],
      m['celulose'],
      m['chromium'],
      m['copper'],
      m['cystine'],
      m['dryMatter'],
      m['energyKcal'],
      m['energyKJ'],
      m['fatTotal'],
      m['fattyAcidConversionFactor'],
      m['fattyAcidsTotal'],
      m['fiber'],
      m['fructose'],
      m['glucose'],
      m['glutamicAcid'],
      m['glycine'],
      m['hexose'],
      m['histamine'],
      m['histidine'],
      m['hydroxyproline'],
      m['iodine'],
      m['iron'],
      m['isoleucine'],
      m['lead'],
      m['leucine'],
      m['lignin'],
      m['lysine'],
      m['magnesium'],
      m['manganese'],
      m['mercury'],
      m['methionine'],
      m['monosaccharidesTotal'],
      m['nickel'],
      m['nitro2protein'],
      m['nitrogen'],
      m['pentose'],
      m['phenylalanine'],
      m['phosphorus'],
      m['potassium'],
      m['proline'],
      m['proteinLabel'],
      m['proteinSci'],
      m['selenium'],
      m['serin'],
      m['sodium'],
      m['starch'],
      m['sugarsTotal'],
      m['sumMonoUnsat'],
      m['sumN3FattyAcids'],
      m['sumN6FattyAcids'],
      m['sumPolyUnsat'],
      m['sumSat'],
      m['threonine'],
      m['tryptophan'],
      m['tyrosine'],
      m['uronicAcid'],
      m['valin'],
      m['vitA'],
      m['vitB1'],
      m['vitB2'],
      m['vitB3'],
      m['vitB3Eq'],
      m['vitB5'],
      m['vitB6'],
      m['vitB7'],
      m['vitB9'],
      m['vitB9Free'],
      m['vitB12'],
      m['vitC'],
      m['vitCL'],
      m['vitCLDehydro'],
      m['vitD'],
      m['vitD2'],
      m['vitD3'],
      m['vitD_25hydroxi'],
      m['vitD3_25hydroxi'],
      m['vitE'],
      m['vitE_alphaTP'],
      m['water'],
      m['zinc'],
      m['other'],
      m['saturated'],
      m['monounsaturated'],
      m['polyunsaturated'],
      m['totalTrans'],
      m['total'],
      m['n3'],
      m['n6'],
      m['cholesterol'],
      m['chloride'],
      m['molybdenum'],
      m['cobalt'],
      m['fluoron'],
      m['silicon'],
      m['rubidium'],
      m['aluminum'],
      m['boron'],
      m['bromine'],
      m['arsenInorganic'],
      m['omega3'],
    );
  }

  /// Converts computed nutrient map → typed Params for liquid events.
  liquid_model.Params _mapToLiquidParams(Map<String, double> m) {
    return liquid_model.Params(
      m['alanine'],
      m['arginine'],
      m['arsenic'],
      m['ash'],
      m['asparticAcid'],
      m['benzoicAcid'],
      m['betacaroteneVitA'],
      m['c16_0'],
      m['c18_0'],
      m['c18_1N_9'],
      m['c18_2N_6'],
      m['c18_3N_3'],
      m['cadmium'],
      m['calcium'],
      m['carbsAvailable'],
      m['carbsByDiff'],
      m['carbsDeclared'],
      m['celulose'],
      m['chromium'],
      m['copper'],
      m['cystine'],
      m['dryMatter'],
      m['energyKcal'],
      m['energyKJ'],
      m['fatTotal'],
      m['fattyAcidConversionFactor'],
      m['fattyAcidsTotal'],
      m['fiber'],
      m['fructose'],
      m['glucose'],
      m['glutamicAcid'],
      m['glycine'],
      m['hexose'],
      m['histamine'],
      m['histidine'],
      m['hydroxyproline'],
      m['iodine'],
      m['iron'],
      m['isoleucine'],
      m['lead'],
      m['leucine'],
      m['lignin'],
      m['lysine'],
      m['magnesium'],
      m['manganese'],
      m['mercury'],
      m['methionine'],
      m['monosaccharidesTotal'],
      m['nickel'],
      m['nitro2protein'],
      m['nitrogen'],
      m['pentose'],
      m['phenylalanine'],
      m['phosphorus'],
      m['potassium'],
      m['proline'],
      m['proteinLabel'],
      m['proteinSci'],
      m['selenium'],
      m['serin'],
      m['sodium'],
      m['starch'],
      m['sugarsTotal'],
      m['sumMonoUnsat'],
      m['sumN3FattyAcids'],
      m['sumN6FattyAcids'],
      m['sumPolyUnsat'],
      m['sumSat'],
      m['threonine'],
      m['tryptophan'],
      m['tyrosine'],
      m['uronicAcid'],
      m['valin'],
      m['vitA'],
      m['vitB1'],
      m['vitB2'],
      m['vitB3'],
      m['vitB3Eq'],
      m['vitB5'],
      m['vitB6'],
      m['vitB7'],
      m['vitB9'],
      m['vitB9Free'],
      m['vitB12'],
      m['vitC'],
      m['vitCL'],
      m['vitCLDehydro'],
      m['vitD'],
      m['vitD2'],
      m['vitD3'],
      m['vitD_25hydroxi'],
      m['vitD3_25hydroxi'],
      m['vitE'],
      m['vitE_alphaTP'],
      m['water'],
      m['zinc'],
      m['other'],
      m['saturated'],
      m['monounsaturated'],
      m['polyunsaturated'],
      m['totalTrans'],
      m['total'],
      m['n3'],
      m['n6'],
      m['cholesterol'],
      m['chloride'],
      m['molybdenum'],
      m['cobalt'],
      m['fluoron'],
      m['silicon'],
      m['rubidium'],
      m['aluminum'],
      m['boron'],
      m['bromine'],
      m['arsenInorganic'],
      m['omega3'],
    );
  }
}
