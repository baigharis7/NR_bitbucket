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
    // Fire all non-null fetches in parallel — each writes to a separate table
    final results = await Future.wait([
      if (fetchNutrients != null)
        _refreshCategory(fetchFn: fetchNutrients, versionKey: _kNutrients, onUpdate: (json) => loadNutrientsJson(json)),
      if (fetchNutrientLoss != null)
        _refreshCategory(fetchFn: fetchNutrientLoss, versionKey: _kNutrientLoss, onUpdate: (json) => loadNutrientLossJson(json)),
      if (fetchCookingOils != null)
        _refreshCategory(fetchFn: fetchCookingOils, versionKey: _kCookingOils, onUpdate: (json) => loadCookingMethodOilsJson(json)),
      if (fetchSportMets != null)
        _refreshCategory(fetchFn: fetchSportMets, versionKey: _kSportMets, onUpdate: (json) => loadSportMetsJson(json)),
      if (fetchObjectiveNutrients != null)
        _refreshCategory(fetchFn: fetchObjectiveNutrients, versionKey: kObjectiveNutrients, onUpdate: (json) => _db.setReferenceBlob(kObjectiveNutrients, json)),
      if (fetchNutrientObjective != null)
        _refreshCategory(fetchFn: fetchNutrientObjective, versionKey: kNutrientObjective, onUpdate: (json) => _db.setReferenceBlob(kNutrientObjective, json)),
    ]);

    return results.any((updated) => updated);
  }

  /// Fetches one reference data category, checks version, and updates if newer.
  Future<bool> _refreshCategory({
    required Future<ReferencePayload?> Function() fetchFn,
    required String versionKey,
    required Future<void> Function(String json) onUpdate,
  }) async {
    final payload = await fetchFn();
    if (payload == null) return false;
    final localVersion = await _db.getReferenceVersion(versionKey);
    if (payload.version > localVersion) {
      await onUpdate(payload.json);
      await _db.setReferenceVersion(versionKey, payload.version);
      return true;
    }
    return false;
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

      // Parse exchangePortion — can be a number or a range string like "100-150"
      double exchangePortion = 0.0;
      final rawPortion = map['exchangePortionDaily'] ?? map['exchangePortion'];
      if (rawPortion != null) {
        final portionStr = rawPortion.toString();
        if (portionStr.contains('-')) {
          final parts = portionStr.split('-');
          final lo = double.tryParse(parts[0]) ?? 0.0;
          final hi = double.tryParse(parts[1]) ?? 0.0;
          exchangePortion = (lo + hi) / 2;
        } else {
          exchangePortion = double.tryParse(portionStr) ?? 0.0;
        }
      }

      return NutrientCompositionsCompanion(
        foodId: Value(int.tryParse(map['id'].toString()) ?? 0),
        isFood: Value(int.tryParse(map['isFood'].toString()) ?? 0),
        group: Value(map['group'] as String? ?? map['g'] as String? ?? ''),
        nameEn: Value(map['name_en'] as String? ?? map['en'] as String? ?? ''),
        nameEs: Value(map['name_es'] as String? ?? map['es'] as String? ?? ''),
        recommendable: Value(int.tryParse(map['recommendable'].toString()) ?? 0),
        freeSugar: Value(map['freeSugar']?.toString()),
        params: Value(jsonEncode(cleanParams)),
        recGroup: Value(int.tryParse(map['rec_group']?.toString() ?? '') ?? 0),
        exchangePortion: Value(exchangePortion),
        allergiesExclusions: Value(map['allergiesExclusions']?.toString() ?? ''),
        intolerances: Value(map['intolerances']?.toString() ?? ''),
        diseases: Value(map['diseases']?.toString() ?? ''),
        guts: Value(int.tryParse(map['guts']?.toString() ?? '') ?? 0),
        rarity: Value(int.tryParse(map['rarity']?.toString() ?? '') ?? 0),
        novaClassification: Value(int.tryParse(map['novaClassification']?.toString() ?? '') ?? 1),
        included: Value(int.tryParse(map['included']?.toString() ?? '') ?? 0),
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
      // S3 uses "nutrients_loss", code expected "nutrients"
      final nutrients = map['nutrients_loss'] as Map<String, dynamic>?
          ?? map['nutrients'] as Map<String, dynamic>?
          ?? {};
      final cleanLosses = nutrients.map((k, v) =>
          MapEntry(k, v is num ? v.toDouble() : 0.0));

      // S3 uses "id", code expected "cookingMethodId"
      return NutrientLossesCompanion(
        cookingMethodId: Value(map['id'] as int? ?? map['cookingMethodId'] as int? ?? 0),
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
        nameEn: Value(map['name_en'] as String? ?? map['en'] as String? ?? ''),
        nameEs: Value(map['name_es'] as String? ?? map['es'] as String? ?? ''),
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
