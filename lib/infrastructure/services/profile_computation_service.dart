import 'dart:convert';

import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/user_profile_response.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/reference_data_service.dart';

/// Ports the upload-profile-data-prod Lambda logic to Dart.
///
/// Computes: unit conversion, BMR/kcal, per-nutrient RDAs, and micronutrient
/// prioritization per objective — all from locally cached reference data.
class ProfileComputationService {
  final ReferenceDatabase _db;

  // Cached parsed reference data (loaded once from Drift blobs)
  Map<String, dynamic>? _objectiveNutrientsCache;
  Map<String, dynamic>? _nutrientObjectiveCache;

  ProfileComputationService(this._db);

  // ---------------------------------------------------------------------------
  // Public
  // ---------------------------------------------------------------------------

  /// Computes the full profile response locally, replicating the Lambda.
  ///
  /// Returns `null` if reference data is not yet available in Drift,
  /// signalling the caller to fall back to the remote Lambda call.
  Future<UserProfileResponse?> computeProfile(
    UploadUserProfile profile,
  ) async {
    if (!await _ensureDataLoaded()) return null;

    // 1. Unit conversion (imperial → metric)
    double height = profile.physicalCharacteristics?.height ?? 170.0;
    double weight = profile.physicalCharacteristics?.weight ?? 70.0;
    final unit = profile.physicalCharacteristics?.unit ?? 1;

    if (unit == 2) {
      height = height * 30.48;      // feet → cm
      weight = weight * 0.453592;   // lb → kg
    }

    // 2. Age from birthDate (epoch millis)
    final age = _computeAge(profile.birthDate);

    // 3. BMR / kcal
    final kcal = _computeKcal(
      height: height,
      weight: weight,
      sex: profile.sex,
      age: age,
      activityFactor: profile.occupationActivityFactor,
    );

    // 4. RDAs per nutrient
    final userRdas = _computeRdas(profile.sex, age);

    // 5. Micronutrient prioritization
    final microResult = _computeMicronutrients(profile.objectives);

    return UserProfileResponse(
      uploadSuccess: true,
      micronutrients: microResult.micronutrients,
      userAll: microResult.userAll,
      temporaryMicronutrients: microResult.temporaryMicronutrients,
      temporaryAll: microResult.temporaryAll,
      userRdas: userRdas,
      kcal: kcal,
    );
  }

