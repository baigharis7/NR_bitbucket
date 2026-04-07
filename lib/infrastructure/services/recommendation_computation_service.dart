import 'dart:convert';

import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendation.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/reference_data_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/constants.dart';

/// Ports the food-recommendation-prod Lambda logic to Dart.
///
/// Computes food recommendations locally from:
/// - NutrientCompositions (Drift) — full nutrient database
/// - Reference blobs (Drift) — objective-nutrients, nutrient-objective (RDA)
/// - Recommendation groups (Hive master file)
/// - User profile — objectives, exclusions, intolerances, diseases, etc.
/// - Last 7 days of food events (Hive)
///
/// Returns `null` if reference data is not yet available, signalling the
/// caller to fall back to the remote Lambda call.
class RecommendationComputationService {
  final ReferenceDatabase _db;

  // Cached parsed reference data (loaded once from Drift blobs)
  Map<String, dynamic>? _objectiveNutrientsCache;
  Map<String, dynamic>? _nutrientObjectiveCache;

  RecommendationComputationService(this._db);

  // ---------------------------------------------------------------------------
  // Public
  // ---------------------------------------------------------------------------

  /// Computes food recommendations locally, replicating the Lambda.
  ///
  /// Returns `null` if reference data is not yet available in Drift.
  Future<Recommendation?> compute({
    required UserProfileModel profile,
    required List<FoodEventComplete> weekFoodEvents,
    required RecommendationGroupsMaster recommendationGroups,
  }) async {
    if (!await _ensureDataLoaded()) return null;

    // 1. Load all nutrient compositions from Drift
    final allFoods = await _db.getAllNutrientCompositions();
    if (allFoods.isEmpty) return null;

    final foodById = <int, NutrientComposition>{};
    for (final f in allFoods) {
      foodById[f.foodId] = f;
    }

    // 2. Collect consumed food IDs and count occurrences
    final consumedFoodIds = <int>{};
    final foodOccurrences = <int, int>{};

    for (final event in weekFoodEvents) {
      for (final food in event.foodInfo ?? <FoodInfo>[]) {
        if (food.id != null) {
          consumedFoodIds.add(food.id!);
          foodOccurrences[food.id!] = (foodOccurrences[food.id!] ?? 0) + 1;
        }
      }
    }

    // Repeated foods: eaten 3+ times in the last 7 days
    final repeatedFoodIds = foodOccurrences.entries
        .where((e) => e.value >= 3)
        .map((e) => e.key)
        .toSet();

    // 3. Sum nutrients from last 7 days, average per day
    final weeklyNutrientSums = _sumWeeklyNutrients(weekFoodEvents);
    final averageDailyNutrients = weeklyNutrientSums
        .map((k, v) => MapEntry(k, v / 7));

    // 4. Find nutrients in deficit (< 85% of RDA)
    final nutrientsInDeficit = _findNutrientsInDeficit(
      averageDailyNutrients,
      profile.sex?.index ?? 0,
      profile.birthDate ?? 0,
    );

    // 5. Get user target nutrients from objectives
    final userNutrients = _getUserNutrients(profile.objectives ?? []);

    // 6. Convert profile conditions to binary strings for comparison
    final userExclusionsBinary = _indicesToBinary(
      profile.exclusions?.exclusions ?? [],
      Constants.EXCLUSIONS_SIZE,
    );
    final userIntolerancesBinary = _indicesToBinary(
      profile.intolerances ?? [],
      Constants.INTOLERANCES_SIZE,
    );
    final userDiseasesBinary = _indicesToBinary(
      profile.medicalSituation?.commonDiseases ?? [],
      Constants.DISEASES_SIZE,
    );
    final userSymptomsBinary = profile.symptoms ?? '';
    final userAversions = profile.foodAversions ?? [];
    final userEatsGuts = (profile.guts ?? 0) == 1;

    // 7. Filter recommendable foods and score them
    final recommendableFoods = allFoods
        .where((f) => f.rarity == 0)
        .toList();
    final allIncludedFoods = allFoods
        .where((f) => f.included == 0)
        .toList();

    // 8. Recommend foods: filter by conditions, rank by nutrients
    final recommended = _recommendFood(
      recommendableFoods: recommendableFoods,
      consumedFoodIds: consumedFoodIds,
      userExclusionsBinary: userExclusionsBinary,
      userIntolerancesBinary: userIntolerancesBinary,
      userDiseasesBinary: userDiseasesBinary,
      userSymptomsBinary: userSymptomsBinary,
      userEatsGuts: userEatsGuts,
      recommendationGroups: recommendationGroups,
      userNutrients: userNutrients,
      nutrientsInDeficit: nutrientsInDeficit,
    );

    // 9. Build final result per recommendation group
    final foodList = _filterFoodList(
      recommended: recommended,
      allIncludedFoods: allIncludedFoods,
      foodById: foodById,
      recommendationGroups: recommendationGroups,
      userNutrients: userNutrients,
      nutrientsInDeficit: nutrientsInDeficit,
      repeatedFoodIds: repeatedFoodIds,
      weekFoodEvents: weekFoodEvents,
      userAversions: userAversions,
    );

    return Recommendation(
      foodList: foodList,
      userNutrients: userNutrients,
      nutrientsInDeficit: nutrientsInDeficit,
    );
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

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
  // Step 3: Sum weekly nutrients
  // ---------------------------------------------------------------------------

  /// Sums all nutrient params across all food events in the week.
  Map<String, double> _sumWeeklyNutrients(List<FoodEventComplete> events) {
    final sums = <String, double>{};

    for (final event in events) {
      for (final food in event.foodInfo ?? <FoodInfo>[]) {
        if (food.params == null) continue;
        final paramsMap = food.params!.toJson();
        for (final entry in paramsMap.entries) {
          if (entry.value is num) {
            sums[entry.key] = (sums[entry.key] ?? 0.0) + (entry.value as num).toDouble();
          }
        }
      }
    }

    return sums;
  }

  // ---------------------------------------------------------------------------
  // Step 4: Find nutrients in deficit
  // ---------------------------------------------------------------------------

  List<String> _findNutrientsInDeficit(
    Map<String, double> averageDailyNutrients,
    int sex,
    int birthDateEpochMillis,
  ) {
    final age = _computeAge(birthDateEpochMillis);
    final deficit = <String>[];

    // Iterate nutrient-objective reference data (RDA by age/sex)
    for (final entry in _nutrientObjectiveCache!.entries) {
      final nutrientName = entry.key;
      final sexData = entry.value as Map<String, dynamic>?;
      if (sexData == null) continue;

      final sexKey = sex == 0 ? 'male' : 'female';
      final ageData = sexData[sexKey] as Map<String, dynamic>?;
      if (ageData == null) continue;

      final ageBracket = _getAgeBracket(age);
      final bracketData = ageData[ageBracket] as Map<String, dynamic>?;
      if (bracketData == null) continue;

      final rda = (bracketData['rda'] as num?)?.toDouble();
      if (rda == null || rda == 0) continue;

      final intake = averageDailyNutrients[nutrientName] ?? 0.0;
      final threshold = rda * 0.85; // 85% of RDA
      if (intake < threshold) {
        deficit.add(nutrientName);
      }
    }

    return deficit;
  }

  // ---------------------------------------------------------------------------
  // Step 5: Get user target nutrients from objectives
  // ---------------------------------------------------------------------------

  // Nutrients excluded from prioritization, matching the Lambda.
  static const _excludedNutrients = {'choline', 'vitF'};

  List<String> _getUserNutrients(List<int> objectives) {
    final nutrients = <String>[];
    for (final entry in (_objectiveNutrientsCache ?? {}).entries) {
      final objectiveCode = int.tryParse(entry.key);
      if (objectiveCode != null && objectives.contains(objectiveCode)) {
        final nutrientList = _extractNutrients(entry.value);
        for (final nutrient in nutrientList) {
          final n = nutrient.toString();
          if (!_excludedNutrients.contains(n) && !nutrients.contains(n)) {
            nutrients.add(n);
          }
        }
      }
    }
    return nutrients..sort();
  }

  /// Extracts nutrient list from either new format ({nutrients, type}) or old format (plain list).
  List _extractNutrients(dynamic value) {
    if (value is List) return value;
    if (value is Map) {
      final nutrients = value['nutrients'];
      if (nutrients is List) return nutrients;
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Step 8: Recommend food (filter + score)
  // ---------------------------------------------------------------------------

  _RecommendedFoods _recommendFood({
    required List<NutrientComposition> recommendableFoods,
    required Set<int> consumedFoodIds,
    required String userExclusionsBinary,
    required String userIntolerancesBinary,
    required String userDiseasesBinary,
    required String userSymptomsBinary,
    required bool userEatsGuts,
    required RecommendationGroupsMaster recommendationGroups,
    required List<String> userNutrients,
    required List<String> nutrientsInDeficit,
  }) {
    final userObjNutrientsInFoods = <_ScoredFood>[];
    final userDeficitNutrientsInFoods = <_ScoredFood>[];

    for (final food in recommendableFoods) {
      // Skip already-eaten foods
      if (consumedFoodIds.contains(food.foodId)) continue;

      // Check exclusions / intolerances / diseases / symptoms
      if (!_isFoodAllowed(
        foodExclusions: food.allergiesExclusions,
        foodIntolerances: food.intolerances,
        foodDiseases: food.diseases,
        userExclusionsBinary: userExclusionsBinary,
        userIntolerancesBinary: userIntolerancesBinary,
        userDiseasesBinary: userDiseasesBinary,
        userSymptomsBinary: userSymptomsBinary,
      )) continue;

      // Check guts preference
      if (food.guts == 1 && !userEatsGuts) continue;

      // Parse nutrient params
      final params = _parseParams(food.params);
      final exchangePortion = food.exchangePortion;

      // Assign recommendation group
      final recGroup = food.recGroup;

      // Build scored food for objective nutrients
      if (userNutrients.isNotEmpty) {
        final scored = <String, double>{};
        for (final nutrient in userNutrients) {
          final value = params[nutrient] ?? 0.0;
          scored[nutrient] = exchangePortion > 0
              ? (value * exchangePortion) / 100
              : value;
        }
        userObjNutrientsInFoods.add(_ScoredFood(
          id: food.foodId,
          group: food.group,
          recGroup: recGroup,
          nutrientValues: scored,
        ));
      }

      // Build scored food for deficit nutrients
      if (nutrientsInDeficit.isNotEmpty) {
        final scored = <String, double>{};
        for (final nutrient in nutrientsInDeficit) {
          final value = params[nutrient] ?? 0.0;
          scored[nutrient] = exchangePortion > 0
              ? (value * exchangePortion) / 100
              : value;
        }
        userDeficitNutrientsInFoods.add(_ScoredFood(
          id: food.foodId,
          group: food.group,
          recGroup: recGroup,
          nutrientValues: scored,
        ));
      }
    }

    return _RecommendedFoods(
      userObjNutrientsInFoods: userObjNutrientsInFoods,
      userDeficitNutrientsInFoods: userDeficitNutrientsInFoods,
    );
  }

  // ---------------------------------------------------------------------------
  // Step 9: Filter and rank per recommendation group
  // ---------------------------------------------------------------------------

  List<GroupRecommendation> _filterFoodList({
    required _RecommendedFoods recommended,
    required List<NutrientComposition> allIncludedFoods,
    required Map<int, NutrientComposition> foodById,
    required RecommendationGroupsMaster recommendationGroups,
    required List<String> userNutrients,
    required List<String> nutrientsInDeficit,
    required Set<int> repeatedFoodIds,
    required List<FoodEventComplete> weekFoodEvents,
    required List<int> userAversions,
  }) {
    final result = <GroupRecommendation>[];

    for (final recGroup in recommendationGroups.recommendationGroups) {
      if (recGroup.size == 0) continue;

      // Filter foods for this recommendation group
      final objFoods = recommended.userObjNutrientsInFoods
          .where((f) => f.recGroup == recGroup.id)
          .toList();
      final deficitFoods = recommended.userDeficitNutrientsInFoods
          .where((f) => f.recGroup == recGroup.id)
          .toList();

      // Rank objective foods by composite nutrient score
      final rankedObjIds = _rankByNutrientScore(objFoods, userNutrients);
      final rankedDeficitIds = _rankByNutrientScore(deficitFoods, nutrientsInDeficit);

      // Filter out aversions
      final filteredObjIds = rankedObjIds
          .where((id) => !userAversions.contains(id))
          .toList();
      final filteredDeficitIds = rankedDeficitIds
          .where((id) => !userAversions.contains(id))
          .toList();

      // Usual foods: repeated foods in this rec group
      final usualFoods = _buildUsualFoods(
        recGroupId: recGroup.id,
        repeatedFoodIds: repeatedFoodIds,
        weekFoodEvents: weekFoodEvents,
        allIncludedFoods: allIncludedFoods,
        foodById: foodById,
        userAversions: userAversions,
      );

      result.add(GroupRecommendation(
        recGroup.id,
        filteredObjIds,
        filteredDeficitIds,
        usualFoods,
      ));
    }

    return result;
  }

  /// Ranks foods by composite nutrient score (sum of per-nutrient positions).
  List<int> _rankByNutrientScore(
    List<_ScoredFood> foods,
    List<String> nutrients,
  ) {
    if (foods.isEmpty || nutrients.isEmpty) {
      return foods.map((f) => f.id).toList();
    }

    // For each nutrient, sort foods descending by that nutrient value,
    // then record each food's position index. Sum positions across nutrients.
    final positionSums = <int, int>{};
    for (final f in foods) {
      positionSums[f.id] = 0;
    }

    for (final nutrient in nutrients) {
      final sorted = List<_ScoredFood>.from(foods)
        ..sort((a, b) => (b.nutrientValues[nutrient] ?? 0)
            .compareTo(a.nutrientValues[nutrient] ?? 0));
      for (int i = 0; i < sorted.length; i++) {
        positionSums[sorted[i].id] = (positionSums[sorted[i].id] ?? 0) + i;
      }
    }

    // Sort by sum of positions (lower = better)
    final ranked = foods.toList()
      ..sort((a, b) => (positionSums[a.id] ?? 0).compareTo(positionSums[b.id] ?? 0));
    return ranked.map((f) => f.id).toList();
  }

  // ---------------------------------------------------------------------------
  // Usual foods + NOVA scoring
  // ---------------------------------------------------------------------------

  UsualFoods _buildUsualFoods({
    required int recGroupId,
    required Set<int> repeatedFoodIds,
    required List<FoodEventComplete> weekFoodEvents,
    required List<NutrientComposition> allIncludedFoods,
    required Map<int, NutrientComposition> foodById,
    required List<int> userAversions,
  }) {
    // Find repeated foods that belong to this rec group
    final usualFoodCompositions = <NutrientComposition>[];
    for (final foodId in repeatedFoodIds) {
      final comp = foodById[foodId];
      if (comp != null && comp.recGroup == recGroupId) {
        usualFoodCompositions.add(comp);
      }
    }

    final usualHealthy = <UsualFoodItem>[];
    final usualUnhealthy = <UsualFoodItem>[];

    for (final usualFood in usualFoodCompositions) {
      if (userAversions.contains(usualFood.foodId)) continue;

      final novaScore = _calculateNovaScore(usualFood);

      // Find alternatives from the same food group
      final sameGroupFoods = allIncludedFoods
          .where((f) => f.group == usualFood.group)
          .toList();

      final altHealthy = <int>[];
      final altUnhealthy = <int>[];
      for (final alt in sameGroupFoods) {
        if (userAversions.contains(alt.foodId)) continue;
        final altNova = _calculateNovaScore(alt);
        if (altNova >= 5) {
          altHealthy.add(alt.foodId);
        } else {
          altUnhealthy.add(alt.foodId);
        }
      }

      final item = UsualFoodItem(
        usualFood.foodId,
        altHealthy,
        altUnhealthy,
      );

      if (novaScore >= 5) {
        usualHealthy.add(item);
      } else {
        usualUnhealthy.add(item);
      }
    }

    return UsualFoods(usualHealthy, usualUnhealthy);
  }

  // ---------------------------------------------------------------------------
  // NOVA score calculation (Lambda lines 829-1009)
  // ---------------------------------------------------------------------------

  double _calculateNovaScore(NutrientComposition food) {
    final novaGroup = food.novaClassification;
    final isFood = food.isFood == 0; // 0 = food, 1 = drink
    final params = _parseParams(food.params);

    final sumSat = params['sumSat'] ?? 0.0;
    final energyKcal = params['energyKcal'] ?? 0.0;
    final sugar = params['sugar'] ?? params['sugarsTotal'] ?? 0.0;
    final sodium = params['sodium'] ?? 0.0;

    double novaScore = 0;

    if (isFood) {
      switch (novaGroup) {
        case 1:
          novaScore = 10;
          break;
        case 2:
          break; // Not scored
        case 3:
          novaScore = 8;
          if (sumSat > 1.5 && sumSat <= 4) novaScore -= 0.5;
          else if (sumSat > 4) novaScore -= 1;
          if (energyKcal > 275) novaScore -= 1;
          if (sugar > 5 && sugar <= 10) novaScore -= 0.5;
          else if (sugar > 10) novaScore -= 1;
          if (sodium > 0.12 && sodium <= 0.4) novaScore -= 0.5;
          else if (sodium > 0.4) novaScore -= 1;
          break;
        case 4:
          novaScore = 4;
          if (sumSat > 1.5 && sumSat <= 4) novaScore += 0.5;
          else if (sumSat > 4) novaScore -= 1;
          if (energyKcal > 275) novaScore -= 1;
          if (sugar > 5 && sugar <= 10) novaScore += 0.5;
          else if (sugar > 10) novaScore -= 1;
          if (sodium > 0.12 && sodium <= 0.4) novaScore += 0.5;
          else if (sodium > 0.4) novaScore -= 1;
          break;
      }
    } else {
      // Drink
      switch (novaGroup) {
        case 1:
          novaScore = 10;
          break;
        case 2:
          break; // Not scored
        case 3:
          novaScore = 8;
          if (sumSat > 0.75 && sumSat <= 3) novaScore -= 0.5;
          else if (sumSat > 3) novaScore -= 1;
          if (energyKcal > 70) novaScore -= 1;
          if (sugar > 2.5 && sugar <= 5) novaScore -= 0.5;
          else if (sugar > 5) novaScore -= 1;
          if (sodium > 0.08 && sodium <= 0.1) novaScore -= 0.5;
          else if (sodium > 0.1) novaScore -= 1;
          break;
        case 4:
          novaScore = 4;
          if (sumSat > 0.75 && sumSat <= 3) novaScore += 0.5;
          else if (sumSat > 3) novaScore -= 1;
          if (energyKcal > 70) novaScore -= 1;
          if (sugar > 2.5 && sugar <= 5) novaScore += 0.5;
          else if (sugar > 5) novaScore -= 1;
          if (sodium > 0.08 && sodium <= 0.1) novaScore += 0.5;
          else if (sodium > 0.1) novaScore -= 1;
          break;
      }
    }

    return novaScore;
  }

  // ---------------------------------------------------------------------------
  // Binary condition checking (matches Lambda's isFoodAllowed)
  // ---------------------------------------------------------------------------

  bool _isFoodAllowed({
    required String foodExclusions,
    required String foodIntolerances,
    required String foodDiseases,
    required String userExclusionsBinary,
    required String userIntolerancesBinary,
    required String userDiseasesBinary,
    required String userSymptomsBinary,
  }) {
    return _checkCondition(userExclusionsBinary, foodExclusions, Constants.EXCLUSIONS_SIZE) &&
        _checkCondition(userIntolerancesBinary, foodIntolerances, Constants.INTOLERANCES_SIZE) &&
        _checkCondition(userSymptomsBinary, '', Constants.SYMPTOMS_SIZE) && // Symptoms not stored per food in S3
        _checkCondition(userDiseasesBinary, foodDiseases, Constants.DISEASES_SIZE);
  }

  /// Checks if user's binary and food's binary have no overlap (AND == 0).
  bool _checkCondition(String userBinary, String foodValue, int binarySize) {
    if (foodValue.isEmpty) return true;

    // Convert food value (comma-separated indices or single number) to binary
    final foodBinary = _valueToBinary(foodValue, binarySize);

    // Parse both as integers and AND them
    final userInt = int.tryParse(userBinary, radix: 2) ?? 0;
    final foodInt = int.tryParse(foodBinary, radix: 2) ?? 0;

    return (userInt & foodInt) == 0;
  }

  /// Converts a comma-separated index string (e.g., "0,2,5") or single number
  /// to a binary string of given size. Matches Lambda's convertToBinary.
  String _valueToBinary(String value, int binarySize) {
    final indices = <int>[];
    if (value.contains(',')) {
      for (final part in value.split(',')) {
        final idx = int.tryParse(part.trim());
        if (idx != null) indices.add(idx);
      }
    } else {
      final idx = int.tryParse(value.trim());
      if (idx != null) indices.add(idx);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < binarySize; i++) {
      buffer.write(indices.contains(i) ? '1' : '0');
    }
    return buffer.toString();
  }

  /// Converts a List<int> of indices to a binary string.
  String _indicesToBinary(List<int> indices, int binarySize) {
    final buffer = StringBuffer();
    for (int i = 0; i < binarySize; i++) {
      buffer.write(indices.contains(i) ? '1' : '0');
    }
    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, double> _parseParams(String paramsJson) {
    try {
      final raw = jsonDecode(paramsJson) as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, v is num ? v.toDouble() : 0.0));
    } catch (_) {
      return {};
    }
  }

  int _computeAge(int birthDateEpochMillis) {
    if (birthDateEpochMillis == 0) return 30; // Safe default
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
}

// ---------------------------------------------------------------------------
// Internal types
// ---------------------------------------------------------------------------

class _ScoredFood {
  final int id;
  final String group;
  final int recGroup;
  final Map<String, double> nutrientValues;

  _ScoredFood({
    required this.id,
    required this.group,
    required this.recGroup,
    required this.nutrientValues,
  });
}

class _RecommendedFoods {
  final List<_ScoredFood> userObjNutrientsInFoods;
  final List<_ScoredFood> userDeficitNutrientsInFoods;

  _RecommendedFoods({
    required this.userObjNutrientsInFoods,
    required this.userDeficitNutrientsInFoods,
  });
}
