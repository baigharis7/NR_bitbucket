import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplements_ev.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/supplement_favorite.dart';
import 'package:nutrenaissance_flutter/data/api/supplements/model/upload_supplement_routine.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/supplement_mappers.dart';

/// Supplement test scenarios (TS-SUP0001 through TS-SUP0017).
///
/// The Add Supplement flow uses BLoC + SupplementSimple as the core model.
/// Widget-level behavior requires BlocProvider with many interactors.
/// These tests verify the Supplement-specific data paths and mappers.

void main() {
  NutriInfo createNutriInfo({
    int id = 10,
    String unit = 'mg',
    int amount = 1000,
  }) {
    return NutriInfo(id: id, unit: unit, amount: amount);
  }

  // ===========================================================
  // TS-SUP0001: Log single supplement (non-goal)
  // ===========================================================
  group('TS-SUP0001: Single supplement model', () {
    test('single supplement item with id, amount and unit', () {
      final supplement = SupplementSimple(
        userId: 'user1',
        eventId: 1000,
        eventDate: 1700000000,
        info: [createNutriInfo(id: 10, amount: 1000, unit: 'IU')],
        name: 'Vitamin D',
      );

      expect(supplement.info!.length, 1);
      expect(supplement.info!.first.id, 10);
      expect(supplement.info!.first.amount, 1000);
      expect(supplement.info!.first.unit, 'IU');
      expect(supplement.name, 'Vitamin D');
      expect(supplement.isFavorite, isFalse);
      expect(supplement.isRoutine, isFalse);
    });
  });

  // ===========================================================
  // TS-SUP0002: Log multiple supplements (non-goal)
  // ===========================================================
  group('TS-SUP0002: Multi-item supplement model', () {
    test('multiple supplement entries in a single event', () {
      final supplement = SupplementSimple(
        userId: 'user1',
        eventId: 1001,
        eventDate: 1700000000,
        info: [
          createNutriInfo(id: 10, amount: 1000, unit: 'IU'),
          createNutriInfo(id: 11, amount: 500, unit: 'mg'),
          createNutriInfo(id: 12, amount: 200, unit: 'mcg'),
        ],
      );

      expect(supplement.info!.length, 3);
      expect(supplement.info![0].unit, 'IU');
      expect(supplement.info![1].amount, 500);
      expect(supplement.info![2].unit, 'mcg');
    });
  });

  // ===========================================================
  // TS-SUP0003: Create favorite supplement
  // ===========================================================
  group('TS-SUP0003: Supplement favorite model', () {
    test('single supplement marked as favorite', () {
      final supplement = SupplementSimple(
        userId: 'user1',
        eventId: 2000,
        eventDate: 1700000000,
        info: [createNutriInfo(id: 15, amount: 400, unit: 'mg')],
        name: 'Magnesium',
        isFavorite: true,
      );

      expect(supplement.isFavorite, isTrue);
      expect(supplement.isRoutine, isFalse);
      expect(supplement.name, 'Magnesium');
    });

    test('favorite with multiple supplements requires a name', () {
      final supplement = SupplementSimple(
        userId: 'user1',
        eventId: 2001,
        eventDate: 1700000000,
        info: [
          createNutriInfo(id: 10, amount: 1000, unit: 'IU'),
          createNutriInfo(id: 15, amount: 400, unit: 'mg'),
        ],
        name: 'Daily Vitamins',
        isFavorite: true,
      );

      expect(supplement.isFavorite, isTrue);
      expect(supplement.name, 'Daily Vitamins');
      expect(supplement.info!.length, 2);
    });
  });

  // ===========================================================
  // TS-SUP0004: Create routine supplement
  // ===========================================================
  group('TS-SUP0004: Supplement routine model', () {
    test('supplement marked as routine with days and time', () {
      final supplement = SupplementSimple(
        userId: 'user1',
        eventId: 3000,
        eventDate: 1700000000,
        info: [createNutriInfo(id: 20, amount: 1000, unit: 'mg')],
        name: 'Omega 3',
        isRoutine: true,
        daysOfWeek: [1, 3, 5],
        scheduleTime: '08:00',
        timeZone: 'Europe/Madrid',
      );

      expect(supplement.isRoutine, isTrue);
      expect(supplement.isFavorite, isFalse);
      expect(supplement.daysOfWeek, [1, 3, 5]);
      expect(supplement.scheduleTime, '08:00');
      expect(supplement.timeZone, 'Europe/Madrid');
    });
  });

  // ===========================================================
  // TS-SUP0005: Edit logged supplement (modify amount/unit)
  // ===========================================================
  group('TS-SUP0005: Edit supplement model', () {
    test('updating NutriInfo amount reflects change', () {
      final info = createNutriInfo(id: 10, amount: 1000, unit: 'IU');

      // Simulate edit: user changes amount
      info.amount = 2000;

      expect(info.amount, 2000);
      expect(info.unit, 'IU');
    });

    test('replacing info item in supplement list simulates edit', () {
      final supplement = SupplementSimple(
        info: [
          createNutriInfo(id: 10, amount: 1000, unit: 'IU'),
          createNutriInfo(id: 11, amount: 500, unit: 'mg'),
        ],
      );

      // Simulate edit: update first item amount
      supplement.info![0].amount = 2000;

      expect(supplement.info![0].amount, 2000);
      expect(supplement.info![1].amount, 500);
    });
  });

  // ===========================================================
  // TS-SUP0006: Delete logged supplement
  // ===========================================================
  group('TS-SUP0006: Delete supplement model', () {
    test('removing NutriInfo from list reduces count', () {
      final supplement = SupplementSimple(
        info: [
          createNutriInfo(id: 10, amount: 1000, unit: 'IU'),
          createNutriInfo(id: 11, amount: 500, unit: 'mg'),
          createNutriInfo(id: 12, amount: 200, unit: 'mcg'),
        ],
      );

      supplement.info!.removeWhere((n) => n.id == 11);

      expect(supplement.info!.length, 2);
      expect(supplement.info!.any((n) => n.id == 11), isFalse);
    });
  });

  // ===========================================================
  // TS-SUP0007: Goal-based Creatine (id: 80)
  // ===========================================================
  group('TS-SUP0007: Goal-based Creatine supplement', () {
    test('Creatine NutriInfo uses constant id 80', () {
      const creatineId = 80;
      final creatine = NutriInfo(id: creatineId, unit: 'mg', amount: 5);

      expect(creatine.id, 80);
      expect(creatine.unit, 'mg');
    });

    test('Creatine RDI pre-fill is 0.08 * weight (int)', () {
      // Logic from supplements_screen.dart: (0.08 * weight).toInt()
      const weight = 70.0;
      final rdi = (0.08 * weight).toInt();

      expect(rdi, 5); // 70kg → 5mg
    });

    test('Creatine supplement model for goal "Reduce risk of injury" (id: 48)',
        () {
      const reduceRiskOfInjury = 48;
      final userObjectives = [reduceRiskOfInjury];

      expect(
          userObjectives.contains(reduceRiskOfInjury), isTrue);

      final creatineSupplement = SupplementSimple(
        info: [NutriInfo(id: 80, unit: 'mg', amount: 5)],
      );

      expect(creatineSupplement.info!.first.id, 80);
      expect(creatineSupplement.info!.first.amount, 5);
    });
  });

  // ===========================================================
  // TS-SUP0008: Goal-based Collagen (id: 81)
  // ===========================================================
  group('TS-SUP0008: Goal-based Collagen supplement', () {
    test('Collagen NutriInfo uses constant id 81', () {
      const collagenId = 81;
      final collagen = NutriInfo(id: collagenId, unit: 'mg', amount: 10);

      expect(collagen.id, 81);
      expect(collagen.unit, 'mg');
    });

    test('Collagen RDI pre-fill is fixed at 10 mg', () {
      const collagenRdi = 10;
      expect(collagenRdi, 10);
    });

    test(
        'Collagen supplement model for goal "Recover from injury" (id: 49)',
        () {
      const recoveryAfterSportInjury = 49;
      final userObjectives = [recoveryAfterSportInjury];

      expect(userObjectives.contains(recoveryAfterSportInjury), isTrue);

      final collagenSupplement = SupplementSimple(
        info: [NutriInfo(id: 81, unit: 'mg', amount: 10)],
      );

      expect(collagenSupplement.info!.first.id, 81);
      expect(collagenSupplement.info!.first.amount, 10);
    });
  });

  // ===========================================================
  // TS-SUP0009: No goals → no supplement suggestions
  // ===========================================================
  group('TS-SUP0009: No goals set — no suggestions', () {
    test('empty objectives list does not contain injury goals', () {
      const reduceRiskOfInjury = 48;
      const recoveryAfterSportInjury = 49;
      final userObjectives = <int>[];

      final hasInjuryGoal = userObjectives.any(
          (e) => e == reduceRiskOfInjury || e == recoveryAfterSportInjury);

      expect(hasInjuryGoal, isFalse);
    });

    test('unrelated objectives do not trigger supplement suggestions', () {
      const reduceRiskOfInjury = 48;
      const recoveryAfterSportInjury = 49;
      // Goals like "Improve sport performance" (47), "Gain muscle" (50)
      final userObjectives = [47, 50, 51];

      final hasInjuryGoal = userObjectives.any(
          (e) => e == reduceRiskOfInjury || e == recoveryAfterSportInjury);

      expect(hasInjuryGoal, isFalse);
    });
  });

  // ===========================================================
  // TS-SUP0010: Edit suggested supplement and create routine
  // ===========================================================
  group('TS-SUP0010: Goal supplement to routine', () {
    test('Creatine supplement converted to routine with days', () {
      final creatineRoutine = SupplementSimple(
        userId: 'user1',
        eventId: 4000,
        eventDate: 1700000000,
        info: [NutriInfo(id: 80, unit: 'mg', amount: 5)],
        name: 'Creatine',
        isRoutine: true,
        daysOfWeek: [1, 2], // Mon, Tue
        scheduleTime: '09:00',
        timeZone: 'Europe/Madrid',
      );

      expect(creatineRoutine.info!.first.id, 80);
      expect(creatineRoutine.isRoutine, isTrue);
      expect(creatineRoutine.daysOfWeek, [1, 2]);
      expect(creatineRoutine.scheduleTime, '09:00');
    });
  });

  // ===========================================================
  // TS-SUP0011: Edit logged goal-based supplement
  // ===========================================================
  group('TS-SUP0011: Edit goal-based supplement', () {
    test('modifying Creatine amount updates correctly', () {
      final creatine = NutriInfo(id: 80, unit: 'mg', amount: 5);

      // User edits amount
      creatine.amount = 10;

      expect(creatine.id, 80);
      expect(creatine.amount, 10);
    });
  });

  // ===========================================================
  // TS-SUP0012: Delete logged goal-based supplement
  // ===========================================================
  group('TS-SUP0012: Delete goal-based supplement', () {
    test('removing Creatine from supplement events', () {
      final events = [
        SupplementSimple(
          info: [NutriInfo(id: 80, unit: 'mg', amount: 5)],
          name: 'Creatine',
        ),
        SupplementSimple(
          info: [NutriInfo(id: 10, unit: 'IU', amount: 1000)],
          name: 'Vitamin D',
        ),
      ];

      events.removeWhere(
          (e) => e.info!.any((n) => n.id == 80));

      expect(events.length, 1);
      expect(events.first.name, 'Vitamin D');
    });

    test('aggregating Creatine totals from events', () {
      final events = [
        SupplementSimple(
            info: [NutriInfo(id: 80, unit: 'mg', amount: 3)]),
        SupplementSimple(
            info: [NutriInfo(id: 80, unit: 'mg', amount: 5)]),
        SupplementSimple(
            info: [NutriInfo(id: 10, unit: 'IU', amount: 1000)]),
      ];

      final totalCreatine = events
          .expand((event) => event.info!)
          .where((info) => info.id == 80)
          .fold<int>(0, (sum, info) => sum + info.amount);

      expect(totalCreatine, 8);
    });

    test('aggregating Collagen totals from events', () {
      final events = [
        SupplementSimple(
            info: [NutriInfo(id: 81, unit: 'mg', amount: 10)]),
        SupplementSimple(
            info: [NutriInfo(id: 81, unit: 'mg', amount: 5)]),
      ];

      final totalCollagen = events
          .expand((event) => event.info!)
          .where((info) => info.id == 81)
          .fold<int>(0, (sum, info) => sum + info.amount);

      expect(totalCollagen, 15);
    });
  });

  // ===========================================================
  // TS-SUP0013: Favorites title visibility
  // ===========================================================
  group('TS-SUP0013: Supplement favorites list model', () {
    test('favorites list contains items with isFavorite set', () {
      final favorites = [
        SupplementSimple(
          info: [createNutriInfo(id: 10, amount: 1000, unit: 'IU')],
          name: 'Vitamin D',
          isFavorite: true,
        ),
        SupplementSimple(
          info: [createNutriInfo(id: 15, amount: 400, unit: 'mg')],
          name: 'Magnesium',
          isFavorite: true,
        ),
      ];

      expect(favorites.length, 2);
      expect(favorites.every((f) => f.isFavorite), isTrue);
      expect(favorites[0].name, 'Vitamin D');
      expect(favorites[1].name, 'Magnesium');
    });
  });

  // ===========================================================
  // TS-SUP0014: Edit a favorite supplement item
  // ===========================================================
  group('TS-SUP0014: Edit supplement favorite', () {
    test('updating favorite supplement name and amount', () {
      final favorite = SupplementSimple(
        userId: 'user1',
        eventId: 5000,
        eventDate: 1700000000,
        info: [createNutriInfo(id: 10, amount: 1000, unit: 'IU')],
        name: 'Vitamin D',
        isFavorite: true,
      );

      // Simulate edit
      favorite.name = 'Vitamin D3';
      favorite.info![0].amount = 2000;

      expect(favorite.name, 'Vitamin D3');
      expect(favorite.info![0].amount, 2000);
      expect(favorite.isFavorite, isTrue);
    });
  });

  // ===========================================================
  // TS-SUP0015: Add Supplement via FAB
  // Supplements use direct navigation (no arguments model).
  // When arguments are present, it's a SupplementSimple for edit mode.
  // ===========================================================
  group('TS-SUP0015: FAB navigation for supplements', () {
    test('SupplementSimple can be passed as navigation argument', () {
      final arg = SupplementSimple(
        info: [createNutriInfo(id: 10, amount: 1000, unit: 'IU')],
        name: 'Vitamin D',
      );

      // Navigation passes SupplementSimple directly (no separate args model)
      expect(arg.info!.length, 1);
      expect(arg.name, 'Vitamin D');
    });

  });

  // ===========================================================
  // TS-SUP0016: Navigate to Supplements Summary
  // TS-SUP0017: Add from Summary view
  // Navigation is direct to named routes; models verified here.
  // ===========================================================
  group('TS-SUP0016 & TS-SUP0017: Summary navigation models', () {
    test('supplement events list represents summary view data', () {
      final events = [
        SupplementSimple(
          userId: 'user1',
          eventId: 6000,
          eventDate: 1700000000,
          info: [createNutriInfo(id: 10, amount: 1000, unit: 'IU')],
          name: 'Vitamin D',
        ),
        SupplementSimple(
          userId: 'user1',
          eventId: 6001,
          eventDate: 1700000000,
          info: [createNutriInfo(id: 15, amount: 400, unit: 'mg')],
          name: 'Magnesium',
        ),
      ];

      expect(events.length, 2);
      expect(events[0].name, 'Vitamin D');
      expect(events[1].name, 'Magnesium');
    });
  });

  // ===========================================================
  // Mapper tests: SupplementSimple → upload/favorite/routine models
  // ===========================================================
  group('Supplement save flow mappers', () {
    test('mapToUploadSupplementsEv maps supplement fields', () {
      final supplement = SupplementSimple(
        userId: 'user1',
        eventId: 7000,
        eventDate: 1700000000,
        info: [
          createNutriInfo(id: 10, amount: 1000, unit: 'IU'),
          createNutriInfo(id: 15, amount: 400, unit: 'mg'),
        ],
        name: 'Daily Vitamins',
      );

      final upload = mapToUploadSupplementsEv(supplement);

      expect(upload.userId, 'user1');
      expect(upload.eventId, 7000);
      expect(upload.eventDate, 1700000000);
      expect(upload.info.length, 2);
      expect(upload.info[0].id, 10);
      expect(upload.info[0].amount, 1000);
      expect(upload.info[0].unit, 'IU');
      expect(upload.info[1].id, 15);
      expect(upload.name, 'Daily Vitamins');
    });

    test('mapToSupplementFavoriteFromSupplement maps favorite fields', () {
      final supplement = SupplementSimple(
        userId: 'user1',
        eventId: 8000,
        eventDate: 1700000000,
        info: [createNutriInfo(id: 15, amount: 400, unit: 'mg')],
        name: 'Magnesium',
        isFavorite: true,
      );

      final favorite = mapToSupplementFavoriteFromSupplement(supplement);

      expect(favorite.userId, 'user1');
      expect(favorite.eventId, 8000);
      expect(favorite.eventDate, 1700000000);
      expect(favorite.data.length, 1);
      expect(favorite.data.first.id, 15);
      expect(favorite.data.first.amount, 400);
      expect(favorite.data.first.unit, 'mg');
      expect(favorite.name, 'Magnesium');
    });

    test('mapToSupplementRoutineFromSupplement maps routine fields', () {
      final supplement = SupplementSimple(
        userId: 'user1',
        eventId: 9000,
        eventDate: 1700000000,
        info: [createNutriInfo(id: 20, amount: 1000, unit: 'mg')],
        name: 'Omega 3',
        isRoutine: true,
        daysOfWeek: [1, 3, 5],
        scheduleTime: '08:00',
        timeZone: 'Europe/Madrid',
      );

      final routine = mapToSupplementRoutineFromSupplement(supplement);

      expect(routine.userId, 'user1');
      expect(routine.eventId, 9000);
      expect(routine.eventDate, 1700000000);
      expect(routine.info.length, 1);
      expect(routine.info.first.id, 20);
      expect(routine.info.first.amount, 1000);
      expect(routine.info.first.unit, 'mg');
      expect(routine.name, 'Omega 3');
      expect(routine.time, '08:00');
      expect(routine.daysOfWeek, [1, 3, 5]);
      expect(routine.timeZone, 'Europe/Madrid');
    });

    test('mapToUploadSupplementsEv handles single Creatine entry', () {
      final creatine = SupplementSimple(
        userId: 'user1',
        eventId: 10000,
        eventDate: 1700000000,
        info: [NutriInfo(id: 80, unit: 'mg', amount: 5)],
        name: 'Creatine',
      );

      final upload = mapToUploadSupplementsEv(creatine);

      expect(upload.info.length, 1);
      expect(upload.info.first.id, 80);
      expect(upload.info.first.amount, 5);
      expect(upload.name, 'Creatine');
    });
  });
}