  /// Returns the nutrient keys grouped by objective ID for the given objectives.
  /// Returns null if reference data is not loaded.
  Future<Map<int, List<String>>?> getObjectiveNutrientsMap(List<int> objectiveIds) async {
    if (!await _ensureDataLoaded()) return null;
    final map = <int, List<String>>{};
    for (final id in objectiveIds) {
      map[id] = _getObjectiveNutrients(id);
    }
    return map;
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  /// Loads reference data from Drift blobs into memory caches.
  /// Returns false if either blob is missing (endpoints not deployed yet).
  Future<bool> _ensureDataLoaded() async {
    if (_objectiveNutrientsCache != null && _nutrientObjectiveCache != null) {
      return true;
    }

    final objectiveNutrientsJson = await _db.getReferenceBlob(
      ReferenceDataService.kObjectiveNutrients,
    );
    final nutrientObjectiveJson = await _db.getReferenceBlob(
      ReferenceDataService.kNutrientObjective,
    );

    if (objectiveNutrientsJson == null || nutrientObjectiveJson == null) {
      return false;
    }

    _objectiveNutrientsCache =
        jsonDecode(objectiveNutrientsJson) as Map<String, dynamic>;
    _nutrientObjectiveCache =
        jsonDecode(nutrientObjectiveJson) as Map<String, dynamic>;
    return true;
  }

  // ---------------------------------------------------------------------------
  // Age
  // ---------------------------------------------------------------------------

  int _computeAge(int birthDateEpochMillis) {
    final birth = DateTime.fromMillisecondsSinceEpoch(birthDateEpochMillis);
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  String _getAgeBracket(int age) {
    if (age < 30) return '19-30';
    if (age < 50) return '30-50';
    if (age < 70) return '50-70';
    return '70+';
  }

  // ---------------------------------------------------------------------------
  // BMR / kcal
  // ---------------------------------------------------------------------------

  int _computeKcal({
    required double height,
    required double weight,
    required int sex,
    required int age,
    required double activityFactor,
  }) {
    final heightM = height / 100.0;
    final bmi = weight / (heightM * heightM);

    double bmr;
    if (bmi < 30) {
      // Harris-Benedict
      if (sex == 0) {
        bmr = 66.5 + 13.75 * weight + 5.003 * height - 6.75 * age;
      } else {
        bmr = 655.1 + 9.563 * weight + 1.850 * height - 4.676 * age;
      }
    } else {
      // Mifflin-St Jeor (obese)
      if (sex == 0) {
        bmr = 10 * weight + 6.25 * height - 5 * age + 5;
      } else {
        bmr = 10 * weight + 6.25 * height - 5 * age - 161;
      }
    }

    return (bmr * activityFactor).round();
  }

  // ---------------------------------------------------------------------------
  // RDA computation
  // ---------------------------------------------------------------------------

  List<UserRda> _computeRdas(int sex, int age) {
    final sexKey = sex == 0 ? 'male' : 'female';
    final ageBracket = _getAgeBracket(age);
    final List<UserRda> rdas = [];

    for (final entry in _nutrientObjectiveCache!.entries) {
      final nutrientName = entry.key;
      final sexData = entry.value as Map<String, dynamic>?;
      if (sexData == null) continue;

      final ageData = (sexData[sexKey] as Map<String, dynamic>?);
      if (ageData == null) continue;

      final bracketData = (ageData[ageBracket] as Map<String, dynamic>?);
      if (bracketData == null) continue;

      final rda = (bracketData['rda'] as num?)?.toDouble() ?? 0.0;
      final ul = (bracketData['ul'] as num?)?.toDouble() ?? 0.0;

      rdas.add(UserRda(
        n: nutrientName,
        rda: rda,
        ul: ul,
        upperLimit: ul,
      ),);
    }

    return rdas;
  }

  // ---------------------------------------------------------------------------
  // Micronutrient prioritization
  // ---------------------------------------------------------------------------

  _MicronutrientResult _computeMicronutrients(List<int> objectives) {
    // Separate normal (id < 100) from temporary (id >= 100) objectives
    final normalObjectives = objectives.where((id) => id < 100).toList();
    final temporaryObjectives = objectives.where((id) => id >= 100).toList();

    final normalResult = _prioritize(normalObjectives);
    final temporaryResult = _prioritize(temporaryObjectives);

    return _MicronutrientResult(
      micronutrients: normalResult.selected,
      userAll: normalResult.all,
      temporaryMicronutrients: temporaryResult.selected,
      temporaryAll: temporaryResult.all,
    );
  }

  _PrioritizationResult _prioritize(List<int> objectiveIds) {
    final Set<String> usedPool = {};
    final List<String> selected = [];
    final Set<String> allNutrients = {};

    // Collect all nutrients across all objectives for the borrowing pool
    final Map<int, List<String>> objectiveNutrientLists = {};
    for (final id in objectiveIds) {
      final nutrients = _getObjectiveNutrients(id);
      objectiveNutrientLists[id] = nutrients;
      allNutrients.addAll(nutrients);
    }

    // Pick top-3 unused per objective
    for (final id in objectiveIds) {
      final nutrients = objectiveNutrientLists[id] ?? [];
      final List<String> picked = [];

      // First pass: pick from this objective's list
      for (final nutrient in nutrients) {
        if (picked.length >= 3) break;
        if (!usedPool.contains(nutrient)) {
          picked.add(nutrient);
          usedPool.add(nutrient);
        }
      }

      // Borrow from general pool if fewer than 3
      if (picked.length < 3) {
        for (final nutrient in allNutrients) {
          if (picked.length >= 3) break;
          if (!usedPool.contains(nutrient)) {
            picked.add(nutrient);
            usedPool.add(nutrient);
          }
        }
      }

      selected.addAll(picked);
    }

    return _PrioritizationResult(
      selected: selected,
      all: allNutrients.toList(),
    );
  }

  List<String> _getObjectiveNutrients(int objectiveId) {
    final raw = _objectiveNutrientsCache![objectiveId.toString()];
    if (raw is List) {
      return raw.cast<String>();
    }
    return [];
  }
}

// ---------------------------------------------------------------------------
// Internal result types
// ---------------------------------------------------------------------------

class _MicronutrientResult {
  final List<String> micronutrients;
  final List<String> userAll;
  final List<String> temporaryMicronutrients;
  final List<String> temporaryAll;

  _MicronutrientResult({
    required this.micronutrients,
    required this.userAll,
    required this.temporaryMicronutrients,
    required this.temporaryAll,
  });
}

class _PrioritizationResult {
  final List<String> selected;
  final List<String> all;

  _PrioritizationResult({required this.selected, required this.all});
}
