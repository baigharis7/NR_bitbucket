import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/sport_kcal_service.dart';

void main() {
  late ReferenceDatabase db;
  late SportKcalCalculationService service;

  setUp(() {
    db = ReferenceDatabase(NativeDatabase.memory());
    service = SportKcalCalculationService(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> _insertSportMets(int sportId, List<double> mets) async {
    await db.into(db.sportMets).insert(SportMetsCompanion(
      sportId: Value(sportId),
      nameEn: const Value('Test Sport'),
      nameEs: const Value('Deporte Test'),
      mets: Value(jsonEncode(mets)),
    ));
  }

  group('SportKcalCalculationService', () {
    test('computes kcal using correct formula: METs * 0.0175 * weight * minutes', () async {
      // METs: [3.5, 7.0, 10.5] for intensities 0, 1, 2
      await _insertSportMets(0, [3.5, 7.0, 10.5]);

      final simple = SportEventSimple(
        userId: 'user1',
        eventId: 1000,
        eventDate: 20260212,
        info: [
          SportInfo(id: 0, name_en: 'Aerobics', intensity: 1, minutes: 30),
        ],
      );

      final result = await service.enrichSportEvent(simple, userWeight: 70.0);

      // Expected: 7.0 * 0.0175 * 70 * 30 = 257.25 → rounds to 257
      expect(result.info!.length, 1);
      expect(result.info![0].kcal, 257);
      expect(result.eventKcals, 257);
    });

    test('uses intensity 0 when intensity is 0', () async {
      await _insertSportMets(1, [3.5, 7.0, 10.5]);

      final simple = SportEventSimple(
        userId: 'user1',
        eventId: 1001,
        eventDate: 20260212,
        info: [
          SportInfo(id: 1, name_en: 'Archery', intensity: 0, minutes: 60),
        ],
      );

      final result = await service.enrichSportEvent(simple, userWeight: 80.0);

      // Expected: 3.5 * 0.0175 * 80 * 60 = 294
      expect(result.info![0].kcal, 294);
      expect(result.eventKcals, 294);
    });

    test('falls back to first METs value when intensity out of range', () async {
      await _insertSportMets(2, [5.0, 8.0]);

      final simple = SportEventSimple(
        userId: 'user1',
        eventId: 1002,
        eventDate: 20260212,
        info: [
          SportInfo(id: 2, name_en: 'Badminton', intensity: 10, minutes: 30),
        ],
      );

      final result = await service.enrichSportEvent(simple, userWeight: 70.0);

      // Intensity 10 is out of range [0,1], falls back to metsList[0] = 5.0
      // Expected: 5.0 * 0.0175 * 70 * 30 = 183.75 → 184
      expect(result.info![0].kcal, 184);
    });

    test('returns 0 kcal when sport not found in database', () async {
      final simple = SportEventSimple(
        userId: 'user1',
        eventId: 1003,
        eventDate: 20260212,
        info: [
          SportInfo(id: 999, name_en: 'Unknown', intensity: 0, minutes: 30),
        ],
      );

      final result = await service.enrichSportEvent(simple, userWeight: 70.0);

      expect(result.info![0].kcal, 0);
      expect(result.eventKcals, 0);
    });

    test('sums kcal across multiple sports', () async {
      await _insertSportMets(0, [3.5]);
      await _insertSportMets(1, [5.0]);

      final simple = SportEventSimple(
        userId: 'user1',
        eventId: 1004,
        eventDate: 20260212,
        info: [
          SportInfo(id: 0, name_en: 'Aerobics', intensity: 0, minutes: 30),
          SportInfo(id: 1, name_en: 'Archery', intensity: 0, minutes: 60),
        ],
      );

      final result = await service.enrichSportEvent(simple, userWeight: 70.0);

      // Sport 0: 3.5 * 0.0175 * 70 * 30 = 128.625 → 129
      // Sport 1: 5.0 * 0.0175 * 70 * 60 = 367.5 → 368
      final kcal0 = result.info![0].kcal!;
      final kcal1 = result.info![1].kcal!;
      expect(kcal0, 129);
      expect(kcal1, 368);
      expect(result.eventKcals, kcal0 + kcal1);
    });

    test('handles null info list gracefully', () async {
      final simple = SportEventSimple(
        userId: 'user1',
        eventId: 1005,
        eventDate: 20260212,
        info: null,
      );

      final result = await service.enrichSportEvent(simple, userWeight: 70.0);

      expect(result.info, isEmpty);
      expect(result.eventKcals, 0);
    });

    test('preserves metadata from input', () async {
      await _insertSportMets(0, [3.5]);

      final simple = SportEventSimple(
        userId: 'user123',
        eventId: 9999,
        eventDate: 20260212,
        comment: 'morning workout',
        sportName: 'Aerobics',
        info: [
          SportInfo(id: 0, name_en: 'Aerobics', name_es: 'Aeróbic', intensity: 0, minutes: 10, timeStart: 800),
        ],
      );

      final result = await service.enrichSportEvent(simple, userWeight: 70.0);

      expect(result.userId, 'user123');
      expect(result.eventId, 9999);
      expect(result.eventDate, 20260212);
      expect(result.comment, 'morning workout');
      expect(result.sportName, 'Aerobics');
      expect(result.info![0].name_en, 'Aerobics');
      expect(result.info![0].name_es, 'Aeróbic');
      expect(result.info![0].timeStart, 800);
      expect(result.info![0].minutes, 10);
    });
  });
}
