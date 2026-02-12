import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/reference_data_service.dart';

void main() {
  late ReferenceDatabase db;
  late ReferenceDataService service;

  setUp(() {
    db = ReferenceDatabase(NativeDatabase.memory());
    service = ReferenceDataService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('ReferenceDataService - loadNutrientsJson', () {
    test('parses and stores nutrient compositions', () async {
      final json = jsonEncode([
        {
          'id': 37,
          'isFood': 0,
          'g': '3.4',
          'en': 'Green pepper',
          'es': 'Pimiento verde',
          'recommendable': 1,
          'freeSugar': '0',
          'params': {'energyKcal': 20.0, 'vitC': 120.0, 'water': 92.0},
        },
        {
          'id': 38,
          'isFood': 0,
          'g': '3.4',
          'en': 'Red pepper',
          'es': 'Pimiento rojo',
          'recommendable': 1,
          'freeSugar': null,
          'params': {'energyKcal': 31.0, 'vitC': 127.0},
        },
      ]);

      await service.loadNutrientsJson(json);

      final item1 = await db.getNutrientComposition(37);
      expect(item1, isNotNull);
      expect(item1!.foodId, 37);
      expect(item1.group, '3.4');
      expect(item1.nameEn, 'Green pepper');
      expect(item1.nameEs, 'Pimiento verde');
      expect(item1.recommendable, 1);
      expect(item1.freeSugar, '0');

      final params = jsonDecode(item1.params) as Map<String, dynamic>;
      expect(params['energyKcal'], 20.0);
      expect(params['vitC'], 120.0);

      final item2 = await db.getNutrientComposition(38);
      expect(item2, isNotNull);
      expect(item2!.nameEn, 'Red pepper');
    });

    test('replaces all existing data on re-load', () async {
      await service.loadNutrientsJson(jsonEncode([
        {'id': 1, 'isFood': 0, 'g': 'a', 'en': 'Old', 'es': 'Viejo', 'params': {}},
      ]));

      // Re-load with different data
      await service.loadNutrientsJson(jsonEncode([
        {'id': 2, 'isFood': 0, 'g': 'b', 'en': 'New', 'es': 'Nuevo', 'params': {}},
      ]));

      final old = await db.getNutrientComposition(1);
      final new_ = await db.getNutrientComposition(2);
      expect(old, isNull); // old data deleted
      expect(new_, isNotNull);
      expect(new_!.nameEn, 'New');
    });
  });

  group('ReferenceDataService - loadNutrientLossJson', () {
    test('parses and stores nutrient loss data', () async {
      final json = jsonEncode([
        {
          'cookingMethodId': 1,
          'nutrients': {'vitC': 0.25, 'vitB1': 0.15},
        },
        {
          'cookingMethodId': 5,
          'nutrients': {'vitC': 0.30},
        },
      ]);

      await service.loadNutrientLossJson(json);

      final loss1 = await db.getNutrientLoss(1);
      expect(loss1, isNotNull);
      final losses = jsonDecode(loss1!.losses) as Map<String, dynamic>;
      expect(losses['vitC'], 0.25);
      expect(losses['vitB1'], 0.15);

      final loss5 = await db.getNutrientLoss(5);
      expect(loss5, isNotNull);
    });
  });

  group('ReferenceDataService - loadCookingMethodOilsJson', () {
    test('parses and stores cooking oil percentages', () async {
      final json = jsonEncode([
        {'id': 5, 'percentage': 0.10},
        {'id': -4, 'percentage': 0.30},
      ]);

      await service.loadCookingMethodOilsJson(json);

      final oil5 = await db.getCookingMethodOil(5);
      expect(oil5, isNotNull);
      expect(oil5!.percentage, 0.10);

      final oilNeg4 = await db.getCookingMethodOil(-4);
      expect(oilNeg4, isNotNull);
      expect(oilNeg4!.percentage, 0.30);
    });
  });

  group('ReferenceDataService - loadSportMetsJson', () {
    test('parses European comma-decimal METs format', () async {
      final json = jsonEncode([
        {
          'id': 0,
          'en': 'Aerobics',
          'es': 'Aeróbic',
          'mets': ['3,5', '7,0', '10,5'],
        },
      ]);

      await service.loadSportMetsJson(json);

      final sport = await db.getSportMets(0);
      expect(sport, isNotNull);
      expect(sport!.nameEn, 'Aerobics');
      expect(sport.nameEs, 'Aeróbic');

      final mets = jsonDecode(sport.mets) as List;
      expect(mets, [3.5, 7.0, 10.5]);
    });

    test('handles regular decimal METs format', () async {
      final json = jsonEncode([
        {'id': 1, 'en': 'Running', 'es': 'Correr', 'mets': ['8.0', '12.5']},
      ]);

      await service.loadSportMetsJson(json);

      final sport = await db.getSportMets(1);
      final mets = jsonDecode(sport!.mets) as List;
      expect(mets, [8.0, 12.5]);
    });
  });

  group('ReferenceDataService - refreshIfNeeded', () {
    test('fetches and stores data when version is newer', () async {
      final nutrientsJson = jsonEncode([
        {'id': 1, 'isFood': 0, 'g': 'a', 'en': 'Test', 'es': 'Prueba', 'params': {'energyKcal': 100.0}},
      ]);

      final updated = await service.refreshIfNeeded(
        fetchNutrients: () async => ReferencePayload(version: 1, json: nutrientsJson),
      );

      expect(updated, true);
      final comp = await db.getNutrientComposition(1);
      expect(comp, isNotNull);
      expect(await db.getReferenceVersion('nutrients'), 1);
    });

    test('skips fetch when local version is current', () async {
      // Set local version to 5
      await db.setReferenceVersion('nutrients', 5);

      bool fetchCalled = false;
      final updated = await service.refreshIfNeeded(
        fetchNutrients: () async {
          fetchCalled = true;
          return ReferencePayload(version: 3, json: '[]'); // older version
        },
      );

      expect(updated, false);
      expect(fetchCalled, true); // fetch IS called, but data is not stored
    });

    test('updates when server version is higher than local', () async {
      await db.setReferenceVersion('sportMets', 1);

      final sportsJson = jsonEncode([
        {'id': 0, 'en': 'A', 'es': 'B', 'mets': ['3,5']},
      ]);

      final updated = await service.refreshIfNeeded(
        fetchSportMets: () async => ReferencePayload(version: 2, json: sportsJson),
      );

      expect(updated, true);
      expect(await db.getReferenceVersion('sportMets'), 2);
      expect(await db.getSportMets(0), isNotNull);
    });

    test('handles null fetch callbacks gracefully', () async {
      final updated = await service.refreshIfNeeded(
        fetchNutrients: null,
        fetchNutrientLoss: null,
        fetchCookingOils: null,
        fetchSportMets: null,
      );

      expect(updated, false);
    });

    test('handles null payload from fetch', () async {
      final updated = await service.refreshIfNeeded(
        fetchNutrients: () async => null,
      );

      expect(updated, false);
    });
  });
}
