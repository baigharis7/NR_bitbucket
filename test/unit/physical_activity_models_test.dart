import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';

/// Physical Activity test scenarios (TS-PA0001 through TS-PA0010).
///
/// The Add Physical Activity flow uses BLoC + AddSportFavorite as the
/// core editing model. Widget-level behavior requires BlocProvider with
/// many interactors. These tests verify sport-specific data paths,
/// model construction, favorites, routines, and navigation arguments.

void main() {
  AddSportFavInfo createSportInfo({
    int? id = 1,
    String? nameEn = 'Running',
    String? nameEs = 'Correr',
    int? intensity = 1,
    int? minutes = 30,
    int? timeStart,
  }) {
    return AddSportFavInfo(
      id: id,
      name_en: nameEn,
      name_es: nameEs,
      intensity: intensity,
      minutes: minutes,
      timeStart: timeStart,
    );
  }

  // ===========================================================
  // TS-PA0001: Add single physical activity
  // ===========================================================
  group('TS-PA0001: Single physical activity model', () {
    test('SportEventSimple with single SportInfo item', () {
      final event = SportEventSimple(
        userId: 'user1',
        eventId: 1000,
        eventDate: 1700000000,
        info: [
          SportInfo(
            id: 1,
            name_en: 'Running',
            name_es: 'Correr',
            intensity: 2,
            minutes: 45,
          ),
        ],
      );

      expect(event.info!.length, 1);
      expect(event.info!.first.id, 1);
      expect(event.info!.first.name_en, 'Running');
      expect(event.info!.first.intensity, 2);
      expect(event.info!.first.minutes, 45);
    });

    test('AddSportFavorite holds single activity for logging', () {
      final sport = AddSportFavorite(
        userId: 'user1',
        eventId: 1001,
        eventDate: 1700000000,
        info: [createSportInfo(id: 5, nameEn: 'Yoga', minutes: 60, intensity: 0)],
      );

      expect(sport.info!.length, 1);
      expect(sport.info!.first.name_en, 'Yoga');
      expect(sport.info!.first.minutes, 60);
      expect(sport.info!.first.intensity, 0);
    });

  });

  // ===========================================================
  // TS-PA0002: Edit logged activity
  // ===========================================================
  group('TS-PA0002: Edit logged activity', () {
    test('modifying SportEventComplete updates duration and intensity', () {
      final event = SportEventComplete(
        userId: 'user1',
        eventId: 2000,
        eventDate: 1700000000,
        info: [
          SportEventInfo(
            id: 1,
            name_en: 'Running',
            name_es: 'Correr',
            intensity: 1,
            minutes: 30,
            kcal: 250,
          ),
        ],
        eventKcals: 250,
      );

      // Simulate edit: update duration
      event.info![0] = SportEventInfo(
        id: 1,
        name_en: 'Running',
        name_es: 'Correr',
        intensity: 2,
        minutes: 60,
        kcal: 500,
      );

      expect(event.info![0].minutes, 60);
      expect(event.info![0].intensity, 2);
      expect(event.info![0].kcal, 500);
    });

    test('modifying AddSportFavInfo minutes and intensity', () {
      final sport = createSportInfo(id: 1, minutes: 30, intensity: 1);

      sport.minutes = 45;
      sport.intensity = 2;

      expect(sport.minutes, 45);
      expect(sport.intensity, 2);
    });
  });

  // ===========================================================
  // TS-PA0003: Delete logged activity
  // ===========================================================
  group('TS-PA0003: Delete logged activity', () {
    test('removing SportEventComplete from list', () {
      final events = [
        SportEventComplete(
          userId: 'user1',
          eventId: 3000,
          eventDate: 1700000000,
          info: [SportEventInfo(id: 1, name_en: 'Running', minutes: 30)],
          eventKcals: 250,
        ),
        SportEventComplete(
          userId: 'user1',
          eventId: 3001,
          eventDate: 1700000000,
          info: [SportEventInfo(id: 5, name_en: 'Yoga', minutes: 60)],
          eventKcals: 150,
        ),
      ];

      events.removeWhere((e) => e.eventId == 3000);

      expect(events.length, 1);
      expect(events.first.info!.first.name_en, 'Yoga');
    });

    test('removing sport from AddSportFavorite info list', () {
      final sport = AddSportFavorite(
        info: [
          createSportInfo(id: 1, nameEn: 'Running'),
          createSportInfo(id: 5, nameEn: 'Yoga'),
          createSportInfo(id: 10, nameEn: 'Swimming'),
        ],
      );

      sport.info!.removeWhere((s) => s.id == 5);

      expect(sport.info!.length, 2);
      expect(sport.info!.any((s) => s.id == 5), isFalse);
    });
  });

  // ===========================================================
  // TS-PA0004: Create a favorite physical activity
  // ===========================================================
  group('TS-PA0004: Sport favorite model', () {
    test('AddSportFavorite with isFavorite flag', () {
      final favorite = AddSportFavorite(
        userId: 'user1',
        eventId: 4000,
        eventDate: 1700000000,
        info: [createSportInfo(id: 1, nameEn: 'Running', minutes: 30, intensity: 1)],
        title: 'Morning Run',
        isFavorite: true,
      );

      expect(favorite.isFavorite, isTrue);
      expect(favorite.isCreateRoutine, isNull);
      expect(favorite.title, 'Morning Run');
      expect(favorite.info!.length, 1);
    });

    test('multi-sport favorite with title', () {
      final favorite = AddSportFavorite(
        userId: 'user1',
        eventId: 4001,
        eventDate: 1700000000,
        info: [
          createSportInfo(id: 1, nameEn: 'Running', minutes: 30),
          createSportInfo(id: 15, nameEn: 'Stretching', minutes: 15),
        ],
        title: 'Cardio Combo',
        isFavorite: true,
      );

      expect(favorite.isFavorite, isTrue);
      expect(favorite.title, 'Cardio Combo');
      expect(favorite.info!.length, 2);
    });
  });

  // ===========================================================
  // TS-PA0005: Verify favorites title visibility
  // ===========================================================
  group('TS-PA0005: Sport favorites list model', () {
    test('favorites list contains items with isFavorite set', () {
      final favorites = [
        AddSportFavorite(
          info: [createSportInfo(id: 1, nameEn: 'Running', minutes: 30)],
          title: 'Morning Run',
          isFavorite: true,
        ),
        AddSportFavorite(
          info: [createSportInfo(id: 5, nameEn: 'Yoga', minutes: 60)],
          title: 'Evening Yoga',
          isFavorite: true,
        ),
      ];

      expect(favorites.length, 2);
      expect(favorites.every((f) => f.isFavorite == true), isTrue);
      expect(favorites[0].title, 'Morning Run');
      expect(favorites[1].title, 'Evening Yoga');
    });
  });

  // ===========================================================
  // TS-PA0006: Edit a favorite physical activity item
  // ===========================================================
  group('TS-PA0006: Edit sport favorite', () {
    test('updating favorite name and sport details', () {
      final favorite = AddSportFavorite(
        userId: 'user1',
        eventId: 5000,
        eventDate: 1700000000,
        info: [createSportInfo(id: 1, nameEn: 'Running', minutes: 30, intensity: 1)],
        title: 'Morning Run',
        isFavorite: true,
      );

      // Simulate edit
      favorite.title = 'Long Run';
      favorite.info![0].minutes = 60;
      favorite.info![0].intensity = 2;

      expect(favorite.title, 'Long Run');
      expect(favorite.info![0].minutes, 60);
      expect(favorite.info![0].intensity, 2);
      expect(favorite.isFavorite, isTrue);
    });
  });

  // ===========================================================
  // TS-PA0007: Create a routine physical activity
  // ===========================================================
  group('TS-PA0007: Sport routine model', () {
    test('AddSportFavorite with isCreateRoutine, days and time', () {
      final routine = AddSportFavorite(
        userId: 'user1',
        eventId: 6000,
        eventDate: 1700000000,
        info: [createSportInfo(id: 1, nameEn: 'Running', minutes: 45, intensity: 2)],
        title: 'Weekday Run',
        isCreateRoutine: true,
        daysOfWeek: [1, 2, 3, 4, 5],
        scheduleTime: '07:00',
        timeZone: 'Europe/Madrid',
      );

      expect(routine.isCreateRoutine, isTrue);
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.scheduleTime, '07:00');
      expect(routine.timeZone, 'Europe/Madrid');
    });

    test('SportRoutineCompleted stores routine with Info items', () {
      final routine = SportRoutineCompleted(
        userId: 'user1',
        eventId: 6001,
        eventDate: 1700000000,
        info: [
          Info(
            id: 1,
            nameEn: 'Running',
            nameEs: 'Correr',
            intensity: 2,
            minutes: 45,
          ),
        ],
        sportName: 'Weekday Run',
        isRoutine: true,
        daysOfWeek: [1, 3, 5],
        scheduleTime: '07:00',
        timeZone: 'Europe/Madrid',
      );

      expect(routine.isRoutine, isTrue);
      expect(routine.daysOfWeek, [1, 3, 5]);
      expect(routine.scheduleTime, '07:00');
      expect(routine.info!.first.nameEn, 'Running');
      expect(routine.info!.first.minutes, 45);
    });

    test('AddSportFavorite.empty() initializes with blank lists', () {
      final empty = AddSportFavorite.empty(eventData: 1700000000);

      expect(empty.info, isEmpty);
      expect(empty.daysOfWeek, isEmpty);
      expect(empty.eventDate, 1700000000);
    });
  });

  // ===========================================================
  // TS-PA0008: Add Physical Activity via FAB
  // ===========================================================
  group('TS-PA0008: FAB navigation via SportArgumentsModel', () {
    test('creates model with selected date', () {
      final model = SportArgumentsModel(
        selectedDateTime: DateTime(2024, 1, 15),
      );

      expect(model.selectedDateTime, DateTime(2024, 1, 15));
      expect(model.preSelectFavorite, isFalse);
      expect(model.preSelectRoutine, isFalse);
    });

    test('preSelectFavorite flag passed from Favorites screen', () {
      final model = SportArgumentsModel(
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectFavorite: true,
      );

      expect(model.preSelectFavorite, isTrue);
      expect(model.preSelectRoutine, isFalse);
    });

    test('preSelectRoutine flag passed from Routines screen', () {
      final model = SportArgumentsModel(
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectRoutine: true,
      );

      expect(model.preSelectRoutine, isTrue);
      expect(model.preSelectFavorite, isFalse);
    });
  });

  // ===========================================================
  // TS-PA0009: Navigate to Physical Activity Summary
  // TS-PA0010: Add from Summary view
  // ===========================================================
  group('TS-PA0009 & TS-PA0010: Summary view models', () {
    test('sport events list represents summary view data', () {
      final events = [
        SportEventComplete(
          userId: 'user1',
          eventId: 7000,
          eventDate: 1700000000,
          info: [
            SportEventInfo(
              id: 1,
              name_en: 'Running',
              name_es: 'Correr',
              intensity: 2,
              minutes: 45,
              kcal: 400,
            ),
          ],
          sportName: 'Morning Run',
          eventKcals: 400,
        ),
        SportEventComplete(
          userId: 'user1',
          eventId: 7001,
          eventDate: 1700000000,
          info: [
            SportEventInfo(
              id: 5,
              name_en: 'Yoga',
              name_es: 'Yoga',
              intensity: 0,
              minutes: 60,
              kcal: 150,
            ),
          ],
          sportName: 'Evening Yoga',
          eventKcals: 150,
        ),
      ];

      expect(events.length, 2);
      expect(events[0].sportName, 'Morning Run');
      expect(events[0].eventKcals, 400);
      expect(events[1].sportName, 'Evening Yoga');
      expect(events[1].eventKcals, 150);
    });

    test('total kcals can be aggregated from events', () {
      final events = [
        SportEventComplete(
          userId: 'user1',
          eventId: 8000,
          eventDate: 1700000000,
          info: [SportEventInfo(id: 1, minutes: 30, kcal: 250)],
          eventKcals: 250,
        ),
        SportEventComplete(
          userId: 'user1',
          eventId: 8001,
          eventDate: 1700000000,
          info: [SportEventInfo(id: 5, minutes: 60, kcal: 150)],
          eventKcals: 150,
        ),
      ];

      final totalKcals =
          events.fold<int>(0, (sum, e) => sum + (e.eventKcals ?? 0));

      expect(totalKcals, 400);
    });
  });

  // ===========================================================
  // Sport mapper tests
  // ===========================================================
  group('Sport model mapper tests', () {
    test('SportEventComplete holds all logged event fields', () {
      final complete = SportEventComplete(
        userId: 'user1',
        eventId: 9000,
        eventDate: 1700000000,
        comment: 'Great workout',
        sportName: 'Gym Session',
        info: [
          SportEventInfo(
            id: 1,
            name_en: 'Running',
            name_es: 'Correr',
            intensity: 2,
            minutes: 30,
            timeStart: 1700000000,
            kcal: 300,
          ),
          SportEventInfo(
            id: 10,
            name_en: 'Swimming',
            name_es: 'Nadar',
            intensity: 1,
            minutes: 45,
            timeStart: 1700002000,
            kcal: 350,
          ),
        ],
        eventKcals: 650,
      );

      expect(complete.userId, 'user1');
      expect(complete.eventId, 9000);
      expect(complete.comment, 'Great workout');
      expect(complete.sportName, 'Gym Session');
      expect(complete.info!.length, 2);
      expect(complete.info![0].kcal, 300);
      expect(complete.info![1].kcal, 350);
      expect(complete.eventKcals, 650);
    });

    test('SportRoutineCompleted maps routine fields', () {
      final routine = SportRoutineCompleted(
        userId: 'user1',
        eventId: 10000,
        eventDate: 1700000000,
        info: [
          Info(id: 1, nameEn: 'Running', nameEs: 'Correr', intensity: 2, minutes: 30),
          Info(id: 5, nameEn: 'Yoga', nameEs: 'Yoga', intensity: 0, minutes: 30),
        ],
        comment: 'Daily routine',
        sportName: 'Morning Routine',
        scheduleTime: '07:00',
        daysOfWeek: [1, 2, 3, 4, 5],
        timeZone: 'Europe/Madrid',
        isRoutine: true,
      );

      expect(routine.userId, 'user1');
      expect(routine.sportName, 'Morning Routine');
      expect(routine.info!.length, 2);
      expect(routine.scheduleTime, '07:00');
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.isRoutine, isTrue);
      expect(routine.timeZone, 'Europe/Madrid');
    });

    test('AddSportFavorite maps favorite fields for save', () {
      final favorite = AddSportFavorite(
        userId: 'user1',
        eventId: 11000,
        eventDate: 1700000000,
        comment: 'Quick session',
        title: 'HIIT Workout',
        info: [
          createSportInfo(id: 1, nameEn: 'Running', minutes: 20, intensity: 2),
          createSportInfo(id: 15, nameEn: 'Burpees', minutes: 10, intensity: 2),
        ],
        isFavorite: true,
      );

      expect(favorite.userId, 'user1');
      expect(favorite.title, 'HIIT Workout');
      expect(favorite.comment, 'Quick session');
      expect(favorite.info!.length, 2);
      expect(favorite.isFavorite, isTrue);
      expect(favorite.info![0].minutes, 20);
      expect(favorite.info![1].minutes, 10);
    });
  });
}
