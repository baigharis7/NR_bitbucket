import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/sports_info_entity.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/health_activity_type_mapping.dart';

void main() {
  late SportsInfoEntity testSportsInfo;

  setUp(() {
    // Create test sports info with sample sports
    testSportsInfo = SportsInfoEntity(
      id: 1,
      v: 1,
      data: [
        SportInfoEntity(id: 1, en: 'Running', es: 'Correr', mets: 8),
        SportInfoEntity(id: 2, en: 'Walking', es: 'Caminar', mets: 3),
        SportInfoEntity(id: 3, en: 'Swimming', es: 'Natación', mets: 7),
        SportInfoEntity(id: 4, en: 'Cycling', es: 'Ciclismo', mets: 6),
        SportInfoEntity(id: 5, en: 'Weight Training', es: 'Pesas', mets: 5),
        SportInfoEntity(id: 6, en: 'Yoga', es: 'Yoga', mets: 2),
        SportInfoEntity(id: 7, en: 'Tennis', es: 'Tenis', mets: 7),
        SportInfoEntity(id: 8, en: 'Soccer', es: 'Fútbol', mets: 8),
        SportInfoEntity(id: 9, en: 'General Exercise', es: 'Ejercicio General', mets: 4),
      ],
    );
  });

  group('HealthActivityTypeMapping.mapToSportId', () {
    test('should map RUNNING to running sport ID', () {
      final sportId = HealthActivityTypeMapping.mapToSportId('RUNNING', testSportsInfo);
      expect(sportId, 1);
    });

    test('should map WALKING to walking sport ID', () {
      final sportId = HealthActivityTypeMapping.mapToSportId('WALKING', testSportsInfo);
      expect(sportId, 2);
    });

    test('should map SWIMMING to swimming sport ID', () {
      final sportId = HealthActivityTypeMapping.mapToSportId('SWIMMING', testSportsInfo);
      expect(sportId, 3);
    });

    test('should map CYCLING to cycling sport ID', () {
      final sportId = HealthActivityTypeMapping.mapToSportId('CYCLING', testSportsInfo);
      expect(sportId, 4);
    });

    test('should map TRADITIONAL_STRENGTH_TRAINING to weight training sport ID', () {
      final sportId = HealthActivityTypeMapping.mapToSportId(
        'TRADITIONAL_STRENGTH_TRAINING',
        testSportsInfo,
      );
      expect(sportId, 5);
    });

    test('should map YOGA to yoga sport ID', () {
      final sportId = HealthActivityTypeMapping.mapToSportId('YOGA', testSportsInfo);
      expect(sportId, 6);
    });

    test('should map TENNIS to tennis sport ID', () {
      final sportId = HealthActivityTypeMapping.mapToSportId('TENNIS', testSportsInfo);
      expect(sportId, 7);
    });

    test('should map SOCCER to soccer sport ID', () {
      final sportId = HealthActivityTypeMapping.mapToSportId('SOCCER', testSportsInfo);
      expect(sportId, 8);
    });

    test('should be case-insensitive for workout type', () {
      expect(HealthActivityTypeMapping.mapToSportId('running', testSportsInfo), 1);
      expect(HealthActivityTypeMapping.mapToSportId('Running', testSportsInfo), 1);
      expect(HealthActivityTypeMapping.mapToSportId('RUNNING', testSportsInfo), 1);
    });

    test('should return null for unknown workout type with no match', () {
      final emptyInfo = SportsInfoEntity(id: 1, v: 1, data: []);
      final sportId = HealthActivityTypeMapping.mapToSportId('UNKNOWN_SPORT', emptyInfo);
      expect(sportId, null);
    });
  });

  group('HealthActivityTypeMapping.findFallbackSportId', () {
    test('should find general exercise as fallback', () {
      final sportId = HealthActivityTypeMapping.findFallbackSportId(testSportsInfo);
      expect(sportId, 9); // General Exercise
    });

    test('should return first sport ID if no fallback found', () {
      final noFallbackInfo = SportsInfoEntity(
        id: 1,
        v: 1,
        data: [
          SportInfoEntity(id: 100, en: 'Specific Sport', es: 'Deporte Específico', mets: 5),
        ],
      );
      final sportId = HealthActivityTypeMapping.findFallbackSportId(noFallbackInfo);
      expect(sportId, 100);
    });

    test('should return null for empty sports list', () {
      final emptyInfo = SportsInfoEntity(id: 1, v: 1, data: []);
      final sportId = HealthActivityTypeMapping.findFallbackSportId(emptyInfo);
      expect(sportId, null);
    });
  });

  group('HealthActivityTypeMapping.findSportById', () {
    test('should find sport by ID', () {
      final sport = HealthActivityTypeMapping.findSportById(1, testSportsInfo);
      expect(sport, isNotNull);
      expect(sport!.en, 'Running');
      expect(sport.es, 'Correr');
    });

    test('should return null for non-existent ID', () {
      final sport = HealthActivityTypeMapping.findSportById(999, testSportsInfo);
      expect(sport, null);
    });
  });

  group('HealthActivityTypeMapping.inferIntensity', () {
    test('should return low intensity for low heart rate', () {
      final intensity = HealthActivityTypeMapping.inferIntensity(null, 30, 90);
      expect(intensity, 0); // Low
    });

    test('should return medium intensity for medium heart rate', () {
      final intensity = HealthActivityTypeMapping.inferIntensity(null, 30, 120);
      expect(intensity, 1); // Medium
    });

    test('should return high intensity for high heart rate', () {
      final intensity = HealthActivityTypeMapping.inferIntensity(null, 30, 160);
      expect(intensity, 2); // High
    });

    test('should use calories per minute when heart rate not available', () {
      // Low: < 5 cal/min -> 4 cal/min = 120 cal in 30 min
      expect(HealthActivityTypeMapping.inferIntensity(120, 30, null), 0);

      // Medium: 5-10 cal/min -> 7 cal/min = 210 cal in 30 min
      expect(HealthActivityTypeMapping.inferIntensity(210, 30, null), 1);

      // High: > 10 cal/min -> 15 cal/min = 450 cal in 30 min
      expect(HealthActivityTypeMapping.inferIntensity(450, 30, null), 2);
    });

    test('should return medium intensity as default when no data', () {
      final intensity = HealthActivityTypeMapping.inferIntensity(null, 30, null);
      expect(intensity, 1); // Medium
    });

    test('should return medium intensity for zero duration', () {
      final intensity = HealthActivityTypeMapping.inferIntensity(100, 0, null);
      expect(intensity, 1); // Medium
    });

    test('should prefer heart rate over calories when both available', () {
      // High heart rate should take precedence
      final intensity = HealthActivityTypeMapping.inferIntensity(120, 30, 160);
      expect(intensity, 2); // High (based on heart rate)
    });
  });

  group('Spanish keyword matching', () {
    test('should match Spanish keywords for running', () {
      final infoWithSpanishOnly = SportsInfoEntity(
        id: 1,
        v: 1,
        data: [
          SportInfoEntity(id: 1, en: 'Jogging Activity', es: 'Correr', mets: 8),
        ],
      );
      final sportId = HealthActivityTypeMapping.mapToSportId('RUNNING', infoWithSpanishOnly);
      expect(sportId, 1);
    });

    test('should match Spanish keywords for swimming', () {
      final infoWithSpanishOnly = SportsInfoEntity(
        id: 1,
        v: 1,
        data: [
          SportInfoEntity(id: 1, en: 'Water Activity', es: 'Natación', mets: 7),
        ],
      );
      final sportId = HealthActivityTypeMapping.mapToSportId('SWIMMING', infoWithSpanishOnly);
      expect(sportId, 1);
    });
  });
}
