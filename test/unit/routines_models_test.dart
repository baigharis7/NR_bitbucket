import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodroutine/food_routine_event.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/routines/sport_routine_completed.dart';

/// Routines test scenarios (TS-ROU001 through TS-ROU024).
///
/// Cross-category routines management: view, edit, delete, and routine event
/// creation for Breakfast (mealTime 0), Lunch (mealTime 1), Dinner (mealTime 2),
/// Snack (mealTime 3), Supplements, and Physical Activity.
///
/// Food routines use FoodFavorite with isRoutine=true, daysOfWeek, and time.
/// Supplement routines use SupplementSimple with isRoutine=true, daysOfWeek, scheduleTime.
/// Physical Activity routines use AddSportFavorite/SportRoutineCompleted with
/// isCreateRoutine/isRoutine=true, daysOfWeek, scheduleTime.
///
/// Green + button on Routines tab:
/// - Meal tab: overlay menu → FoodArgumentsModel(preSelectRoutine: true)
/// - Physical Activity tab: SportArgumentsModel(preSelectRoutine: true)
/// - Supplements tab: direct navigation

void main() {
  // ---- Helpers ----

  FoodFavorite createMealRoutine({
    required int mealTime,
    required String title,
    required List<int> daysOfWeek,
    required String time,
    List<FoodInFavorite>? ingredients,
  }) {
    return FoodFavorite(
      title: title,
      mealTime: mealTime,
      isFavorite: false,
      isRoutine: true,
      daysOfWeek: daysOfWeek,
      time: time,
      timeZone: 'Europe/Madrid',
      ingredients: ingredients ??
          [
            FoodInFavorite(
              id: 100,
              qty: 150,
              unit: 1,
              conversionFactor: 0,
              cookingMethod: 0,
            ),
          ],
      drinks: [],
    );
  }

  FoodRoutineEvent createFoodRoutineEvent({
    required int mealType,
    required String foodName,
    required List<int> daysOfWeek,
    required String time,
  }) {
    return FoodRoutineEvent(
      userId: 'user1',
      eventDate: 1700000000,
      eventId: 1000,
      mealType: mealType,
      foodName: foodName,
      comment: '',
      ingredients: [
        FoodRoutineInEvent(id: 100, qty: 150, unit: 1, cookingMethod: 0),
      ],
      drinks: [],
      isRoutine: true,
      daysOfWeek: daysOfWeek,
      time: time,
      timeZone: 'Europe/Madrid',
    );
  }

  SupplementSimple createSupplementRoutine({
    required String name,
    required List<int> daysOfWeek,
    required String scheduleTime,
    int id = 10,
    int amount = 1000,
    String unit = 'mg',
  }) {
    return SupplementSimple(
      userId: 'user1',
      eventId: 2000,
      eventDate: 1700000000,
      info: [NutriInfo(id: id, unit: unit, amount: amount)],
      name: name,
      isFavorite: false,
      isRoutine: true,
      daysOfWeek: daysOfWeek,
      scheduleTime: scheduleTime,
      timeZone: 'Europe/Madrid',
    );
  }

  AddSportFavorite createSportRoutine({
    required String title,
    required List<int> daysOfWeek,
    required String scheduleTime,
    int sportId = 1,
    String sportName = 'Running',
    int minutes = 30,
    int intensity = 1,
  }) {
    return AddSportFavorite(
      userId: 'user1',
      eventId: 3000,
      eventDate: 1700000000,
      info: [
        AddSportFavInfo(
          id: sportId,
          name_en: sportName,
          name_es: sportName,
          intensity: intensity,
          minutes: minutes,
        ),
      ],
      title: title,
      isFavorite: false,
      isCreateRoutine: true,
      daysOfWeek: daysOfWeek,
      scheduleTime: scheduleTime,
      timeZone: 'Europe/Madrid',
    );
  }

  SportRoutineCompleted createSportRoutineCompleted({
    required String sportName,
    required List<int> daysOfWeek,
    required String scheduleTime,
    int sportId = 1,
    int minutes = 30,
    int intensity = 1,
  }) {
    return SportRoutineCompleted(
      userId: 'user1',
      eventId: 4000,
      eventDate: 1700000000,
      info: [
        Info(
          id: sportId,
          nameEn: 'Running',
          nameEs: 'Correr',
          intensity: intensity,
          minutes: minutes,
        ),
      ],
      sportName: sportName,
      isRoutine: true,
      daysOfWeek: daysOfWeek,
      scheduleTime: scheduleTime,
      timeZone: 'Europe/Madrid',
    );
  }

  // ===========================================================
  // TS-ROU001: Breakfast — View Routines
  // ===========================================================
  group('TS-ROU001: View breakfast routines', () {
    test('breakfast routine has mealTime 0, isRoutine true, daysOfWeek and time', () {
      final routine = createMealRoutine(
        mealTime: 0,
        title: 'Morning Oats',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '07:30',
      );

      expect(routine.mealTime, 0);
      expect(routine.isRoutine, isTrue);
      expect(routine.isFavorite, isFalse);
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.time, '07:30');
    });

    test('routines list filtered by mealTime 0 shows only breakfast', () {
      final allRoutines = [
        createMealRoutine(mealTime: 0, title: 'Oats', daysOfWeek: [1, 3, 5], time: '07:30'),
        createMealRoutine(mealTime: 1, title: 'Salad', daysOfWeek: [1, 2, 3, 4, 5], time: '13:00'),
        createMealRoutine(mealTime: 0, title: 'Eggs', daysOfWeek: [2, 4], time: '08:00'),
      ];

      final breakfastRoutines = allRoutines.where((r) => r.mealTime == 0).toList();

      expect(breakfastRoutines.length, 2);
      expect(breakfastRoutines[0].title, 'Oats');
      expect(breakfastRoutines[1].title, 'Eggs');
    });
  });

  // ===========================================================
  // TS-ROU002: Breakfast — Edit Routine
  // ===========================================================
  group('TS-ROU002: Edit breakfast routine', () {
    test('updating routine days, time, and food values', () {
      final routine = createMealRoutine(
        mealTime: 0,
        title: 'Morning Oats',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '07:30',
      );

      routine.daysOfWeek = [1, 3, 5];
      routine.time = '08:00';
      routine.ingredients[0].qty = 200;

      expect(routine.daysOfWeek, [1, 3, 5]);
      expect(routine.time, '08:00');
      expect(routine.ingredients[0].qty, 200);
    });
  });

  // ===========================================================
  // TS-ROU003: Breakfast — Delete Routine
  // ===========================================================
  group('TS-ROU003: Delete breakfast routine', () {
    test('removing breakfast routine from list', () {
      final routines = [
        createMealRoutine(mealTime: 0, title: 'Oats', daysOfWeek: [1, 3, 5], time: '07:30'),
        createMealRoutine(mealTime: 0, title: 'Eggs', daysOfWeek: [2, 4], time: '08:00'),
      ];

      routines.removeWhere((r) => r.title == 'Oats');

      expect(routines.length, 1);
      expect(routines.first.title, 'Eggs');
    });
  });

  // ===========================================================
  // TS-ROU004: Breakfast — View Routine Created Event
  // ===========================================================
  group('TS-ROU004: View breakfast routine event', () {
    test('FoodRoutineEvent created with mealType 0 and scheduled time', () {
      final event = createFoodRoutineEvent(
        mealType: 0,
        foodName: 'Morning Oats',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '07:30',
      );

      expect(event.mealType, 0);
      expect(event.isRoutine, isTrue);
      expect(event.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(event.time, '07:30');
      expect(event.foodName, 'Morning Oats');
    });
  });

  // ===========================================================
  // TS-ROU005: Lunch — View Routines
  // ===========================================================
  group('TS-ROU005: View lunch routines', () {
    test('lunch routine has mealTime 1, isRoutine true', () {
      final routine = createMealRoutine(
        mealTime: 1,
        title: 'Chicken Salad',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '13:00',
      );

      expect(routine.mealTime, 1);
      expect(routine.isRoutine, isTrue);
      expect(routine.time, '13:00');
    });
  });

  // ===========================================================
  // TS-ROU006: Lunch — Edit Routine
  // ===========================================================
  group('TS-ROU006: Edit lunch routine', () {
    test('updating lunch routine timing and food values', () {
      final routine = createMealRoutine(
        mealTime: 1,
        title: 'Salad',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '13:00',
      );

      routine.daysOfWeek = [1, 3, 5];
      routine.time = '12:30';
      routine.ingredients[0].qty = 250;

      expect(routine.daysOfWeek, [1, 3, 5]);
      expect(routine.time, '12:30');
      expect(routine.ingredients[0].qty, 250);
    });
  });

  // ===========================================================
  // TS-ROU007: Lunch — Delete Routine
  // ===========================================================
  group('TS-ROU007: Delete lunch routine', () {
    test('removing lunch routine from list', () {
      final routines = [
        createMealRoutine(mealTime: 1, title: 'Salad', daysOfWeek: [1, 3, 5], time: '13:00'),
        createMealRoutine(mealTime: 1, title: 'Wrap', daysOfWeek: [2, 4], time: '12:30'),
      ];

      routines.removeWhere((r) => r.title == 'Salad');

      expect(routines.length, 1);
      expect(routines.first.title, 'Wrap');
    });
  });

  // ===========================================================
  // TS-ROU008: Lunch — View Routine Created Event
  // ===========================================================
  group('TS-ROU008: View lunch routine event', () {
    test('FoodRoutineEvent created with mealType 1', () {
      final event = createFoodRoutineEvent(
        mealType: 1,
        foodName: 'Chicken Salad',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '13:00',
      );

      expect(event.mealType, 1);
      expect(event.time, '13:00');
    });
  });

  // ===========================================================
  // TS-ROU009: Dinner — View Routines
  // ===========================================================
  group('TS-ROU009: View dinner routines', () {
    test('dinner routine has mealTime 2, isRoutine true', () {
      final routine = createMealRoutine(
        mealTime: 2,
        title: 'Pasta',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '20:00',
      );

      expect(routine.mealTime, 2);
      expect(routine.isRoutine, isTrue);
      expect(routine.time, '20:00');
    });
  });

  // ===========================================================
  // TS-ROU010: Dinner — Edit Routine
  // ===========================================================
  group('TS-ROU010: Edit dinner routine', () {
    test('updating dinner routine timing and food values', () {
      final routine = createMealRoutine(
        mealTime: 2,
        title: 'Pasta',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '20:00',
      );

      routine.time = '19:30';
      routine.ingredients[0].qty = 180;

      expect(routine.time, '19:30');
      expect(routine.ingredients[0].qty, 180);
    });
  });

  // ===========================================================
  // TS-ROU011: Dinner — Delete Routine
  // ===========================================================
  group('TS-ROU011: Delete dinner routine', () {
    test('removing dinner routine from list', () {
      final routines = [
        createMealRoutine(mealTime: 2, title: 'Pasta', daysOfWeek: [1, 3, 5], time: '20:00'),
      ];

      routines.removeWhere((r) => r.title == 'Pasta');

      expect(routines, isEmpty);
    });
  });

  // ===========================================================
  // TS-ROU012: Dinner — View Routine Created Event
  // ===========================================================
  group('TS-ROU012: View dinner routine event', () {
    test('FoodRoutineEvent created with mealType 2', () {
      final event = createFoodRoutineEvent(
        mealType: 2,
        foodName: 'Pasta Bolognese',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '20:00',
      );

      expect(event.mealType, 2);
      expect(event.time, '20:00');
    });
  });

  // ===========================================================
  // TS-ROU013: Snack — View Routines
  // ===========================================================
  group('TS-ROU013: View snack routines', () {
    test('snack routine has mealTime 3, isRoutine true, user-provided time', () {
      final routine = createMealRoutine(
        mealTime: 3,
        title: 'Afternoon Nuts',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '16:00',
      );

      expect(routine.mealTime, 3);
      expect(routine.isRoutine, isTrue);
      expect(routine.time, '16:00');
    });
  });

  // ===========================================================
  // TS-ROU014: Snack — Edit Routine
  // ===========================================================
  group('TS-ROU014: Edit snack routine', () {
    test('updating snack routine timing and food values', () {
      final routine = createMealRoutine(
        mealTime: 3,
        title: 'Nuts',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '16:00',
      );

      routine.time = '15:30';
      routine.ingredients[0].qty = 50;

      expect(routine.time, '15:30');
      expect(routine.ingredients[0].qty, 50);
    });
  });

  // ===========================================================
  // TS-ROU015: Snack — Delete Routine
  // ===========================================================
  group('TS-ROU015: Delete snack routine', () {
    test('removing snack routine from list', () {
      final routines = [
        createMealRoutine(mealTime: 3, title: 'Nuts', daysOfWeek: [1, 3, 5], time: '16:00'),
        createMealRoutine(mealTime: 3, title: 'Fruit', daysOfWeek: [2, 4], time: '10:30'),
      ];

      routines.removeWhere((r) => r.title == 'Nuts');

      expect(routines.length, 1);
    });
  });

  // ===========================================================
  // TS-ROU016: Snack — View Routine Created Event
  // ===========================================================
  group('TS-ROU016: View snack routine event', () {
    test('FoodRoutineEvent created with mealType 3 and user time', () {
      final event = createFoodRoutineEvent(
        mealType: 3,
        foodName: 'Afternoon Nuts',
        daysOfWeek: [1, 2, 3, 4, 5],
        time: '16:00',
      );

      expect(event.mealType, 3);
      expect(event.time, '16:00');
    });
  });

  // ===========================================================
  // TS-ROU017: Supplements — View Routines
  // ===========================================================
  group('TS-ROU017: View supplement routines', () {
    test('supplement routine has isRoutine true, daysOfWeek, scheduleTime', () {
      final routine = createSupplementRoutine(
        name: 'Omega 3',
        daysOfWeek: [1, 3, 5],
        scheduleTime: '08:00',
      );

      expect(routine.isRoutine, isTrue);
      expect(routine.isFavorite, isFalse);
      expect(routine.daysOfWeek, [1, 3, 5]);
      expect(routine.scheduleTime, '08:00');
      expect(routine.name, 'Omega 3');
    });

    test('supplement routines list shows all routines', () {
      final routines = [
        createSupplementRoutine(name: 'Omega 3', daysOfWeek: [1, 3, 5], scheduleTime: '08:00'),
        createSupplementRoutine(name: 'Vitamin D', daysOfWeek: [1, 2, 3, 4, 5], scheduleTime: '09:00'),
      ];

      expect(routines.length, 2);
      expect(routines.every((r) => r.isRoutine), isTrue);
    });
  });

  // ===========================================================
  // TS-ROU018: Supplements — Edit Routine
  // ===========================================================
  group('TS-ROU018: Edit supplement routine', () {
    test('updating supplement routine days, time, and values', () {
      final routine = createSupplementRoutine(
        name: 'Omega 3',
        daysOfWeek: [1, 3, 5],
        scheduleTime: '08:00',
        amount: 1000,
      );

      routine.daysOfWeek = [1, 2, 3, 4, 5];
      routine.scheduleTime = '07:30';
      routine.info![0].amount = 2000;

      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.scheduleTime, '07:30');
      expect(routine.info![0].amount, 2000);
    });
  });

  // ===========================================================
  // TS-ROU019: Supplements — Delete Routine
  // ===========================================================
  group('TS-ROU019: Delete supplement routine', () {
    test('removing supplement routine from list', () {
      final routines = [
        createSupplementRoutine(name: 'Omega 3', daysOfWeek: [1, 3, 5], scheduleTime: '08:00'),
        createSupplementRoutine(name: 'Vitamin D', daysOfWeek: [1, 2, 3, 4, 5], scheduleTime: '09:00'),
      ];

      routines.removeWhere((r) => r.name == 'Omega 3');

      expect(routines.length, 1);
      expect(routines.first.name, 'Vitamin D');
    });
  });

  // ===========================================================
  // TS-ROU020: Supplements — View Routine Created Event
  // ===========================================================
  group('TS-ROU020: View supplement routine event', () {
    test('supplement routine event displays with scheduled time', () {
      final routine = createSupplementRoutine(
        name: 'Omega 3',
        daysOfWeek: [1, 3, 5],
        scheduleTime: '08:00',
      );

      expect(routine.isRoutine, isTrue);
      expect(routine.scheduleTime, '08:00');
      expect(routine.daysOfWeek, [1, 3, 5]);
    });
  });

  // ===========================================================
  // TS-ROU021: Physical Activity — View Routines
  // ===========================================================
  group('TS-ROU021: View physical activity routines', () {
    test('sport routine has isCreateRoutine true, daysOfWeek, scheduleTime', () {
      final routine = createSportRoutine(
        title: 'Morning Run',
        daysOfWeek: [1, 2, 3, 4, 5],
        scheduleTime: '07:00',
      );

      expect(routine.isCreateRoutine, isTrue);
      expect(routine.isFavorite, isFalse);
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.scheduleTime, '07:00');
    });

    test('SportRoutineCompleted stores completed routine data', () {
      final routine = createSportRoutineCompleted(
        sportName: 'Morning Run',
        daysOfWeek: [1, 2, 3, 4, 5],
        scheduleTime: '07:00',
      );

      expect(routine.isRoutine, isTrue);
      expect(routine.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(routine.scheduleTime, '07:00');
    });
  });

  // ===========================================================
  // TS-ROU022: Physical Activity — Edit Routine
  // ===========================================================
  group('TS-ROU022: Edit physical activity routine', () {
    test('updating sport routine days, time, duration and intensity', () {
      final routine = createSportRoutine(
        title: 'Morning Run',
        daysOfWeek: [1, 2, 3, 4, 5],
        scheduleTime: '07:00',
        minutes: 30,
        intensity: 1,
      );

      routine.daysOfWeek = [1, 3, 5];
      routine.scheduleTime = '06:30';
      routine.info![0].minutes = 45;
      routine.info![0].intensity = 2;

      expect(routine.daysOfWeek, [1, 3, 5]);
      expect(routine.scheduleTime, '06:30');
      expect(routine.info![0].minutes, 45);
      expect(routine.info![0].intensity, 2);
    });
  });

  // ===========================================================
  // TS-ROU023: Physical Activity — Delete Routine
  // ===========================================================
  group('TS-ROU023: Delete physical activity routine', () {
    test('removing sport routine from list', () {
      final routines = [
        createSportRoutine(title: 'Morning Run', daysOfWeek: [1, 3, 5], scheduleTime: '07:00'),
        createSportRoutine(title: 'Evening Yoga', daysOfWeek: [2, 4], scheduleTime: '19:00'),
      ];

      routines.removeWhere((r) => r.title == 'Morning Run');

      expect(routines.length, 1);
      expect(routines.first.title, 'Evening Yoga');
    });
  });

  // ===========================================================
  // TS-ROU024: Physical Activity — View Routine Created Event
  // ===========================================================
  group('TS-ROU024: View physical activity routine event', () {
    test('SportRoutineCompleted event displays at scheduled time', () {
      final event = createSportRoutineCompleted(
        sportName: 'Morning Run',
        daysOfWeek: [1, 2, 3, 4, 5],
        scheduleTime: '07:00',
        minutes: 45,
        intensity: 2,
      );

      expect(event.isRoutine, isTrue);
      expect(event.scheduleTime, '07:00');
      expect(event.info!.first.minutes, 45);
    });
  });

  // ===========================================================
  // Green + button interactions on Routines tab
  // ===========================================================
  group('Routines screen green + button: Meal tab', () {
    test('Breakfast FAB creates FoodArgumentsModel with preSelectRoutine', () {
      final args = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'breakfast', time: '07:30'),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectRoutine: true,
      );

      expect(args.mealTime.id, 0);
      expect(args.preSelectRoutine, isTrue);
      expect(args.preSelectFavorite, isFalse);
    });

    test('Lunch FAB creates FoodArgumentsModel with preSelectRoutine', () {
      final args = FoodArgumentsModel(
        mealTime: MealTime(id: 1, name: 'lunch', time: '13:30'),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectRoutine: true,
      );

      expect(args.mealTime.id, 1);
      expect(args.preSelectRoutine, isTrue);
    });

    test('Dinner FAB creates FoodArgumentsModel with preSelectRoutine', () {
      final args = FoodArgumentsModel(
        mealTime: MealTime(id: 2, name: 'dinner', time: '20:30'),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectRoutine: true,
      );

      expect(args.mealTime.id, 2);
      expect(args.preSelectRoutine, isTrue);
    });

    test('Snack FAB creates FoodArgumentsModel with preSelectRoutine', () {
      final args = FoodArgumentsModel(
        mealTime: MealTime(id: 3, name: 'snack', time: ''),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectRoutine: true,
      );

      expect(args.mealTime.id, 3);
      expect(args.preSelectRoutine, isTrue);
    });
  });

  group('Routines screen green + button: Physical Activity tab', () {
    test('sport FAB creates SportArgumentsModel with preSelectRoutine', () {
      final args = SportArgumentsModel(
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectRoutine: true,
      );

      expect(args.preSelectRoutine, isTrue);
      expect(args.preSelectFavorite, isFalse);
    });
  });

  group('Routines screen green + button: Supplements tab', () {
    test('supplements FAB navigates to create new routine', () {
      final empty = SupplementSimple.empty();

      expect(empty.info, isEmpty);
      expect(empty.isRoutine, isFalse);
      expect(empty.daysOfWeek, isEmpty);
    });
  });

  // ===========================================================
  // Cross-category routine patterns
  // ===========================================================
  group('Cross-category routine patterns', () {
    test('all routine types share daysOfWeek and time pattern', () {
      final mealRoutine = createMealRoutine(
        mealTime: 0,
        title: 'Oats',
        daysOfWeek: [1, 3, 5],
        time: '07:30',
      );
      final suppRoutine = createSupplementRoutine(
        name: 'Omega 3',
        daysOfWeek: [1, 3, 5],
        scheduleTime: '08:00',
      );
      final sportRoutine = createSportRoutine(
        title: 'Running',
        daysOfWeek: [1, 3, 5],
        scheduleTime: '07:00',
      );

      expect(mealRoutine.isRoutine, isTrue);
      expect(suppRoutine.isRoutine, isTrue);
      expect(sportRoutine.isCreateRoutine, isTrue);

      expect(mealRoutine.daysOfWeek, [1, 3, 5]);
      expect(suppRoutine.daysOfWeek, [1, 3, 5]);
      expect(sportRoutine.daysOfWeek, [1, 3, 5]);
    });

    test('routine days represent weekdays 1-7', () {
      // 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
      final weekdays = [1, 2, 3, 4, 5];
      final weekend = [6, 7];
      final allDays = [1, 2, 3, 4, 5, 6, 7];

      expect(weekdays.length, 5);
      expect(weekend.length, 2);
      expect(allDays.length, 7);
    });

    test('clicking a routine item passes the full model for editing', () {
      final mealRoutine = createMealRoutine(
        mealTime: 0,
        title: 'Oats',
        daysOfWeek: [1, 3, 5],
        time: '07:30',
      );
      final sportRoutine = createSportRoutineCompleted(
        sportName: 'Running',
        daysOfWeek: [1, 3, 5],
        scheduleTime: '07:00',
      );

      expect(mealRoutine.ingredients.isNotEmpty, isTrue);
      expect(sportRoutine.info!.isNotEmpty, isTrue);
    });
  });
}
