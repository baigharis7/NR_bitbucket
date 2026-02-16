import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';

/// Handles fetching, parsing, and storing reference data in the Drift database.
///
/// Reference data includes:
/// - `nutrients.json` — full nutrient composition per food/drink (~1800 items)
/// - `nutrients_loss_table.json` — nutrient retention losses per cooking method
/// - `cookingMethodsOilsInfo` — oil absorption percentage per cooking method
/// - `sports.json` — full METs array per sport (one value per intensity level)
///
/// **Backend requirement**: Expose these S3 files via API endpoints (or extend
/// `/manage-master-files` to include them with version tracking).
class ReferenceDataService {
  final ReferenceDatabase _db;

  ReferenceDataService(this._db);

  // Version keys stored in the ReferenceDataVersions table
  static const _kNutrients = 'nutrients';
  static const _kNutrientLoss = 'nutrientLoss';
  static const _kCookingOils = 'cookingOils';
  static const _kSportMets = 'sportMets';
  static const kObjectiveNutrients = 'objectiveNutrients';
  static const kNutrientObjective = 'nutrientObjective';

  // ---------------------------------------------------------------------------
  // Public: call from app startup
  // ---------------------------------------------------------------------------

  /// Check local versions against server versions and re-download if stale.
  /// Returns true if any data was updated.
  ///
  /// [fetchNutrientsJson], [fetchNutrientLossJson], etc. are callbacks that
  /// return the raw JSON string from your API. Pass `null` to skip a category.
  Future<bool> refreshIfNeeded({
    Future<ReferencePayload?> Function()? fetchNutrients,
    Future<ReferencePayload?> Function()? fetchNutrientLoss,
    Future<ReferencePayload?> Function()? fetchCookingOils,
    Future<ReferencePayload?> Function()? fetchSportMets,
    Future<ReferencePayload?> Function()? fetchObjectiveNutrients,
    Future<ReferencePayload?> Function()? fetchNutrientObjective,
  }) async {
    bool updated = false;

    if (fetchNutrients != null) {
      final payload = await fetchNutrients();
      if (payload != null) {
        final localVersion = await _db.getReferenceVersion(_kNutrients);
        if (payload.version > localVersion) {
          await loadNutrientsJson(payload.json);
          await _db.setReferenceVersion(_kNutrients, payload.version);
          updated = true;
        }
      }
    }

    if (fetchNutrientLoss != null) {
      final payload = await fetchNutrientLoss();
      if (payload != null) {
        final localVersion = await _db.getReferenceVersion(_kNutrientLoss);
        if (payload.version > localVersion) {
          await loadNutrientLossJson(payload.json);
          await _db.setReferenceVersion(_kNutrientLoss, payload.version);
          updated = true;
        }
      }
    }

    if (fetchCookingOils != null) {
      final payload = await fetchCookingOils();
      if (payload != null) {
        final localVersion = await _db.getReferenceVersion(_kCookingOils);
        if (payload.version > localVersion) {
          await loadCookingMethodOilsJson(payload.json);
          await _db.setReferenceVersion(_kCookingOils, payload.version);
          updated = true;
        }
      }
    }

    if (fetchSportMets != null) {
      final payload = await fetchSportMets();
      if (payload != null) {
        final localVersion = await _db.getReferenceVersion(_kSportMets);
        if (payload.version > localVersion) {
          await loadSportMetsJson(payload.json);
          await _db.setReferenceVersion(_kSportMets, payload.version);
          updated = true;
        }
      }
    }

    if (fetchObjectiveNutrients != null) {
      final payload = await fetchObjectiveNutrients();
      if (payload != null) {
        final localVersion = await _db.getReferenceVersion(kObjectiveNutrients);
        if (payload.version > localVersion) {
          await _db.setReferenceBlob(kObjectiveNutrients, payload.json);
          await _db.setReferenceVersion(kObjectiveNutrients, payload.version);
          updated = true;
        }
      }
    }

    if (fetchNutrientObjective != null) {
      final payload = await fetchNutrientObjective();
      if (payload != null) {
        final localVersion = await _db.getReferenceVersion(kNutrientObjective);
        if (payload.version > localVersion) {
          await _db.setReferenceBlob(kNutrientObjective, payload.json);
          await _db.setReferenceVersion(kNutrientObjective, payload.version);
          updated = true;
        }
      }
    }

    return updated;
  }

  // ---------------------------------------------------------------------------
  // Loaders: parse JSON and batch-insert into Drift
  // ---------------------------------------------------------------------------

