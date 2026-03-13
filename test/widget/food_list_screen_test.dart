import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/recommendation_groups_master.dart';
import 'package:nutrenaissance_flutter/domain/models/recommendations/recommendations_food_item.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/recommendation_computation_service.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/common/bloc/recommendations_general_state.dart';
import 'package:nutrenaissance_flutter/presentation/recommendations/foodslist/view/food_list_tab.dart';

// --- Mocktail mocks ---
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

void main() {
  // ---------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------
  FoodItemMaster _food({required int id, String en = 'Apple', String? group}) {
    return FoodItemMaster(id: id, en: en, es: 'Comida $id', group: group);
  }

  RecommendationFoodInfo _foodInfo(FoodItemMaster food) {
    return RecommendationFoodInfo(foodItemMaster: food, foodNutrients: []);
  }

  RecommendationGroup _recGroup({required int id, required List<String> groups, String en = 'Group'}) {
    return RecommendationGroup(id: id, groups: groups, size: 5, en: en, es: en);
  }

  RecommendationsGeneralBloc _buildBloc({
    List<SimpleItem>? foodItems,
    List<FoodItemMaster>? foodAndDrinksNames,
    List<RecommendationsFoodItem>? recommendationFoodsItems,
    RecommendationGroupsMaster? recommendationGroups,
  }) {
    final bloc = RecommendationsGeneralBloc(
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
      getWeekFoodEventsInteractor: _MockGetWeekFoodEventsInteractor(),
      getRecentFoodEventsInteractor: _MockGetRecentFoodEventsInteractor(),
      getFoodFavoritesInteractor: _MockGetFoodFavoritesInteractor(),
    );

    bloc.emit(RecommendationsGeneralState(
      isLoading: false,
      foodItems: foodItems ?? [],
      foodAndDrinksNames: foodAndDrinksNames ?? [],
      recommendationFoodsItems: recommendationFoodsItems ?? [],
      recommendationGroups: recommendationGroups ?? RecommendationGroupsMaster(recommendationGroups: []),
    ));

    return bloc;
  }

  Widget buildTestWidget({required RecommendationsGeneralBloc bloc, List<SimpleItem>? foodItems}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: BlocProvider<RecommendationsGeneralBloc>.value(
        value: bloc,
        child: FoodListScreen(foodItems: foodItems ?? []),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------
  group('FoodListScreen', () {
    testWidgets('displays food items from state', (tester) async {
      final foods = [
        _food(id: 1, en: 'Chicken', group: 'meats'),
        _food(id: 2, en: 'Rice', group: 'grains'),
      ];
      final recGroup1 = _recGroup(id: 1, groups: ['meats'], en: 'Meats');
      final recGroup2 = _recGroup(id: 2, groups: ['grains'], en: 'Grains');

      final bloc = _buildBloc(
        foodItems: [
          SimpleItem(name: '', id: 1),
          SimpleItem(name: '', id: 2),
        ],
        foodAndDrinksNames: foods,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: recGroup1,
            objFoods: [_foodInfo(foods[0])],
            deficitFoods: [],
          ),
          RecommendationsFoodItem(
            recommendationGroup: recGroup2,
            objFoods: [],
            deficitFoods: [_foodInfo(foods[1])],
          ),
        ],
        recommendationGroups: RecommendationGroupsMaster(
          recommendationGroups: [recGroup1, recGroup2],
        ),
      );

      await tester.pumpWidget(buildTestWidget(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('Chicken'), findsOneWidget);
      expect(find.text('Rice'), findsOneWidget);
    });

    testWidgets('shows food group name as subtitle when available', (tester) async {
      final food = _food(id: 1, en: 'Chicken', group: 'meats');
      final recGroup = _recGroup(id: 1, groups: ['meats'], en: 'Meats & Proteins');

      final bloc = _buildBloc(
        foodItems: [SimpleItem(name: '', id: 1)],
        foodAndDrinksNames: [food],
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: recGroup,
            objFoods: [_foodInfo(food)],
            deficitFoods: [],
          ),
        ],
        recommendationGroups: RecommendationGroupsMaster(recommendationGroups: [recGroup]),
      );

      await tester.pumpWidget(buildTestWidget(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('Chicken'), findsOneWidget);
      expect(find.text('Meats & Proteins'), findsOneWidget);
    });

    testWidgets('food card has clipBehavior Clip.antiAlias', (tester) async {
      final food = _food(id: 1, en: 'Rice', group: 'grains');
      final recGroup = _recGroup(id: 1, groups: ['grains']);

      final bloc = _buildBloc(
        foodItems: [SimpleItem(name: '', id: 1)],
        foodAndDrinksNames: [food],
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: recGroup,
            objFoods: [_foodInfo(food)],
            deficitFoods: [],
          ),
        ],
        recommendationGroups: RecommendationGroupsMaster(recommendationGroups: [recGroup]),
      );

      await tester.pumpWidget(buildTestWidget(bloc: bloc));
      await tester.pumpAndSettle();

      final containerFinder = find.byWidgetPredicate((widget) =>
        widget is Container && widget.clipBehavior == Clip.antiAlias,
      );
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('food card contains IntrinsicHeight for proper strip height', (tester) async {
      final food = _food(id: 1, en: 'Rice', group: 'grains');
      final recGroup = _recGroup(id: 1, groups: ['grains']);

      final bloc = _buildBloc(
        foodItems: [SimpleItem(name: '', id: 1)],
        foodAndDrinksNames: [food],
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: recGroup,
            objFoods: [_foodInfo(food)],
            deficitFoods: [],
          ),
        ],
        recommendationGroups: RecommendationGroupsMaster(recommendationGroups: [recGroup]),
      );

      await tester.pumpWidget(buildTestWidget(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.byType(IntrinsicHeight), findsOneWidget);
    });

    testWidgets('shows "My foods list" header', (tester) async {
      final bloc = _buildBloc(foodItems: [], foodAndDrinksNames: []);

      await tester.pumpWidget(buildTestWidget(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('My foods list'), findsOneWidget);
    });

    testWidgets('shows empty list when no food items', (tester) async {
      final bloc = _buildBloc(foodItems: [], foodAndDrinksNames: []);

      await tester.pumpWidget(buildTestWidget(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('My foods list'), findsOneWidget);
      // No food cards
      expect(find.byType(IntrinsicHeight), findsNothing);
    });

    testWidgets('delete icon shows RemoveItemWidget dialog', (tester) async {
      final food = _food(id: 1, en: 'Rice', group: 'grains');
      final recGroup = _recGroup(id: 1, groups: ['grains']);

      final bloc = _buildBloc(
        foodItems: [SimpleItem(name: '', id: 1)],
        foodAndDrinksNames: [food],
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: recGroup,
            objFoods: [_foodInfo(food)],
            deficitFoods: [],
          ),
        ],
        recommendationGroups: RecommendationGroupsMaster(recommendationGroups: [recGroup]),
      );

      await tester.pumpWidget(buildTestWidget(bloc: bloc));
      await tester.pumpAndSettle();

      // Find the delete icon (Image.asset)
      final deleteIcon = find.byWidgetPredicate((widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == 'assets/images/delete_icon.png',
      );
      expect(deleteIcon, findsOneWidget);

      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // RemoveItemWidget dialog should appear
      expect(find.text('Remove item'), findsOneWidget);
      // Yes/No buttons
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('dialog shows food name in description', (tester) async {
      final food = _food(id: 1, en: 'Salmon', group: 'fish');
      final recGroup = _recGroup(id: 1, groups: ['fish']);

      final bloc = _buildBloc(
        foodItems: [SimpleItem(name: '', id: 1)],
        foodAndDrinksNames: [food],
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: recGroup,
            objFoods: [_foodInfo(food)],
            deficitFoods: [],
          ),
        ],
        recommendationGroups: RecommendationGroupsMaster(recommendationGroups: [recGroup]),
      );

      await tester.pumpWidget(buildTestWidget(bloc: bloc));
      await tester.pumpAndSettle();

      final deleteIcon = find.byWidgetPredicate((widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == 'assets/images/delete_icon.png',
      );
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // Dialog should mention the food name
      expect(find.text('Salmon'), findsWidgets);
    });

    testWidgets('multiple food items are listed in a ListView', (tester) async {
      final foods = [
        _food(id: 1, en: 'Apple', group: 'fruits'),
        _food(id: 2, en: 'Banana', group: 'fruits'),
        _food(id: 3, en: 'Chicken', group: 'meats'),
      ];
      final recGroup1 = _recGroup(id: 1, groups: ['fruits'], en: 'Fruits');
      final recGroup2 = _recGroup(id: 2, groups: ['meats'], en: 'Meats');

      final bloc = _buildBloc(
        foodItems: [
          SimpleItem(name: '', id: 1),
          SimpleItem(name: '', id: 2),
          SimpleItem(name: '', id: 3),
        ],
        foodAndDrinksNames: foods,
        recommendationFoodsItems: [
          RecommendationsFoodItem(
            recommendationGroup: recGroup1,
            objFoods: [_foodInfo(foods[0]), _foodInfo(foods[1])],
            deficitFoods: [],
          ),
          RecommendationsFoodItem(
            recommendationGroup: recGroup2,
            objFoods: [_foodInfo(foods[2])],
            deficitFoods: [],
          ),
        ],
        recommendationGroups: RecommendationGroupsMaster(
          recommendationGroups: [recGroup1, recGroup2],
        ),
      );

      await tester.pumpWidget(buildTestWidget(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Chicken'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
