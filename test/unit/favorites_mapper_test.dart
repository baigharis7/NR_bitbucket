import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/data/local/models/favorites/sport/sport_favorite_entity.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';

void main() {
  group('mapToSportFavoriteFromEntity', () {
    test('maps timeZone from entity timeZone, not scheduleTime', () {
      final entity = SportFavoriteEntity(
        userId: 'user123',
        eventDate: 1700000000000,
        title: 'Badminton',
        comment: null,
        info: [
          SportFavoriteInfoEntity(
            id: 1,
            intensity: 2,
            minutes: 60,
            timeStart: 1700000000000,
            name_en: 'Badminton',
            name_es: 'Bádminton',
          ),
        ],
        eventId: 12345,
        scheduleTime: '17:30',
        daysOfWeek: [6, 7],
        isFavorite: false,
        isCreateRoutine: true,
        timeZone: 'Asia/Karachi',
      );

      final result = mapToSportFavoriteFromEntity(entity);

      expect(result.timeZone, 'Asia/Karachi');
      expect(result.scheduleTime, '17:30');
      // Ensure timeZone is NOT the scheduleTime value
      expect(result.timeZone, isNot(equals(result.scheduleTime)));
    });

    test('maps all fields correctly from entity', () {
      final entity = SportFavoriteEntity(
        userId: 'user456',
        eventDate: 1700000000000,
        title: 'Pilates',
        comment: 'Morning session',
        info: [
          SportFavoriteInfoEntity(
            id: 2,
            intensity: 1,
            minutes: 45,
            timeStart: 1700000000000,
            name_en: 'Pilates',
            name_es: 'Pilates',
          ),
        ],
        eventId: 67890,
        scheduleTime: '08:00',
        daysOfWeek: [1, 3, 5],
        isFavorite: true,
        isCreateRoutine: false,
        timeZone: 'Europe/Madrid',
      );

      final result = mapToSportFavoriteFromEntity(entity);

      expect(result.userId, 'user456');
      expect(result.eventId, 67890);
      expect(result.eventDate, 1700000000000);
      expect(result.title, 'Pilates');
      expect(result.comment, 'Morning session');
      expect(result.scheduleTime, '08:00');
      expect(result.daysOfWeek, [1, 3, 5]);
      expect(result.isFavorite, true);
      expect(result.isCreateRoutine, false);
      expect(result.timeZone, 'Europe/Madrid');
      expect(result.info!.length, 1);
      expect(result.info!.first.id, 2);
      expect(result.info!.first.minutes, 45);
    });

    test('handles null timeZone in entity', () {
      final entity = SportFavoriteEntity(
        userId: 'user789',
        eventDate: 1700000000000,
        title: 'Running',
        comment: null,
        info: [],
        scheduleTime: '06:00',
        timeZone: null,
      );

      final result = mapToSportFavoriteFromEntity(entity);

      expect(result.timeZone, isNull);
      expect(result.scheduleTime, '06:00');
    });
  });
}
