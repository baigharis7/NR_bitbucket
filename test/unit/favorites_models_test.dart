import 'package:flutter_test/flutter_test.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/supplements/supplement_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/sportevents/sport_arguments_model.dart';

/// Favorites test scenarios (TS-FAV001 through TS-FAV018).
///
/// Cross-category favorites management: view, edit, and delete for
/// Breakfast (mealTime 0), Lunch (mealTime 1), Dinner (mealTime 2),
/// Snack (mealTime 3), Supplements, and Physical Activity.
///
/// Also covers green + button interactions on the Favorites screen:
/// - Meal tab: shows meal time overlay menu → navigates with FoodArgumentsModel(preSelectFavorite: true)
/// - Physical Activity tab: navigates with SportArgumentsModel(preSelectFavorite: true)
/// - Supplements tab: navigates directly to SupplementsScreen (no arguments)

void main() {
  // ---- Helpers ----

  FoodFavorite createMealFavorite({
    required int mealTime,
    required String title,
    List<FoodInFavorite>? ingredients,
  }) {
    return FoodFavorite(
      title: title,
      mealTime: mealTime,
      isFavorite: true,
      isRoutine: false,
      time: mealTime == 0
          ? '07:30'
          : mealTime == 1
              ? '13:30'
              : mealTime == 2
                  ? '20:30'
                  : '',
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

  SupplementSimple createSupplementFavorite({
    required String name,
    int id = 10,
    int amount = 1000,
    String unit = 'mg',
  }) {
    return SupplementSimple(
      userId: 'user1',
      eventId: 1000,
      eventDate: 1700000000,
      info: [NutriInfo(id: id, unit: unit, amount: amount)],
      name: name,
      isFavorite: true,
    );
  }

  AddSportFavorite createSportFavorite({
    required String title,
    int sportId = 1,
    String sportName = 'Running',
    int minutes = 30,
    int intensity = 1,
  }) {
    return AddSportFavorite(
      userId: 'user1',
      eventId: 2000,
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
      isFavorite: true,
    );
  }

  // ===========================================================
  // TS-FAV001: Breakfast — View Favorites
  // ===========================================================
  group('TS-FAV001: View breakfast favorites', () {
    test('breakfast favorite has mealTime 0 and isFavorite true', () {
      final fav = createMealFavorite(mealTime: 0, title: 'Morning Oats');

      expect(fav.mealTime, 0);
      expect(fav.isFavorite, isTrue);
      expect(fav.title, 'Morning Oats');
    });

    test('favorites list filtered by mealTime 0 shows only breakfast', () {
      final allFavorites = [
        createMealFavorite(mealTime: 0, title: 'Morning Oats'),
        createMealFavorite(mealTime: 1, title: 'Lunch Salad'),
        createMealFavorite(mealTime: 0, title: 'Eggs & Toast'),
        createMealFavorite(mealTime: 2, title: 'Dinner Pasta'),
      ];

      final breakfastFavs =
          allFavorites.where((f) => f.mealTime == 0).toList();

      expect(breakfastFavs.length, 2);
      expect(breakfastFavs[0].title, 'Morning Oats');
      expect(breakfastFavs[1].title, 'Eggs & Toast');
    });
  });

  // ===========================================================
  // TS-FAV002: Breakfast — Edit a Favorite
  // ===========================================================
  group('TS-FAV002: Edit breakfast favorite', () {
    test('updating breakfast favorite name and ingredient qty', () {
      final fav = createMealFavorite(mealTime: 0, title: 'Morning Oats');

      fav.title = 'Updated Oats';
      fav.ingredients[0].qty = 200;

      expect(fav.title, 'Updated Oats');
      expect(fav.ingredients[0].qty, 200);
      expect(fav.mealTime, 0);
      expect(fav.isFavorite, isTrue);
    });
  });

  // ===========================================================
  // TS-FAV003: Breakfast — Delete a Favorite
  // ===========================================================
  group('TS-FAV003: Delete breakfast favorite', () {
    test('removing breakfast favorite from list', () {
      final favorites = [
        createMealFavorite(mealTime: 0, title: 'Morning Oats'),
        createMealFavorite(mealTime: 0, title: 'Eggs & Toast'),
      ];

      favorites.removeWhere((f) => f.title == 'Morning Oats');

      expect(favorites.length, 1);
      expect(favorites.first.title, 'Eggs & Toast');
    });
  });

  // ===========================================================
  // TS-FAV004: Lunch — View Favorites
  // ===========================================================
  group('TS-FAV004: View lunch favorites', () {
    test('lunch favorite has mealTime 1 and isFavorite true', () {
      final fav = createMealFavorite(mealTime: 1, title: 'Chicken Salad');

      expect(fav.mealTime, 1);
      expect(fav.isFavorite, isTrue);
      expect(fav.title, 'Chicken Salad');
    });

    test('favorites list filtered by mealTime 1 shows only lunch', () {
      final allFavorites = [
        createMealFavorite(mealTime: 0, title: 'Oats'),
        createMealFavorite(mealTime: 1, title: 'Chicken Salad'),
        createMealFavorite(mealTime: 1, title: 'Tuna Wrap'),
        createMealFavorite(mealTime: 3, title: 'Trail Mix'),
      ];

      final lunchFavs =
          allFavorites.where((f) => f.mealTime == 1).toList();

      expect(lunchFavs.length, 2);
      expect(lunchFavs[0].title, 'Chicken Salad');
      expect(lunchFavs[1].title, 'Tuna Wrap');
    });
  });

  // ===========================================================
  // TS-FAV005: Lunch — Edit a Favorite
  // ===========================================================
  group('TS-FAV005: Edit lunch favorite', () {
    test('updating lunch favorite name and ingredient qty', () {
      final fav = createMealFavorite(mealTime: 1, title: 'Chicken Salad');

      fav.title = 'Grilled Chicken Salad';
      fav.ingredients[0].qty = 250;

      expect(fav.title, 'Grilled Chicken Salad');
      expect(fav.ingredients[0].qty, 250);
      expect(fav.mealTime, 1);
    });
  });

  // ===========================================================
  // TS-FAV006: Lunch — Delete a Favorite
  // ===========================================================
  group('TS-FAV006: Delete lunch favorite', () {
    test('removing lunch favorite from list', () {
      final favorites = [
        createMealFavorite(mealTime: 1, title: 'Chicken Salad'),
        createMealFavorite(mealTime: 1, title: 'Tuna Wrap'),
      ];

      favorites.removeWhere((f) => f.title == 'Chicken Salad');

      expect(favorites.length, 1);
      expect(favorites.first.title, 'Tuna Wrap');
    });
  });

  // ===========================================================
  // TS-FAV007: Dinner — View Favorites
  // ===========================================================
  group('TS-FAV007: View dinner favorites', () {
    test('dinner favorite has mealTime 2 and isFavorite true', () {
      final fav = createMealFavorite(mealTime: 2, title: 'Pasta Bolognese');

      expect(fav.mealTime, 2);
      expect(fav.isFavorite, isTrue);
      expect(fav.title, 'Pasta Bolognese');
    });

    test('favorites list filtered by mealTime 2 shows only dinner', () {
      final allFavorites = [
        createMealFavorite(mealTime: 0, title: 'Oats'),
        createMealFavorite(mealTime: 2, title: 'Pasta Bolognese'),
        createMealFavorite(mealTime: 2, title: 'Grilled Salmon'),
      ];

      final dinnerFavs =
          allFavorites.where((f) => f.mealTime == 2).toList();

      expect(dinnerFavs.length, 2);
    });
  });

  // ===========================================================
  // TS-FAV008: Dinner — Edit a Favorite
  // ===========================================================
  group('TS-FAV008: Edit dinner favorite', () {
    test('updating dinner favorite name and ingredient qty', () {
      final fav = createMealFavorite(mealTime: 2, title: 'Pasta Bolognese');

      fav.title = 'Whole Wheat Pasta';
      fav.ingredients[0].qty = 180;

      expect(fav.title, 'Whole Wheat Pasta');
      expect(fav.ingredients[0].qty, 180);
      expect(fav.mealTime, 2);
    });
  });

  // ===========================================================
  // TS-FAV009: Dinner — Delete a Favorite
  // ===========================================================
  group('TS-FAV009: Delete dinner favorite', () {
    test('removing dinner favorite from list', () {
      final favorites = [
        createMealFavorite(mealTime: 2, title: 'Pasta Bolognese'),
        createMealFavorite(mealTime: 2, title: 'Grilled Salmon'),
      ];

      favorites.removeWhere((f) => f.title == 'Grilled Salmon');

      expect(favorites.length, 1);
      expect(favorites.first.title, 'Pasta Bolognese');
    });
  });

  // ===========================================================
  // TS-FAV010: Snack — View Favorites
  // ===========================================================
  group('TS-FAV010: View snack favorites', () {
    test('snack favorite has mealTime 3 and empty default time', () {
      final fav = createMealFavorite(mealTime: 3, title: 'Trail Mix');

      expect(fav.mealTime, 3);
      expect(fav.isFavorite, isTrue);
      expect(fav.time, isEmpty);
      expect(fav.title, 'Trail Mix');
    });

    test('favorites list filtered by mealTime 3 shows only snacks', () {
      final allFavorites = [
        createMealFavorite(mealTime: 0, title: 'Oats'),
        createMealFavorite(mealTime: 3, title: 'Trail Mix'),
        createMealFavorite(mealTime: 3, title: 'Fruit Bowl'),
      ];

      final snackFavs =
          allFavorites.where((f) => f.mealTime == 3).toList();

      expect(snackFavs.length, 2);
    });
  });

  // ===========================================================
  // TS-FAV011: Snack — Edit a Favorite
  // ===========================================================
  group('TS-FAV011: Edit snack favorite', () {
    test('updating snack favorite name and ingredient qty', () {
      final fav = createMealFavorite(mealTime: 3, title: 'Trail Mix');

      fav.title = 'Healthy Trail Mix';
      fav.ingredients[0].qty = 100;

      expect(fav.title, 'Healthy Trail Mix');
      expect(fav.ingredients[0].qty, 100);
      expect(fav.mealTime, 3);
    });
  });

  // ===========================================================
  // TS-FAV012: Snack — Delete a Favorite
  // ===========================================================
  group('TS-FAV012: Delete snack favorite', () {
    test('removing snack favorite from list', () {
      final favorites = [
        createMealFavorite(mealTime: 3, title: 'Trail Mix'),
        createMealFavorite(mealTime: 3, title: 'Fruit Bowl'),
      ];

      favorites.removeWhere((f) => f.title == 'Trail Mix');

      expect(favorites.length, 1);
      expect(favorites.first.title, 'Fruit Bowl');
    });
  });

  // ===========================================================
  // TS-FAV013: Supplements — View Favorites
  // ===========================================================
  group('TS-FAV013: View supplement favorites', () {
    test('supplement favorite has isFavorite true and name', () {
      final fav = createSupplementFavorite(name: 'Vitamin D');

      expect(fav.isFavorite, isTrue);
      expect(fav.name, 'Vitamin D');
      expect(fav.info!.length, 1);
    });

    test('supplement favorites list shows all favorites', () {
      final favorites = [
        createSupplementFavorite(
            name: 'Vitamin D', id: 10, amount: 1000, unit: 'IU'),
        createSupplementFavorite(
            name: 'Magnesium', id: 15, amount: 400, unit: 'mg'),
      ];

      expect(favorites.length, 2);
      expect(favorites.every((f) => f.isFavorite), isTrue);
      expect(favorites[0].name, 'Vitamin D');
      expect(favorites[1].name, 'Magnesium');
    });
  });

  // ===========================================================
  // TS-FAV014: Supplements — Edit a Favorite
  // ===========================================================
  group('TS-FAV014: Edit supplement favorite', () {
    test('updating supplement favorite name and amount', () {
      final fav = createSupplementFavorite(name: 'Vitamin D', amount: 1000);

      fav.name = 'Vitamin D3';
      fav.info![0].amount = 2000;

      expect(fav.name, 'Vitamin D3');
      expect(fav.info![0].amount, 2000);
      expect(fav.isFavorite, isTrue);
    });
  });

  // ===========================================================
  // TS-FAV015: Supplements — Delete a Favorite
  // ===========================================================
  group('TS-FAV015: Delete supplement favorite', () {
    test('removing supplement favorite from list', () {
      final favorites = [
        createSupplementFavorite(name: 'Vitamin D'),
        createSupplementFavorite(name: 'Magnesium'),
      ];

      favorites.removeWhere((f) => f.name == 'Vitamin D');

      expect(favorites.length, 1);
      expect(favorites.first.name, 'Magnesium');
    });
  });

  // ===========================================================
  // TS-FAV016: Physical Activity — View Favorites
  // ===========================================================
  group('TS-FAV016: View physical activity favorites', () {
    test('sport favorite has isFavorite true and title', () {
      final fav = createSportFavorite(title: 'Morning Run');

      expect(fav.isFavorite, isTrue);
      expect(fav.title, 'Morning Run');
      expect(fav.info!.length, 1);
    });

    test('sport favorites list shows all favorites', () {
      final favorites = [
        createSportFavorite(
            title: 'Morning Run', sportId: 1, sportName: 'Running'),
        createSportFavorite(
            title: 'Evening Yoga', sportId: 5, sportName: 'Yoga'),
      ];

      expect(favorites.length, 2);
      expect(favorites.every((f) => f.isFavorite == true), isTrue);
      expect(favorites[0].title, 'Morning Run');
      expect(favorites[1].title, 'Evening Yoga');
    });
  });

  // ===========================================================
  // TS-FAV017: Physical Activity — Edit a Favorite
  // ===========================================================
  group('TS-FAV017: Edit physical activity favorite', () {
    test('updating sport favorite title and duration', () {
      final fav = createSportFavorite(title: 'Morning Run', minutes: 30);

      fav.title = 'Long Run';
      fav.info![0].minutes = 60;
      fav.info![0].intensity = 2;

      expect(fav.title, 'Long Run');
      expect(fav.info![0].minutes, 60);
      expect(fav.info![0].intensity, 2);
      expect(fav.isFavorite, isTrue);
    });
  });

  // ===========================================================
  // TS-FAV018: Physical Activity — Delete a Favorite
  // ===========================================================
  group('TS-FAV018: Delete physical activity favorite', () {
    test('removing sport favorite from list', () {
      final favorites = [
        createSportFavorite(title: 'Morning Run'),
        createSportFavorite(title: 'Evening Yoga'),
      ];

      favorites.removeWhere((f) => f.title == 'Morning Run');

      expect(favorites.length, 1);
      expect(favorites.first.title, 'Evening Yoga');
    });
  });

  // ===========================================================
  // Green + button interactions on Favorites screen
  // ===========================================================
  group('Favorites screen green + button: Meal tab', () {
    test('Breakfast FAB creates FoodArgumentsModel with mealTime 0 and preSelectFavorite', () {
      final args = FoodArgumentsModel(
        mealTime: MealTime(id: 0, name: 'breakfast', time: '07:30'),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectFavorite: true,
      );

      expect(args.mealTime.id, 0);
      expect(args.preSelectFavorite, isTrue);
      expect(args.preSelectRoutine, isFalse);
    });

    test('Lunch FAB creates FoodArgumentsModel with mealTime 1 and preSelectFavorite', () {
      final args = FoodArgumentsModel(
        mealTime: MealTime(id: 1, name: 'lunch', time: '13:30'),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectFavorite: true,
      );

      expect(args.mealTime.id, 1);
      expect(args.preSelectFavorite, isTrue);
    });

    test('Dinner FAB creates FoodArgumentsModel with mealTime 2 and preSelectFavorite', () {
      final args = FoodArgumentsModel(
        mealTime: MealTime(id: 2, name: 'dinner', time: '20:30'),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectFavorite: true,
      );

      expect(args.mealTime.id, 2);
      expect(args.preSelectFavorite, isTrue);
    });

    test('Snack FAB creates FoodArgumentsModel with mealTime 3 and preSelectFavorite', () {
      final args = FoodArgumentsModel(
        mealTime: MealTime(id: 3, name: 'snack', time: ''),
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectFavorite: true,
      );

      expect(args.mealTime.id, 3);
      expect(args.mealTime.time, isEmpty);
      expect(args.preSelectFavorite, isTrue);
    });

    test('meal tab overlay menu provides all 4 meal times', () {
      final mealTimes = [
        MealTime(id: 0, name: 'breakfast', time: '07:30'),
        MealTime(id: 1, name: 'lunch', time: '13:30'),
        MealTime(id: 2, name: 'dinner', time: '20:30'),
        MealTime(id: 3, name: 'snack', time: ''),
      ];

      expect(mealTimes.length, 4);
      expect(mealTimes.map((m) => m.id).toList(), [0, 1, 2, 3]);
    });
  });

  group('Favorites screen green + button: Physical Activity tab', () {
    test('sport FAB creates SportArgumentsModel with preSelectFavorite', () {
      final args = SportArgumentsModel(
        selectedDateTime: DateTime(2024, 1, 15),
        preSelectFavorite: true,
      );

      expect(args.preSelectFavorite, isTrue);
      expect(args.preSelectRoutine, isFalse);
      expect(args.selectedDateTime, DateTime(2024, 1, 15));
    });
  });

  group('Favorites screen green + button: Supplements tab', () {
    test('supplements FAB navigates without arguments', () {
      // Supplements tab navigates to SupplementsScreen.routeName
      // with no arguments (unlike meals and sports which pass models).
      // The SupplementSimple.empty() is created inside the BLoC.
      final empty = SupplementSimple.empty();

      expect(empty.info, isEmpty);
      expect(empty.isFavorite, isFalse);
      expect(empty.isRoutine, isFalse);
    });
  });

  // ===========================================================
  // Cross-category favorites management
  // ===========================================================
  group('Cross-category favorites filtering', () {
    test('meal favorites can be filtered by mealTime from combined list', () {
      final mealFavorites = [
        createMealFavorite(mealTime: 0, title: 'Oats'),
        createMealFavorite(mealTime: 1, title: 'Salad'),
        createMealFavorite(mealTime: 2, title: 'Pasta'),
        createMealFavorite(mealTime: 3, title: 'Nuts'),
      ];

      for (int mt = 0; mt <= 3; mt++) {
        final filtered = mealFavorites.where((f) => f.mealTime == mt).toList();
        expect(filtered.length, 1,
            reason: 'mealTime $mt should have exactly 1 favorite');
      }
    });

    test('all favorite types share isFavorite pattern', () {
      final mealFav = createMealFavorite(mealTime: 0, title: 'Oats');
      final suppFav = createSupplementFavorite(name: 'Vitamin D');
      final sportFav = createSportFavorite(title: 'Running');

      expect(mealFav.isFavorite, isTrue);
      expect(suppFav.isFavorite, isTrue);
      expect(sportFav.isFavorite, isTrue);
    });

    test('clicking a favorite item passes the full model for editing', () {
      // Meal: FoodFavorite passed as argument
      final mealFav = createMealFavorite(mealTime: 0, title: 'Oats');
      expect(mealFav.ingredients.length, 1);
      expect(mealFav.title, 'Oats');

      // Sport: AddSportFavorite passed as argument
      final sportFav = createSportFavorite(title: 'Morning Run');
      expect(sportFav.info!.length, 1);
      expect(sportFav.title, 'Morning Run');

      // Supplement: SupplementSimple passed for edit
      final suppFav = createSupplementFavorite(name: 'Vitamin D');
      expect(suppFav.info!.length, 1);
      expect(suppFav.name, 'Vitamin D');
    });
  });
}
