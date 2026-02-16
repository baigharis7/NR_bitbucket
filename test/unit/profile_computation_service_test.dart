import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/api/profile/model/upload_user_profile.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/reference_data_service.dart';

void main() {
  late ReferenceDatabase db;
  late ProfileComputationService service;

  // Sample reference data
  final objectiveNutrients = {
    '1': ['calcium', 'vitD', 'magnesium', 'phosphorus'],
    '2': ['iron', 'vitB12', 'vitB9', 'zinc'],
    '3': ['vitC', 'vitE', 'selenium'],
    '100': ['iron', 'vitB9', 'vitB6', 'vitB12'],
    '101': ['vitC', 'zinc', 'vitD'],
  };

  final nutrientObjective = {
    'calcium': {
      'male': {
        '19-30': {'rda': 1000, 'ul': 2500},
        '30-50': {'rda': 1000, 'ul': 2500},
        '50-70': {'rda': 1000, 'ul': 2000},
        '70+': {'rda': 1200, 'ul': 2000},
      },
      'female': {
        '19-30': {'rda': 1000, 'ul': 2500},
        '30-50': {'rda': 1000, 'ul': 2500},
        '50-70': {'rda': 1200, 'ul': 2000},
        '70+': {'rda': 1200, 'ul': 2000},
      },
    },
    'vitD': {
      'male': {
        '19-30': {'rda': 15, 'ul': 100},
        '30-50': {'rda': 15, 'ul': 100},
        '50-70': {'rda': 15, 'ul': 100},
        '70+': {'rda': 20, 'ul': 100},
      },
      'female': {
        '19-30': {'rda': 15, 'ul': 100},
        '30-50': {'rda': 15, 'ul': 100},
        '50-70': {'rda': 15, 'ul': 100},
        '70+': {'rda': 20, 'ul': 100},
      },
    },
    'iron': {
      'male': {
        '19-30': {'rda': 8, 'ul': 45},
        '30-50': {'rda': 8, 'ul': 45},
        '50-70': {'rda': 8, 'ul': 45},
        '70+': {'rda': 8, 'ul': 45},
      },
      'female': {
        '19-30': {'rda': 18, 'ul': 45},
        '30-50': {'rda': 18, 'ul': 45},
        '50-70': {'rda': 8, 'ul': 45},
        '70+': {'rda': 8, 'ul': 45},
      },
    },
    'vitC': {
      'male': {
        '19-30': {'rda': 90, 'ul': 2000},
        '30-50': {'rda': 90, 'ul': 2000},
        '50-70': {'rda': 90, 'ul': 2000},
        '70+': {'rda': 90, 'ul': 2000},
      },
      'female': {
        '19-30': {'rda': 75, 'ul': 2000},
        '30-50': {'rda': 75, 'ul': 2000},
        '50-70': {'rda': 75, 'ul': 2000},
        '70+': {'rda': 75, 'ul': 2000},
      },
    },
    'magnesium': {
      'male': {
        '19-30': {'rda': 400, 'ul': 350},
        '30-50': {'rda': 420, 'ul': 350},
        '50-70': {'rda': 420, 'ul': 350},
        '70+': {'rda': 420, 'ul': 350},
      },
      'female': {
        '19-30': {'rda': 310, 'ul': 350},
        '30-50': {'rda': 320, 'ul': 350},
        '50-70': {'rda': 320, 'ul': 350},
        '70+': {'rda': 320, 'ul': 350},
      },
    },
  };

  Future<void> _insertReferenceData() async {
    await db.setReferenceBlob(
      ReferenceDataService.kObjectiveNutrients,
      jsonEncode(objectiveNutrients),
    );
    await db.setReferenceBlob(
      ReferenceDataService.kNutrientObjective,
      jsonEncode(nutrientObjective),
    );
  }

  UploadUserProfile _buildProfile({
    double height = 175.0,
    double weight = 70.0,
    int unit = 0,
    int sex = 0,
    int birthDate = 694224000000, // ~1992-01-01 → age ~34
    double activityFactor = 1.5,
    List<int> objectives = const [1],
  }) {
    return UploadUserProfile(
      userId: 'test-user',
      commonName: 'Test',
      birthDate: birthDate,
      sex: sex,
      occupationActivityFactor: activityFactor,
      physicalCharacteristics: PhysicalCharacteristics(
        height: height,
        weight: weight,
        unit: unit,
      ),
      objectives: objectives,
    );
  }

  setUp(() {
    db = ReferenceDatabase(NativeDatabase.memory());
    service = ProfileComputationService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ProfileComputationService', () {
    group('returns null when reference data missing', () {
      test('returns null when no blobs loaded', () async {
        final profile = _buildProfile();
        final result = await service.computeProfile(profile);
        expect(result, isNull);
      });

      test('returns null when only one blob loaded', () async {
        await db.setReferenceBlob(
          ReferenceDataService.kObjectiveNutrients,
          jsonEncode(objectiveNutrients),
        );
        final profile = _buildProfile();
        final result = await service.computeProfile(profile);
        expect(result, isNull);
      });
    });

    group('unit conversion', () {
      test('metric units pass through unchanged', () async {
        await _insertReferenceData();
        // 175cm, 70kg, unit=0 (metric), male, age ~34
        // BMI = 70 / (1.75^2) = 22.86 → Harris-Benedict
        // BMR = 66.5 + 13.75*70 + 5.003*175 - 6.75*34 = 66.5 + 962.5 + 875.525 - 229.5 = 1675.025
        // kcal = 1675.025 * 1.5 = 2512.5 → 2513
        final profile = _buildProfile(height: 175.0, weight: 70.0, unit: 0);
        final result = await service.computeProfile(profile);
        expect(result, isNotNull);
        expect(result!.kcal, 2513);
      });

      test('imperial units are converted correctly', () async {
        await _insertReferenceData();
        // 5.74 feet → 5.74 * 30.48 = 174.9552 cm
        // 154.32 lb → 154.32 * 0.453592 = 69.99 kg
        // Should produce very similar kcal to 175cm / 70kg metric
        final profile = _buildProfile(
          height: 5.74,
          weight: 154.32,
          unit: 1,
        );
        final result = await service.computeProfile(profile);
        expect(result, isNotNull);
        // Should be close to 2513 (metric equivalent)
        expect(result!.kcal, closeTo(2513, 5));
      });
    });

    group('kcal computation', () {
      test('Harris-Benedict male (BMI < 30)', () async {
        await _insertReferenceData();
        // 180cm, 75kg, male, age 25, af=1.3
        // BMI = 75 / 3.24 = 23.15 → Harris-Benedict
        // BMR = 66.5 + 13.75*75 + 5.003*180 - 6.75*25
        //     = 66.5 + 1031.25 + 900.54 - 168.75 = 1829.54
        // kcal = 1829.54 * 1.3 = 2378.4 → 2378
        final profile = _buildProfile(
          height: 180.0,
          weight: 75.0,
          sex: 0,
          birthDate: DateTime(2001, 1, 1).millisecondsSinceEpoch,
          activityFactor: 1.3,
        );
        final result = await service.computeProfile(profile);
        expect(result!.kcal, 2378);
      });

      test('Harris-Benedict female (BMI < 30)', () async {
        await _insertReferenceData();
        // 165cm, 55kg, female, age 25, af=1.3
        // BMI = 55 / (1.65^2) = 20.2 → Harris-Benedict
        // BMR = 655.1 + 9.563*55 + 1.850*165 - 4.676*25
        //     = 655.1 + 525.965 + 305.25 - 116.9 = 1369.415
        // kcal = 1369.415 * 1.3 = 1780.24 → 1780
        final profile = _buildProfile(
          height: 165.0,
          weight: 55.0,
          sex: 1,
          birthDate: DateTime(2001, 1, 1).millisecondsSinceEpoch,
          activityFactor: 1.3,
        );
        final result = await service.computeProfile(profile);
        expect(result!.kcal, 1780);
      });

      test('Mifflin-St Jeor male (BMI >= 30)', () async {
        await _insertReferenceData();
        // 170cm, 100kg, male, age 40, af=1.2
        // BMI = 100 / (1.7^2) = 34.6 → Mifflin-St Jeor
        // BMR = 10*100 + 6.25*170 - 5*40 + 5
        //     = 1000 + 1062.5 - 200 + 5 = 1867.5
        // kcal = 1867.5 * 1.2 = 2241.0 → 2241
        final profile = _buildProfile(
          height: 170.0,
          weight: 100.0,
          sex: 0,
          birthDate: DateTime(1986, 1, 1).millisecondsSinceEpoch,
          activityFactor: 1.2,
        );
        final result = await service.computeProfile(profile);
        expect(result!.kcal, 2241);
      });

      test('Mifflin-St Jeor female (BMI >= 30)', () async {
        await _insertReferenceData();
        // 160cm, 80kg, female, age 40, af=1.2
        // BMI = 80 / (1.6^2) = 31.25 → Mifflin-St Jeor
        // BMR = 10*80 + 6.25*160 - 5*40 - 161
        //     = 800 + 1000 - 200 - 161 = 1439
        // kcal = 1439 * 1.2 = 1726.8 → 1727
        final profile = _buildProfile(
          height: 160.0,
          weight: 80.0,
          sex: 1,
          birthDate: DateTime(1986, 1, 1).millisecondsSinceEpoch,
          activityFactor: 1.2,
        );
        final result = await service.computeProfile(profile);
        expect(result!.kcal, 1727);
      });
    });

    group('RDA computation', () {
      test('returns RDAs for male in 30-50 bracket', () async {
        await _insertReferenceData();
        // age ~34 → bracket "30-50", sex=0 → "male"
        final profile = _buildProfile(sex: 0);
        final result = await service.computeProfile(profile);
        expect(result, isNotNull);

        final calciumRda = result!.userRdas.firstWhere((r) => r.n == 'calcium');
        expect(calciumRda.rda, 1000);
        expect(calciumRda.ul, 2500);

        final ironRda = result.userRdas.firstWhere((r) => r.n == 'iron');
        expect(ironRda.rda, 8);
        expect(ironRda.ul, 45);
      });

      test('returns RDAs for female in 19-30 bracket', () async {
        await _insertReferenceData();
        // age 25 → bracket "19-30", sex=1 → "female"
        final profile = _buildProfile(
          sex: 1,
          birthDate: DateTime(2001, 1, 1).millisecondsSinceEpoch,
        );
        final result = await service.computeProfile(profile);
        expect(result, isNotNull);

        final ironRda = result!.userRdas.firstWhere((r) => r.n == 'iron');
        expect(ironRda.rda, 18); // female 19-30 iron RDA
        expect(ironRda.ul, 45);

        final vitCRda = result.userRdas.firstWhere((r) => r.n == 'vitC');
        expect(vitCRda.rda, 75); // female vitC
      });

      test('returns RDAs for 70+ bracket', () async {
        await _insertReferenceData();
        // age 75 → bracket "70+", sex=0 → "male"
        final profile = _buildProfile(
          sex: 0,
          birthDate: DateTime(1951, 1, 1).millisecondsSinceEpoch,
        );
        final result = await service.computeProfile(profile);
        expect(result, isNotNull);

        final calciumRda = result!.userRdas.firstWhere((r) => r.n == 'calcium');
        expect(calciumRda.rda, 1200); // male 70+ calcium
        expect(calciumRda.ul, 2000);
      });

      test('produces one RDA entry per nutrient in reference data', () async {
        await _insertReferenceData();
        final profile = _buildProfile();
        final result = await service.computeProfile(profile);
        expect(result!.userRdas.length, nutrientObjective.length);
      });
    });

    group('micronutrient prioritization', () {
      test('single objective picks top 3', () async {
        await _insertReferenceData();
        // Objective 1: ['calcium', 'vitD', 'magnesium', 'phosphorus']
        final profile = _buildProfile(objectives: [1]);
        final result = await service.computeProfile(profile);
        expect(result!.micronutrients, ['calcium', 'vitD', 'magnesium']);
        expect(result.userAll, containsAll(['calcium', 'vitD', 'magnesium', 'phosphorus']));
      });

      test('multiple objectives avoid duplicate selections', () async {
        await _insertReferenceData();
        // Obj 1: ['calcium', 'vitD', 'magnesium', 'phosphorus'] → picks calcium, vitD, magnesium
        // Obj 2: ['iron', 'vitB12', 'vitB9', 'zinc'] → picks iron, vitB12, vitB9
        final profile = _buildProfile(objectives: [1, 2]);
        final result = await service.computeProfile(profile);
        expect(result!.micronutrients.length, 6);
        expect(result.micronutrients.sublist(0, 3), ['calcium', 'vitD', 'magnesium']);
        expect(result.micronutrients.sublist(3, 6), ['iron', 'vitB12', 'vitB9']);
      });

      test('borrows from pool when fewer than 3 unique nutrients', () async {
        await _insertReferenceData();
        // Obj 3: ['vitC', 'vitE', 'selenium'] → only vitC in RDA data
        // vitE and selenium are not in nutrientObjective, but objective_nutrients has them
        // So picks vitC, vitE, selenium (all 3 are in the objective's list)
        final profile = _buildProfile(objectives: [3]);
        final result = await service.computeProfile(profile);
        expect(result!.micronutrients, ['vitC', 'vitE', 'selenium']);
      });

      test('temporary objectives (id >= 100) go to temporaryMicronutrients', () async {
        await _insertReferenceData();
        // Obj 100: ['iron', 'vitB9', 'vitB6', 'vitB12'] → picks iron, vitB9, vitB6
        final profile = _buildProfile(objectives: [100]);
        final result = await service.computeProfile(profile);
        expect(result!.micronutrients, isEmpty);
        expect(result.userAll, isEmpty);
        expect(result.temporaryMicronutrients, ['iron', 'vitB9', 'vitB6']);
        expect(result.temporaryAll, containsAll(['iron', 'vitB9', 'vitB6', 'vitB12']));
      });

      test('normal and temporary objectives computed independently', () async {
        await _insertReferenceData();
        // Obj 2 (normal): ['iron', 'vitB12', 'vitB9', 'zinc'] → picks iron, vitB12, vitB9
        // Obj 100 (temp): ['iron', 'vitB9', 'vitB6', 'vitB12'] → picks iron, vitB9, vitB6
        // Note: iron appears in both — independent pools means no conflict
        final profile = _buildProfile(objectives: [2, 100]);
        final result = await service.computeProfile(profile);
        expect(result!.micronutrients, ['iron', 'vitB12', 'vitB9']);
        expect(result.temporaryMicronutrients, ['iron', 'vitB9', 'vitB6']);
      });

      test('empty objectives returns empty lists', () async {
        await _insertReferenceData();
        final profile = _buildProfile(objectives: []);
        final result = await service.computeProfile(profile);
        expect(result!.micronutrients, isEmpty);
        expect(result.userAll, isEmpty);
        expect(result.temporaryMicronutrients, isEmpty);
        expect(result.temporaryAll, isEmpty);
      });

      test('unknown objective id returns empty for that objective', () async {
        await _insertReferenceData();
        final profile = _buildProfile(objectives: [999]);
        final result = await service.computeProfile(profile);
        expect(result!.micronutrients, isEmpty);
        expect(result.userAll, isEmpty);
      });
    });

    group('full integration', () {
      test('returns uploadSuccess true', () async {
        await _insertReferenceData();
        final profile = _buildProfile();
        final result = await service.computeProfile(profile);
        expect(result!.uploadSuccess, isTrue);
      });

      test('all output fields are populated', () async {
        await _insertReferenceData();
        final profile = _buildProfile(objectives: [1, 100]);
        final result = await service.computeProfile(profile);
        expect(result, isNotNull);
        expect(result!.kcal, isNonZero);
        expect(result.userRdas, isNotEmpty);
        expect(result.micronutrients, isNotEmpty);
        expect(result.userAll, isNotEmpty);
        expect(result.temporaryMicronutrients, isNotEmpty);
        expect(result.temporaryAll, isNotEmpty);
      });
    });
  });
}
