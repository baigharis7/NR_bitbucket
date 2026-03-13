import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_recent_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/foodevents/get_week_food_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_user_exclusions_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/save_profile_entity_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipes_for_foods_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/recommendations/get_recommendation_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/common/simple_item.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/recommendation_computation_service.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_actions.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';

// --- Mocktail mocks (no code generation needed) ---
class _MockGetRecommendationInteractor extends Mock implements GetRecommendationInteractor {}
class _MockGetUserIdInteractor extends Mock implements GetUserIdInteractor {}
class _MockGetMasterFileInteractor extends Mock implements GetMasterFileInteractor {}
class _MockIsNecessaryToShowExplainingCardInteractor extends Mock implements IsNecessaryToShowExplainingCardInteractor {}
class _MockSaveExplainingCardInteractionInteractor extends Mock implements SaveExplainingCardInteractionInteractor {}
class _MockGetRecipesForFoodsInteractor extends Mock implements GetRecipesForFoodsInteractor {}
class _MockGetUserExclusionsInteractor extends Mock implements GetUserExclusionsInteractor {}
class _MockGetProfileInteractor extends Mock implements GetProfileInteractor {}
class _MockSaveProfileInteractor extends Mock implements SaveProfileInteractor {}
class _MockRecommendationComputationService extends Mock implements RecommendationComputationService {}
class _MockGetWeekFoodEventsInteractor extends Mock implements GetWeekFoodEventsInteractor {}
class _MockGetRecentFoodEventsInteractor extends Mock implements GetRecentFoodEventsInteractor {}
class _MockGetFoodFavoritesInteractor extends Mock implements GetFoodFavoritesInteractor {}

/// Helper to build a RecommendationsGeneralBloc with all required mocks.
RecommendationsGeneralBloc _buildBloc({
  GetWeekFoodEventsInteractor? weekFoodEventsInteractor,
  GetRecentFoodEventsInteractor? recentFoodEventsInteractor,
  GetFoodFavoritesInteractor? foodFavoritesInteractor,
}) {
  return RecommendationsGeneralBloc(
    getRecommendationInteractor: _MockGetRecommendationInteractor(),
    getUserIdInteractor: _MockGetUserIdInteractor(),
    getMasterFileInteractor: _MockGetMasterFileInteractor(),
    isNecessaryToShowExplainingCardInteractor: _MockIsNecessaryToShowExplainingCardInteractor(),
    saveExplainingCardInteractionInteractor: _MockSaveExplainingCardInteractionInteractor(),
    getRecipesForFoodsInteractor: _MockGetRecipesForFoodsInteractor(),
    getUserExclusionsInteractor: _MockGetUserExclusionsInteractor(),
    getProfileInteractor: _MockGetProfileInteractor(),
    saveProfileInteractor: _MockSaveProfileInteractor(),
    recommendationComputationService: _MockRecommendationComputationService(),
    getWeekFoodEventsInteractor: weekFoodEventsInteractor ?? _MockGetWeekFoodEventsInteractor(),
    getRecentFoodEventsInteractor: recentFoodEventsInteractor ?? _MockGetRecentFoodEventsInteractor(),
    getFoodFavoritesInteractor: foodFavoritesInteractor ?? _MockGetFoodFavoritesInteractor(),
  );
}