  /// Parses the S3 `nutrients.json` file and populates the
  /// NutrientCompositions table.
  ///
  /// Expected format (array of objects):
  /// ```json
  /// [
  ///   {
  ///     "id": 1,
  ///     "isFood": 0,
  ///     "g": "cereals",
  ///     "en": "Wheat flour",
  ///     "es": "Harina de trigo",
  ///     "recommendable": 1,
  ///     "freeSugar": "0",
  ///     "params": { "energyKcal": 364, "protein": 10.3, ... }
  ///   },
  ///   ...
  /// ]
  /// ```
  Future<void> loadNutrientsJson(String json) async {
    final List<dynamic> items = jsonDecode(json);
    final entries = items.map((item) {
      final map = item as Map<String, dynamic>;
      final params = map['params'] as Map<String, dynamic>? ?? {};
      // Ensure all param values are doubles
      final cleanParams = params.map((k, v) =>
          MapEntry(k, v is num ? v.toDouble() : 0.0));

      return NutrientCompositionsCompanion(
        foodId: Value(map['id'] as int),
        isFood: Value(map['isFood'] as int? ?? 0),
        group: Value(map['g'] as String? ?? ''),
        nameEn: Value(map['en'] as String? ?? ''),
        nameEs: Value(map['es'] as String? ?? ''),
        recommendable: Value(map['recommendable'] as int? ?? 0),
        freeSugar: Value(map['freeSugar']?.toString()),
        params: Value(jsonEncode(cleanParams)),
      );
    }).toList();

    await _db.replaceAllNutrientCompositions(entries);
  }

  /// Parses the S3 `nutrients_loss_table.json` file and populates the
  /// NutrientLosses table.
  ///
  /// Expected format (array of objects):
  /// ```json
  /// [
  ///   {
  ///     "cookingMethodId": 1,
  ///     "nutrients": { "vitC": 0.25, "vitB1": 0.15, ... }
  ///   },
  ///   ...
  /// ]
  /// ```
  Future<void> loadNutrientLossJson(String json) async {
    final List<dynamic> items = jsonDecode(json);
    final entries = items.map((item) {
      final map = item as Map<String, dynamic>;
      final nutrients = map['nutrients'] as Map<String, dynamic>? ?? {};
      final cleanLosses = nutrients.map((k, v) =>
          MapEntry(k, v is num ? v.toDouble() : 0.0));

      return NutrientLossesCompanion(
        cookingMethodId: Value(map['cookingMethodId'] as int),
        losses: Value(jsonEncode(cleanLosses)),
      );
    }).toList();

    await _db.replaceAllNutrientLosses(entries);
  }

  /// Parses the `cookingMethodsOilsInfo` data and populates the
  /// CookingMethodOils table.
  ///
  /// Expected format (array of objects):
  /// ```json
  /// [
  ///   { "id": 1, "percentage": 0.05 },
  ///   { "id": 5, "percentage": 0.10 },
  ///   ...
  /// ]
  /// ```
  Future<void> loadCookingMethodOilsJson(String json) async {
    final List<dynamic> items = jsonDecode(json);
    final entries = items.map((item) {
      final map = item as Map<String, dynamic>;
      return CookingMethodOilsCompanion(
        cookingMethodId: Value(map['id'] as int),
        percentage: Value((map['percentage'] as num).toDouble()),
      );
    }).toList();

    await _db.replaceAllCookingMethodOils(entries);
  }

  /// Parses the S3 `sports.json` file and populates the SportMets table.
  ///
  /// Expected format (array of objects):
  /// ```json
  /// [
  ///   {
  ///     "id": 1,
  ///     "en": "Running",
  ///     "es": "Correr",
  ///     "mets": ["3,5", "7,0", "10,5"]
  ///   },
  ///   ...
  /// ]
  /// ```
  /// METs values are comma-decimal strings (European format).
  Future<void> loadSportMetsJson(String json) async {
    final List<dynamic> items = jsonDecode(json);
    final entries = items.map((item) {
      final map = item as Map<String, dynamic>;
      final rawMets = map['mets'] as List<dynamic>? ?? [];
      final mets = rawMets.map((m) {
        final str = m.toString().replaceAll(',', '.');
        return double.tryParse(str) ?? 0.0;
      }).toList();

      return SportMetsCompanion(
        sportId: Value(map['id'] as int),
        nameEn: Value(map['en'] as String? ?? ''),
        nameEs: Value(map['es'] as String? ?? ''),
        mets: Value(jsonEncode(mets)),
      );
    }).toList();

    await _db.replaceAllSportMets(entries);
  }
}

/// Wrapper for a reference data fetch result.
class ReferencePayload {
  final int version;
  final String json;

  ReferencePayload({required this.version, required this.json});
}