void main() {
  // ---------------------------------------------------------------
  // Test data factories
  // ---------------------------------------------------------------
  RecommendationGroup _group({required int id, required List<String> groups, String en = '', String es = ''}) {
    return RecommendationGroup(id: id, groups: groups, size: 5, en: en, es: es);
  }

  FoodItemMaster _food({required int id, String? en, String? group}) {
    return FoodItemMaster(id: id, en: en ?? 'Food $id', es: 'Comida $id', group: group);
  }

  RecommendationFoodInfo _foodInfo(FoodItemMaster food) {
    return RecommendationFoodInfo(foodItemMaster: food, foodNutrients: []);
  }

  UsualFoodsItem _usualItem(FoodItemMaster food, {List<RecommendationFoodInfo>? altHealthy, List<RecommendationFoodInfo>? altUnhealthy}) {
    return UsualFoodsItem(
      foodInfo: _foodInfo(food),
      alternativeUsualHealthyFoods: altHealthy ?? [],
      alternativeUsualUnHealthyFoods: altUnhealthy ?? [],
    );
  }

  // ---------------------------------------------------------------
  // findFoodCategoryType tests
  // ---------------------------------------------------------------
  group('findFoodCategoryType', () {
    late RecommendationsGeneralBloc bloc;

    setUp(() {
      bloc = _buildBloc();
    });

    test('returns 0 (blue/obj) for food in objFoods', () {
      final food = _food(id: 10, group: 'grains');
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 1, groups: ['grains']),
            objFoods: [_foodInfo(food)],
            deficitFoods: [],
          ),
        ],
      ));

      expect(bloc.findFoodCategoryType(10), 0);
    });

    test('returns 1 (green/deficit) for food in deficitFoods', () {
      final food = _food(id: 20, group: 'fruits');
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 1, groups: ['fruits']),
            objFoods: [],
            deficitFoods: [_foodInfo(food)],
          ),
        ],
      ));

      expect(bloc.findFoodCategoryType(20), 1);
    });

    test('returns 2 (yellowishGreen) for food in usualUnHealthyFoods', () {
      final food = _food(id: 30, group: 'snacks');
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 1, groups: ['snacks']),
            objFoods: [],
            deficitFoods: [],
            usualUnHealthyFoods: [_usualItem(food)],
          ),
        ],
      ));

      expect(bloc.findFoodCategoryType(30), 2);
    });

    test('returns 3 (yellowishGreen) for food in usualHealthyFoods', () {
      final food = _food(id: 40, group: 'veggies');
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 1, groups: ['veggies']),
            objFoods: [],
            deficitFoods: [],
            usualHealthyFoods: [_usualItem(food)],
          ),
        ],
      ));

      expect(bloc.findFoodCategoryType(40), 3);
    });

    test('returns -1 when food not found in any list', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 1, groups: ['grains']),
            objFoods: [_foodInfo(_food(id: 10))],
            deficitFoods: [],
          ),
        ],
      ));

      expect(bloc.findFoodCategoryType(999), -1);
    });

    test('returns -1 when recommendationFoodsItems is null', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: null,
      ));

      expect(bloc.findFoodCategoryType(10), -1);
    });

    test('returns -1 when recommendationFoodsItems is empty', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [],
      ));

      expect(bloc.findFoodCategoryType(10), -1);
    });

    test('objFoods takes priority over deficitFoods when food is in both', () {
      final food = _food(id: 50);
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 1, groups: ['grains']),
            objFoods: [_foodInfo(food)],
            deficitFoods: [_foodInfo(food)],
          ),
        ],
      ));

      // objFoods is checked first so should return 0
      expect(bloc.findFoodCategoryType(50), 0);
    });

    test('searches across multiple recommendation groups', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 1, groups: ['grains']),
            objFoods: [_foodInfo(_food(id: 10))],
            deficitFoods: [],
          ),
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 2, groups: ['fruits']),
            objFoods: [],
            deficitFoods: [_foodInfo(_food(id: 20))],
          ),
        ],
      ));

      expect(bloc.findFoodCategoryType(10), 0);
      expect(bloc.findFoodCategoryType(20), 1);
    });

    test('handles null usualHealthyFoods and usualUnHealthyFoods gracefully', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 1, groups: ['grains']),
            objFoods: [],
            deficitFoods: [],
            usualHealthyFoods: null,
            usualUnHealthyFoods: null,
          ),
        ],
      ));

      expect(bloc.findFoodCategoryType(10), -1);
    });

    test('deficitFoods takes priority over usualUnHealthyFoods (different groups)', () {
      final food = _food(id: 60);
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: _group(id: 1, groups: ['grains']),
            objFoods: [],
            deficitFoods: [_foodInfo(food)],
            usualUnHealthyFoods: [_usualItem(food)],
          ),
        ],
      ));

      // deficitFoods is checked before usualUnHealthyFoods
      expect(bloc.findFoodCategoryType(60), 1);
    });
  });

  // ---------------------------------------------------------------
  // _ensureSavedFoodsVisible logic tests (inline simulation)
  // ---------------------------------------------------------------
  group('ensureSavedFoodsVisible logic', () {
    test('saved food missing from recommendations is added to matching group objFoods', () {
      final savedFoods = [SimpleItem(name: '', id: 100)];
      final food100 = _food(id: 100, en: 'Broccoli', group: 'veggies');
      final group1 = _group(id: 1, groups: ['veggies'], en: 'Vegetables');
      final recItems = [
        RecommendationsFoodItem(
          recommendationGroup: group1,
          objFoods: [_foodInfo(_food(id: 10, group: 'veggies'))],
          deficitFoods: [],
        ),
      ];

      // Simulate _ensureSavedFoodsVisible
      final existingIds = <int>{};
      for (final item in recItems) {
        for (final f in item.objFoods) {
          if (f.foodItemMaster.id != null) existingIds.add(f.foodItemMaster.id!);
        }
        for (final f in item.deficitFoods) {
          if (f.foodItemMaster.id != null) existingIds.add(f.foodItemMaster.id!);
        }
      }

      for (final savedItem in savedFoods) {
        if (existingIds.contains(savedItem.id)) continue;
        if (food100.id == null) continue;
        final foodGroup = food100.group ?? '';
        if (foodGroup.isEmpty) continue;
        for (final recItem in recItems) {
          if (recItem.recommendationGroup.groups.contains(foodGroup)) {
            recItem.objFoods.add(RecommendationFoodInfo(
              foodItemMaster: food100,
              foodNutrients: [],
            ));
            break;
          }
        }
      }

      expect(recItems[0].objFoods.length, 2);
      expect(recItems[0].objFoods.last.foodItemMaster.id, 100);
      expect(recItems[0].objFoods.last.foodItemMaster.en, 'Broccoli');
    });

    test('saved food already in recommendations is NOT duplicated', () {
      final food10 = _food(id: 10, group: 'veggies');
      final savedFoods = [SimpleItem(name: '', id: 10)];
      final recItems = [
        RecommendationsFoodItem(
          recommendationGroup: _group(id: 1, groups: ['veggies']),
          objFoods: [_foodInfo(food10)],
          deficitFoods: [],
        ),
      ];

      final existingIds = <int>{};
      for (final item in recItems) {
        for (final f in item.objFoods) {
          if (f.foodItemMaster.id != null) existingIds.add(f.foodItemMaster.id!);
        }
      }

      int addCount = 0;
      for (final savedItem in savedFoods) {
        if (existingIds.contains(savedItem.id)) continue;
        addCount++;
      }

      expect(addCount, 0);
      expect(recItems[0].objFoods.length, 1);
    });

    test('saved food with null group is skipped', () {
      final savedFoods = [SimpleItem(name: '', id: 200)];
      final foodNoGroup = _food(id: 200, group: null);
      final recItems = [
        RecommendationsFoodItem(
          recommendationGroup: _group(id: 1, groups: ['veggies']),
          objFoods: [],
          deficitFoods: [],
        ),
      ];

      final existingIds = <int>{};
      int addCount = 0;
      for (final savedItem in savedFoods) {
        if (existingIds.contains(savedItem.id)) continue;
        final foodGroup = foodNoGroup.group ?? '';
        if (foodGroup.isEmpty) continue;
        addCount++;
      }

      expect(addCount, 0);
      expect(recItems[0].objFoods.length, 0);
    });

    test('saved food whose group does not match any recommendation group is not added', () {
      final savedFoods = [SimpleItem(name: '', id: 300)];
      final food300 = _food(id: 300, group: 'exotic');
      final recItems = [
        RecommendationsFoodItem(
          recommendationGroup: _group(id: 1, groups: ['veggies']),
          objFoods: [],
          deficitFoods: [],
        ),
        RecommendationsFoodItem(
          recommendationGroup: _group(id: 2, groups: ['grains']),
          objFoods: [],
          deficitFoods: [],
        ),
      ];

      final existingIds = <int>{};
      for (final savedItem in savedFoods) {
        if (existingIds.contains(savedItem.id)) continue;
        final foodGroup = food300.group ?? '';
        if (foodGroup.isEmpty) continue;
        bool found = false;
        for (final recItem in recItems) {
          if (recItem.recommendationGroup.groups.contains(foodGroup)) {
            found = true;
            break;
          }
        }
        expect(found, false);
      }

      expect(recItems[0].objFoods.length, 0);
      expect(recItems[1].objFoods.length, 0);
    });

    test('foods already in deficitFoods or usualFoods are counted as existing', () {
      final food50 = _food(id: 50, group: 'grains');
      final food60 = _food(id: 60, group: 'grains');
      final food70 = _food(id: 70, group: 'grains');
      final savedFoods = [
        SimpleItem(name: '', id: 50),
        SimpleItem(name: '', id: 60),
        SimpleItem(name: '', id: 70),
      ];
      final recItems = [
        RecommendationsFoodItem(
          recommendationGroup: _group(id: 1, groups: ['grains']),
          objFoods: [],
          deficitFoods: [_foodInfo(food50)],
          usualUnHealthyFoods: [_usualItem(food60)],
          usualHealthyFoods: [_usualItem(food70)],
        ),
      ];

      final existingIds = <int>{};
      for (final item in recItems) {
        for (final f in item.objFoods) {
          if (f.foodItemMaster.id != null) existingIds.add(f.foodItemMaster.id!);
        }
        for (final f in item.deficitFoods) {
          if (f.foodItemMaster.id != null) existingIds.add(f.foodItemMaster.id!);
        }
        for (final f in (item.usualHealthyFoods ?? [])) {
          if (f.foodInfo.foodItemMaster.id != null) existingIds.add(f.foodInfo.foodItemMaster.id!);
        }
        for (final f in (item.usualUnHealthyFoods ?? [])) {
          if (f.foodInfo.foodItemMaster.id != null) existingIds.add(f.foodInfo.foodItemMaster.id!);
        }
      }

      expect(existingIds.contains(50), true);
      expect(existingIds.contains(60), true);
      expect(existingIds.contains(70), true);

      for (final savedItem in savedFoods) {
        expect(existingIds.contains(savedItem.id), true);
      }
      expect(recItems[0].objFoods.length, 0);
    });

    test('multiple saved foods can be added to different groups', () {
      final food100 = _food(id: 100, group: 'veggies');
      final food200 = _food(id: 200, group: 'grains');
      final savedFoods = [
        SimpleItem(name: '', id: 100),
        SimpleItem(name: '', id: 200),
      ];
      final recItems = [
        RecommendationsFoodItem(
          recommendationGroup: _group(id: 1, groups: ['veggies']),
          objFoods: [],
          deficitFoods: [],
        ),
        RecommendationsFoodItem(
          recommendationGroup: _group(id: 2, groups: ['grains']),
          objFoods: [],
          deficitFoods: [],
        ),
      ];

      final foods = {100: food100, 200: food200};
      final existingIds = <int>{};

      for (final savedItem in savedFoods) {
        if (existingIds.contains(savedItem.id)) continue;
        final food = foods[savedItem.id]!;
        if (food.id == null) continue;
        final foodGroup = food.group ?? '';
        if (foodGroup.isEmpty) continue;
        for (final recItem in recItems) {
          if (recItem.recommendationGroup.groups.contains(foodGroup)) {
            recItem.objFoods.add(RecommendationFoodInfo(
              foodItemMaster: food,
              foodNutrients: [],
            ));
            break;
          }
        }
      }

      expect(recItems[0].objFoods.length, 1);
      expect(recItems[0].objFoods[0].foodItemMaster.id, 100);
      expect(recItems[1].objFoods.length, 1);
      expect(recItems[1].objFoods[0].foodItemMaster.id, 200);
    });
  });

  // ---------------------------------------------------------------
  // findFoodGroup tests
  // ---------------------------------------------------------------
  group('findFoodGroup', () {
    late RecommendationsGeneralBloc bloc;

    setUp(() {
      bloc = _buildBloc();
    });

    test('returns matching RecommendationGroup when food group matches', () {
      final vegGroup = _group(id: 1, groups: ['veggies'], en: 'Vegetables');
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        foodAndDrinksNames: [_food(id: 10, group: 'veggies')],
        recommendationGroups: RecommendationGroupsMaster(recommendationGroups: [vegGroup]),
      ));

      final result = bloc.findFoodGroup(10);
      expect(result, isNotNull);
      expect(result!.id, 1);
      expect(result.en, 'Vegetables');
    });

    test('returns null when food has no group', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        foodAndDrinksNames: [_food(id: 10, group: null)],
        recommendationGroups: RecommendationGroupsMaster(
          recommendationGroups: [_group(id: 1, groups: ['veggies'])],
        ),
      ));

      expect(bloc.findFoodGroup(10), isNull);
    });

    test('returns null when food has empty group string', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        foodAndDrinksNames: [_food(id: 10, group: '')],
        recommendationGroups: RecommendationGroupsMaster(
          recommendationGroups: [_group(id: 1, groups: ['veggies'])],
        ),
      ));

      expect(bloc.findFoodGroup(10), isNull);
    });

    test('returns null when food group does not match any recommendation group', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        foodAndDrinksNames: [_food(id: 10, group: 'exotic')],
        recommendationGroups: RecommendationGroupsMaster(
          recommendationGroups: [_group(id: 1, groups: ['veggies'])],
        ),
      ));

      expect(bloc.findFoodGroup(10), isNull);
    });

    test('returns null when recommendationGroups is null', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        foodAndDrinksNames: [_food(id: 10, group: 'veggies')],
        recommendationGroups: null,
      ));

      expect(bloc.findFoodGroup(10), isNull);
    });
  });

  // ---------------------------------------------------------------
  // findFood tests
  // ---------------------------------------------------------------
  group('findFood', () {
    late RecommendationsGeneralBloc bloc;

    setUp(() {
      bloc = _buildBloc();
    });

    test('finds food by id from foodAndDrinksNames list', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        foodAndDrinksNames: [
          _food(id: 1, en: 'Chicken'),
          _food(id: 2, en: 'Rice'),
        ],
      ));

      final result = bloc.findFood(1);
      expect(result.en, 'Chicken');
    });

    test('returns empty FoodItemMaster when id not found', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        foodAndDrinksNames: [_food(id: 1, en: 'Chicken')],
      ));

      final result = bloc.findFood(999);
      expect(result.id, isNull);
    });
  });

  // ---------------------------------------------------------------
  // getRecommendationFoodInfo tests
  // ---------------------------------------------------------------
  group('getRecommendationFoodInfo', () {
    late RecommendationsGeneralBloc bloc;

    setUp(() {
      bloc = _buildBloc();
    });

    test('maps food IDs to RecommendationFoodInfo objects', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        foodAndDrinksNames: [
          _food(id: 1, en: 'Chicken'),
          _food(id: 2, en: 'Rice'),
          _food(id: 3, en: 'Salmon'),
        ],
      ));

      final result = bloc.getRecommendationFoodInfo([1, 3]);
      expect(result.length, 2);
      expect(result[0].foodItemMaster.en, 'Chicken');
      expect(result[1].foodItemMaster.en, 'Salmon');
      expect(result[0].foodNutrients, isEmpty);
    });

    test('returns empty foodNutrients for each item', () {
      bloc.emit(RecommendationsGeneralState(
        isLoading: false,
        foodAndDrinksNames: [_food(id: 1, en: 'Apple')],
      ));

      final result = bloc.getRecommendationFoodInfo([1]);
      expect(result[0].foodNutrients, isEmpty);
    });
  });

  // ---------------------------------------------------------------
  // LoadRecentFoodsAction tests
  // ---------------------------------------------------------------
  group('LoadRecentFoodsAction', () {
    test('loads recent food events into state', () async {
      final mockRecentEvents = _MockGetRecentFoodEventsInteractor();
      final events = [
        FoodEventComplete(
          eventDate: 20260313,
          mealType: 0,
          foodInfo: [
            FoodInfo('grains', 1, 'Oats', 'Avena', 1, null, null, null),
            FoodInfo('fruits', 2, 'Apple', 'Manzana', 1, null, null, null),
          ],
        ),
        FoodEventComplete(
          eventDate: 20260312,
          mealType: 1,
          foodInfo: [
            FoodInfo('grains', 1, 'Oats', 'Avena', 1, null, null, null),
          ],
        ),
      ];
      when(() => mockRecentEvents.execute()).thenAnswer((_) async => events);

      final bloc = _buildBloc(recentFoodEventsInteractor: mockRecentEvents);
      // Reset to null so the guard allows loading
      bloc.emit(RecommendationsGeneralState(isLoading: false, recentFoodEvents: null));
      bloc.add(LoadRecentFoodsAction());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.recentFoodEvents, isNotNull);
      expect(bloc.state.recentFoodEvents!.length, 2);
    });

    test('sets empty list on error', () async {
      final mockRecentEvents = _MockGetRecentFoodEventsInteractor();
      when(() => mockRecentEvents.execute()).thenThrow(Exception('test error'));

      final bloc = _buildBloc(recentFoodEventsInteractor: mockRecentEvents);
      bloc.emit(RecommendationsGeneralState(isLoading: false, recentFoodEvents: null));
      bloc.add(LoadRecentFoodsAction());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.recentFoodEvents, isNotNull);
      expect(bloc.state.recentFoodEvents, isEmpty);
    });

    test('does not reload if already loaded', () async {
      final mockRecentEvents = _MockGetRecentFoodEventsInteractor();
      when(() => mockRecentEvents.execute()).thenAnswer((_) async => []);

      final bloc = _buildBloc(recentFoodEventsInteractor: mockRecentEvents);
      bloc.emit(RecommendationsGeneralState(isLoading: false, recentFoodEvents: null));
      bloc.add(LoadRecentFoodsAction());
      await Future.delayed(const Duration(milliseconds: 100));

      // Second call should be a no-op (recentFoodEvents is now non-null)
      bloc.add(LoadRecentFoodsAction());
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockRecentEvents.execute()).called(1);
    });
  });

  // ---------------------------------------------------------------
  // LoadFavoritesAction tests
  // ---------------------------------------------------------------
  group('LoadFavoritesAction', () {
    test('loads food favorites into state', () async {
      final mockFavorites = _MockGetFoodFavoritesInteractor();
      final favorites = [
        FoodFavorite(
          ingredients: [
            FoodInFavorite(id: 10, name_en: 'Chicken', qty: 100, unit: 1, cookingMethod: 0),
            FoodInFavorite(id: 20, name_en: 'Rice', qty: 200, unit: 1, cookingMethod: 0),
          ],
          drinks: [],
          mealTime: 1,
        ),
      ];
      when(() => mockFavorites.execute()).thenAnswer((_) async => favorites);

      final bloc = _buildBloc(foodFavoritesInteractor: mockFavorites);
      bloc.emit(RecommendationsGeneralState(isLoading: false, foodFavorites: null));
      bloc.add(LoadFavoritesAction());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.foodFavorites, isNotNull);
      expect(bloc.state.foodFavorites!.length, 1);
      expect(bloc.state.foodFavorites![0].ingredients.length, 2);
    });

    test('sets empty list on error', () async {
      final mockFavorites = _MockGetFoodFavoritesInteractor();
      when(() => mockFavorites.execute()).thenThrow(Exception('test error'));

      final bloc = _buildBloc(foodFavoritesInteractor: mockFavorites);
      bloc.emit(RecommendationsGeneralState(isLoading: false, foodFavorites: null));
      bloc.add(LoadFavoritesAction());
      await Future.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.foodFavorites, isNotNull);
      expect(bloc.state.foodFavorites, isEmpty);
    });

    test('does not reload if already loaded', () async {
      final mockFavorites = _MockGetFoodFavoritesInteractor();
      when(() => mockFavorites.execute()).thenAnswer((_) async => []);

      final bloc = _buildBloc(foodFavoritesInteractor: mockFavorites);
      bloc.emit(RecommendationsGeneralState(isLoading: false, foodFavorites: null));
      bloc.add(LoadFavoritesAction());
      await Future.delayed(const Duration(milliseconds: 100));

      // Second call should be a no-op (foodFavorites is now non-null)
      bloc.add(LoadFavoritesAction());
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockFavorites.execute()).called(1);
    });
  });

  // ---------------------------------------------------------------
  // Recents food counting logic (pure unit test)
  // ---------------------------------------------------------------
  group('Recents food counting logic', () {
    test('counts unique foods across multiple events', () {
      final events = [
        FoodEventComplete(foodInfo: [
          FoodInfo('grains', 1, 'Oats', 'Avena', 1, null, null, null),
          FoodInfo('fruits', 2, 'Apple', 'Manzana', 1, null, null, null),
        ]),
        FoodEventComplete(foodInfo: [
          FoodInfo('grains', 1, 'Oats', 'Avena', 1, null, null, null),
          FoodInfo('veggies', 3, 'Broccoli', 'Brocoli', 1, null, null, null),
        ]),
        FoodEventComplete(foodInfo: [
          FoodInfo('grains', 1, 'Oats', 'Avena', 1, null, null, null),
        ]),
      ];

      final foodCounts = <int, int>{};
      for (final event in events) {
        for (final food in event.foodInfo ?? <FoodInfo>[]) {
          if (food.id == null) continue;
          foodCounts[food.id!] = (foodCounts[food.id!] ?? 0) + 1;
        }
      }

      expect(foodCounts[1], 3); // Oats eaten 3 times
      expect(foodCounts[2], 1); // Apple eaten once
      expect(foodCounts[3], 1); // Broccoli eaten once
      expect(foodCounts.length, 3); // 3 unique foods
    });

    test('sorts by count descending', () {
      final counts = {'Oats': 5, 'Apple': 2, 'Rice': 8, 'Chicken': 1};
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      expect(sorted[0].key, 'Rice');
      expect(sorted[1].key, 'Oats');
      expect(sorted[2].key, 'Apple');
      expect(sorted[3].key, 'Chicken');
    });

    test('skips foods with null id', () {
      final events = [
        FoodEventComplete(foodInfo: [
          FoodInfo('grains', null, 'Unknown', 'Desconocido', 1, null, null, null),
          FoodInfo('fruits', 2, 'Apple', 'Manzana', 1, null, null, null),
        ]),
      ];

      final foodCounts = <int, int>{};
      for (final event in events) {
        for (final food in event.foodInfo ?? <FoodInfo>[]) {
          if (food.id == null) continue;
          foodCounts[food.id!] = (foodCounts[food.id!] ?? 0) + 1;
        }
      }

      expect(foodCounts.length, 1);
      expect(foodCounts.containsKey(2), true);
    });

    test('handles events with null foodInfo', () {
      final events = [
        FoodEventComplete(foodInfo: null),
        FoodEventComplete(foodInfo: [
          FoodInfo('fruits', 2, 'Apple', 'Manzana', 1, null, null, null),
        ]),
      ];

      final foodCounts = <int, int>{};
      for (final event in events) {
        for (final food in event.foodInfo ?? <FoodInfo>[]) {
          if (food.id == null) continue;
          foodCounts[food.id!] = (foodCounts[food.id!] ?? 0) + 1;
        }
      }

      expect(foodCounts.length, 1);
    });
  });

  // ---------------------------------------------------------------
  // Favorites deduplication logic (pure unit test)
  // ---------------------------------------------------------------
  group('Favorites deduplication logic', () {
    test('collects unique foods from multiple favorites', () {
      final favorites = [
        FoodFavorite(
          ingredients: [
            FoodInFavorite(id: 10, name_en: 'Chicken', qty: 100, unit: 1, cookingMethod: 0),
            FoodInFavorite(id: 20, name_en: 'Rice', qty: 200, unit: 1, cookingMethod: 0),
          ],
          drinks: [
            FoodInFavorite(id: 30, name_en: 'Water', qty: 250, unit: 1, cookingMethod: 0),
          ],
          mealTime: 1,
        ),
        FoodFavorite(
          ingredients: [
            FoodInFavorite(id: 10, name_en: 'Chicken', qty: 150, unit: 1, cookingMethod: 1),
            FoodInFavorite(id: 40, name_en: 'Salmon', qty: 100, unit: 1, cookingMethod: 0),
          ],
          drinks: [],
          mealTime: 2,
        ),
      ];

      final uniqueFoods = <int, FoodInFavorite>{};
      for (final fav in favorites) {
        for (final ingredient in fav.ingredients) {
          uniqueFoods.putIfAbsent(ingredient.id, () => ingredient);
        }
        for (final drink in fav.drinks) {
          uniqueFoods.putIfAbsent(drink.id, () => drink);
        }
      }

      expect(uniqueFoods.length, 4); // Chicken, Rice, Water, Salmon
      expect(uniqueFoods.containsKey(10), true);
      expect(uniqueFoods.containsKey(20), true);
      expect(uniqueFoods.containsKey(30), true);
      expect(uniqueFoods.containsKey(40), true);
    });

    test('keeps first occurrence when food appears in multiple favorites', () {
      final favorites = [
        FoodFavorite(
          ingredients: [
            FoodInFavorite(id: 10, name_en: 'Chicken Grilled', qty: 100, unit: 1, cookingMethod: 0),
          ],
          drinks: [],
          mealTime: 1,
        ),
        FoodFavorite(
          ingredients: [
            FoodInFavorite(id: 10, name_en: 'Chicken Boiled', qty: 200, unit: 1, cookingMethod: 2),
          ],
          drinks: [],
          mealTime: 2,
        ),
      ];

      final uniqueFoods = <int, FoodInFavorite>{};
      for (final fav in favorites) {
        for (final ingredient in fav.ingredients) {
          uniqueFoods.putIfAbsent(ingredient.id, () => ingredient);
        }
      }

      expect(uniqueFoods.length, 1);
      expect(uniqueFoods[10]!.name_en, 'Chicken Grilled'); // first occurrence kept
    });

    test('handles empty favorites list', () {
      final favorites = <FoodFavorite>[];

      final uniqueFoods = <int, FoodInFavorite>{};
      for (final fav in favorites) {
        for (final ingredient in fav.ingredients) {
          uniqueFoods.putIfAbsent(ingredient.id, () => ingredient);
        }
      }

      expect(uniqueFoods, isEmpty);
    });

    test('handles favorites with empty ingredients and drinks', () {
      final favorites = [
        FoodFavorite(ingredients: [], drinks: [], mealTime: 0),
      ];

      final uniqueFoods = <int, FoodInFavorite>{};
      for (final fav in favorites) {
        for (final ingredient in fav.ingredients) {
          uniqueFoods.putIfAbsent(ingredient.id, () => ingredient);
        }
        for (final drink in fav.drinks) {
          uniqueFoods.putIfAbsent(drink.id, () => drink);
        }
      }

      expect(uniqueFoods, isEmpty);
    });
  });
}
