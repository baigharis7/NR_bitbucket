import 'dart:convert';
import 'dart:io';

import 'package:chuck_interceptor/chuck_interceptor.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/drift/reference_database.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/units_foods_entity.dart';
import 'package:nutrenaissance_flutter/domain/models/calendar/dashboard_all_calendar_events.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/supplements_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/food_event_mappers.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/nutrient_calculation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_actions.dart';
import 'package:nutrenaissance_flutter/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/bloc/meal_time_details_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/widgets/NutritionProgressWidget.dart';
import 'package:nutrenaissance_flutter/infrastructure/l10n/generated/app_localizations.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';

import 'bloc_test_mocks.mocks.dart';

/// Aggregation oracle — sums must run on RAW values, rounding only at display.
///
/// Automates the manual validation pass performed on-device on 2026-07-16
/// against the domain expert's oracle (same 5 foods and grams as the B1
/// fixture, spread over three meals):
///
///   breakfast: omelette 60 g + serrano ham 250 g
///   lunch:     pork chop 300 g + brown rice 80 g
///   dinner:    pasta 90 g
///
/// The meal plan is chosen so that summing already-rounded per-food values
/// gives a DIFFERENT result than rounding the raw sum. Three discriminating
/// cases, all confirmed on-device:
///
///   breakfast protein  8.76 + 76.25 = 85.01 -> "85.0"  (rounded-sum bug: 85.1)
///   breakfast fat      7.374 + 11.25 = 18.62 -> "18.6" (rounded-sum bug: 18.7)
///   day protein        raw sum 161.76 -> "161.8"       (rounded-sum bug: 161.9)
///
/// If someone ever "optimizes" the aggregation to sum display-rounded values,
/// these tests go red. Expected values verified against Dart's actual binary
/// rounding (12.15 -> "12.2", 76.25 -> "76.3"), not recomputed by hand.
///
/// Not asserted here: kcal (integer display, convention not yet validated
/// with the domain expert) and micronutrients (same reason).

class _Meal {
  final int mealTypeId;
  final String name;
  final List<(int foodId, int grams)> foods;
  final double protein;
  final double carbs;
  final double fat;
  final String proteinDisplay;
  final String carbsDisplay;
  final String fatDisplay;

  const _Meal(
    this.mealTypeId,
    this.name,
    this.foods, {
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinDisplay,
    required this.carbsDisplay,
    required this.fatDisplay,
  });
}

// Foods: 2050 Tortilla francesa, 1745 Jamón serrano, 1870 Chuleta de cerdo,
// 156 Arroz integral, 305 Pasta — the frozen B1 fixture entries.
const _meals = [
  _Meal(
    0,
    'breakfast',
    [(2050, 60), (1745, 250)],
    protein: 85.01,
    carbs: 0.24,
    fat: 18.62,
    proteinDisplay: '85.0',
    carbsDisplay: '0.2',
    fatDisplay: '18.6',
  ),
  _Meal(
    1,
    'lunch',
    [(1870, 300), (156, 80)],
    protein: 64.6,
    carbs: 57.44,
    fat: 47.32,
    proteinDisplay: '64.6',
    carbsDisplay: '57.4',
    fatDisplay: '47.3',
  ),
  _Meal(
    2,
    'dinner',
    [(305, 90)],
    protein: 12.15,
    carbs: 65.16,
    fat: 1.62,
    proteinDisplay: '12.2',
    carbsDisplay: '65.2',
    fatDisplay: '1.6',
  ),
];

// Day totals (raw sums, then the 2-decimal clamp the blocs apply).
const _dayProtein = 161.76, _dayCarbs = 122.84, _dayFat = 67.56;
const _dayProteinDisplay = '161.8',
    _dayCarbsDisplay = '122.8',
    _dayFatDisplay = '67.6';

const _tolerance = 0.01;

final _nutrientsInfoReal = [
  NutrientInfoMaster(
    officialName: 'proteinSci',
    unit: 'g',
    en: 'Protein',
    es: 'Proteínas',
  ),
  NutrientInfoMaster(
    officialName: 'proteinLabel',
    unit: 'g',
    en: 'Protein labeling',
    es: 'Etiquetado de proteínas',
  ),
  NutrientInfoMaster(
    officialName: 'carbsAvailable',
    unit: 'g',
    en: 'Carbohydrates',
    es: 'Hidratos',
  ),
  NutrientInfoMaster(
    officialName: 'fatTotal',
    unit: 'g',
    en: 'Fat',
    es: 'Grasas',
  ),
];

class _FakeProfileComputationService extends Fake
    implements ProfileComputationService {
  @override
  Future<Map<int, List<String>>?> getObjectiveNutrientsMap(
    List<int> objectiveIds,
  ) async => null;
}

/// Builds the in-memory reference DB from the frozen fixture and enriches the
/// full meal plan through the production pipeline (calculation engine ->
/// entity mapper -> domain mapper), exactly like a real food registration.
Future<List<FoodEventComplete>> enrichMealPlan(ReferenceDatabase db) async {
  final raw = File(
    'test/fixtures/nutrients_real_subset.json',
  ).readAsStringSync();
  final fixtureFoods =
      (jsonDecode(raw) as Map<String, dynamic>)['foods'] as List<dynamic>;
  for (final food in fixtureFoods) {
    await db
        .into(db.nutrientCompositions)
        .insert(
          NutrientCompositionsCompanion(
            foodId: Value(int.parse(food['id'].toString())),
            isFood: Value(int.tryParse(food['isFood'].toString()) ?? 1),
            group: Value(food['group']?.toString() ?? ''),
            nameEn: Value(food['name_en']?.toString() ?? ''),
            nameEs: Value(food['name_es']?.toString() ?? ''),
            recommendable: Value(
              int.tryParse(food['recommendable'].toString()) ?? 1,
            ),
            freeSugar: Value(food['freeSugar']?.toString()),
            params: Value(jsonEncode(food['params'])),
          ),
        );
  }

  final service = NutrientCalculationService(db);
  final events = <FoodEventComplete>[];
  for (final meal in _meals) {
    for (final (foodId, grams) in meal.foods) {
      // Raw food, base unit pair "38,1" carried by every catalog food,
      // no cooking method — same shape as the B1 oracle registrations.
      final simple = FoodEventSimple(
        userId: 'user123',
        eventId: foodId,
        eventDate: 20260716,
        mealType: meal.mealTypeId,
        foodName: null,
        comment: null,
        ingredients: [
          FoodInEvent(id: foodId, qty: grams, unit: 38, cookingMethod: -1),
        ],
      );
      final upload = await service.enrichFoodEvent(
        simple,
        unitsFoods: [UnitFoodEntity(id: foodId, units: '38,1')],
        conversionFactorsInfo: [],
      );
      events.add(mapToFoodEventComplete(mapToFoodEventEntity(upload)));
    }
  }
  return events;
}

/// Runs MealTimeDetailsBloc with the FULL day of events and returns the
/// macros it would paint for one meal time (the bloc itself filters by meal).
Future<List<NutrientsModel>> _mealMacros(
  List<FoodEventComplete> allEvents,
  _Meal meal,
) async {
  final mockGetUserId = MockGetUserIdInteractor();
  final mockGetFoodEventsOfToday = MockGetFoodEventsOfTodayInteractor();
  final mockGetTodayLiquidEvents = MockGetTodayLiquidEventsInteractor();
  final mockGetProfile = MockGetProfileInteractor();
  final mockGetMasterFile = MockGetMasterFileInteractor();
  final mockUpdateEvents = MockUpdateEventsInteractor();

  when(mockGetUserId.execute()).thenReturn('user123');
  when(
    mockGetProfile.execute(),
  ).thenAnswer((_) async => UserProfileModel(userId: 'user123'));
  when(mockGetMasterFile.execute(MasterFilesType.nutrientsInfo)).thenAnswer(
    (_) async => NutrientsInfoMaster(nutrientsInfo: _nutrientsInfoReal),
  );
  when(
    mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames),
  ).thenAnswer(
    (_) async => FoodsAndDrinksNamesMaster(
      FoodsAndDrinkListsMaster(foodNames: [], drinkNames: []),
    ),
  );
  when(
    mockGetMasterFile.execute(MasterFilesType.unitsInfo),
  ).thenAnswer((_) async => UnitsInfoMaster(unitsInfoMaster: []));
  when(mockGetMasterFile.execute(MasterFilesType.objectivesInfo)).thenAnswer(
    (_) async => ObjectivesInfoMaster(
      objectives: [],
      metabolicObjectives: [],
      bodyCompositionObjectives: [],
    ),
  );
  when(
    mockGetFoodEventsOfToday.execute(dateTime: anyNamed('dateTime')),
  ).thenAnswer((_) async => allEvents);
  when(
    mockGetTodayLiquidEvents.execute(dateTime: anyNamed('dateTime')),
  ).thenAnswer((_) async => <LiquidEventComplete>[]);
  when(
    mockUpdateEvents.execute(
      userId: anyNamed('userId'),
      categoryType: anyNamed('categoryType'),
      fullSync: anyNamed('fullSync'),
    ),
  ).thenAnswer((_) async => false);

  final bloc = MealTimeDetailsBloc(
    getUserIdInteractor: mockGetUserId,
    getFoodEventsOfTodayInteractor: mockGetFoodEventsOfToday,
    getLiquidEventsOfTodayInteractor: mockGetTodayLiquidEvents,
    getProfileInteractor: mockGetProfile,
    getMasterFileInteractor: mockGetMasterFile,
    deleteFoodEventInteractor: MockDeleteFoodEventInteractor(),
    removeFoodEventInteractor: MockRemoveFoodEventInteractor(),
    updateEventsInteractor: mockUpdateEvents,
    preferencesRepository: MockPreferencesRepository(),
    profileComputationService: _FakeProfileComputationService(),
  );

  bloc.add(
    UpdateFoodArgumentsModelEventState(
      foodArgumentsModel: FoodArgumentsModel(
        mealTime: MealTime(id: meal.mealTypeId, name: meal.name, time: ''),
        selectedDateTime: DateTime(2026, 7, 16),
      ),
    ),
  );
  await pumpEventQueue();

  final macros = bloc.state.macronutrients;
  await bloc.close();

  expect(macros, isNotNull, reason: 'Bloc never built the macro list');
  expect(macros!.length, 3);
  return macros;
}

/// Runs DashboardBloc's food refresh with the full day of events and returns
/// the day-total macros the dashboard would paint.
Future<List<NutrientsModel>> dayMacros(
  List<FoodEventComplete> allEvents,
) async {
  final mockGetFoodEvents = MockGetFoodEventsOfTodayInteractor();
  final mockGetWeekFoodEvents = MockGetWeekFoodEventsInteractor();
  final mockGetDayCalories = MockGetDayCaloriesInteractor();
  final mockGetAllDashboardEvents =
      MockGetAllDashboardEventsSortedByDateInteractor();

  when(
    mockGetFoodEvents.execute(dateTime: anyNamed('dateTime')),
  ).thenAnswer((_) async => allEvents);
  when(mockGetWeekFoodEvents.execute()).thenAnswer((_) async => allEvents);
  when(
    mockGetDayCalories.execute(dateTime: anyNamed('dateTime')),
  ).thenAnswer((_) async => 500);
  when(
    mockGetAllDashboardEvents.execute(),
  ).thenAnswer((_) async => DashboardAllCalendarEvents());

  final bloc = DashboardBloc(
    getFoodEventsOfTodayInteractor: mockGetFoodEvents,
    getMasterFileInteractor: MockGetMasterFileInteractor(),
    getAdviceInteractor: MockGetAdviceInteractor(),
    getUserIdInteractor: MockGetUserIdInteractor(),
    getProfileInteractor: MockGetProfileInteractor(),
    getWaterEventsTodayInteractor: MockGetWaterEventsTodayInteractor(),
    isNecessaryToShowExplainingCardInteractor:
        MockIsNecessaryToShowExplainingCardInteractor(),
    saveExplainingCardInteractionInteractor:
        MockSaveExplainingCardInteractionInteractor(),
    getDayCaloriesInteractor: mockGetDayCalories,
    getLiquidEventsOfTodayInteractor: MockGetTodayLiquidEventsInteractor(),
    getWeekFoodEventsInteractor: mockGetWeekFoodEvents,
    getWeekLiquidEventsInteractor: MockGetWeekLiquidEventsInteractor(),
    getWeekSportsInteractor: MockGetWeekSportsInteractor(),
    uploadProfileInteractor: MockUploadProfileInteractor(),
    saveProfileInteractor: MockSaveProfileInteractor(),
    uploadWaterEventInteractor: MockUploadWaterEventInteractor(),
    saveWaterEventInteractor: MockSaveWaterEventInteractor(),
    uploadStepsInteractor: MockUploadStepsInteractor(),
    saveStepsInteractor: MockSaveStepsInteractor(),
    getStepsInteractor: MockGetStepsInteractor(),
    getTodayStepInteractor: MockGetTodayStepInteractor(),
    getAllEventsSortedByDateInteractor:
        MockGetAllEventsSortedByDateInteractor(),
    getTodayCreatineEventInteractor: MockGetTodayCreatineEventInteractor(),
    uploadCreatineEventInteractor: MockUploadCreatineEventInteractor(),
    saveCreatineEventInteractor: MockSaveCreatineEventInteractor(),
    getTodayCollagenEventInteractor: MockGetTodayCollagenEventInteractor(),
    uploadCollagenEventInteractor: MockUploadCollagenEventInteractor(),
    saveCollagenEventInteractor: MockSaveCollagenEventInteractor(),
    getAllDashboardEventsSortedByDateInteractor: mockGetAllDashboardEvents,
    getMasterFilesVersionInteractor: MockGetMasterFileVersionInteractor(),
    manageMasterFilesInteractor: MockManageMasterFilesInteractor(),
    clearAuthPreferencesInteractor: MockClearAuthPreferencesInteractor(),
    eraseDatabaseInteractor: MockEraseDatabaseInteractor(),
    signOutInteractor: MockSignOutInteractor(),
    getRoutinesInteractor: MockGetRoutinesInteractor(),
    eraseDBLocalEventsInteractor: MockEraseDBLocalEventsInteractor(),
    synchronizeEventsInteractor: MockSynchronizeEventsInteractor(),
    updateEventsInteractor: MockUpdateEventsInteractor(),
    chuck: Chuck(showNotification: false),
    showModelAppearanceInteractor: MockShowModelAppearanceInteractor(),
    saveModelAppearanceInteractor: MockSaveModelAppearanceInteractor(),
    getTodaySportsInteractor: MockGetTodaySportsInteractor(),
    getDaySupplementEventsInteractor: MockGetDaySupplementEventsInteractor(),
  );

  // Minimal state so the recompute path doesn't crash on null access —
  // same seeding as dashboard_bloc_test.dart, with the real nutrient info.
  bloc.state.foodEvents = [];
  bloc.state.todayLiquidEvents = [];
  bloc.state.waterEvents = [];
  bloc.state.weeklyFoodEvents = [];
  bloc.state.weeklyLiquidEvents = [];
  bloc.state.weeklySportEvents = [];
  bloc.state.supplementEvents = [];
  bloc.state.userKcal = 2000;
  bloc.state.nutrientsInfoMaster = NutrientsInfoMaster(
    nutrientsInfo: _nutrientsInfoReal,
  );
  bloc.state.supplementsInfoMaster = SupplementsInfoMaster(v: 1, data: []);
  bloc.state.profile = UserProfileModel(
    micronutrients: [],
    temporaryMicronutrients: [],
    userRdas: UserRdas(userRdas: []),
    objectives: [],
    kcal: 2000,
  );

  bloc.add(RefreshCategoryAction(category: DataChangedCategory.food));
  await pumpEventQueue();

  final macros = bloc.state.macronutrients;
  await bloc.close();

  expect(macros, isNotNull, reason: 'Dashboard never built the macro list');
  expect(macros!.length, 3);
  return macros;
}

void main() {
  group('Aggregation through the real blocs', () {
    late ReferenceDatabase db;
    late List<FoodEventComplete> allEvents;

    setUp(() async {
      db = ReferenceDatabase(NativeDatabase.memory());
      allEvents = await enrichMealPlan(db);
    });

    tearDown(() async {
      await db.close();
    });

    group('Meal-level aggregation (MealTimeDetailsBloc) sums raw values', () {
      for (final meal in _meals) {
        test(
          '${meal.name} -> protein ${meal.proteinDisplay}, carbs ${meal.carbsDisplay}, fat ${meal.fatDisplay}',
          () async {
            final macros = await _mealMacros(allEvents, meal);

            expect(
              macros[0].quantityConsumed,
              closeTo(meal.protein, _tolerance),
            );
            expect(macros[1].quantityConsumed, closeTo(meal.carbs, _tolerance));
            expect(macros[2].quantityConsumed, closeTo(meal.fat, _tolerance));

            expect(
              macros[0].quantityConsumed.toNutrientDisplay(),
              meal.proteinDisplay,
              reason:
                  'Meal protein must be the rounded RAW sum. For breakfast, '
                  'summing already-rounded per-food values (8.8 + 76.3) would '
                  'show 85.1 instead of 85.0.',
            );
            expect(
              macros[2].quantityConsumed.toNutrientDisplay(),
              meal.fatDisplay,
              reason:
                  'Meal fat must be the rounded RAW sum. For breakfast, '
                  'summing already-rounded per-food values (7.4 + 11.3) would '
                  'show 18.7 instead of 18.6.',
            );
            expect(
              macros[1].quantityConsumed.toNutrientDisplay(),
              meal.carbsDisplay,
            );
          },
        );
      }
    });

    group('Day-level aggregation (DashboardBloc) sums raw values', () {
      test(
        'day totals -> protein $_dayProteinDisplay, carbs $_dayCarbsDisplay, fat $_dayFatDisplay',
        () async {
          final macros = await dayMacros(allEvents);

          expect(macros[0].quantityConsumed, closeTo(_dayProtein, _tolerance));
          expect(macros[1].quantityConsumed, closeTo(_dayCarbs, _tolerance));
          expect(macros[2].quantityConsumed, closeTo(_dayFat, _tolerance));

          expect(
            macros[0].quantityConsumed.toNutrientDisplay(),
            _dayProteinDisplay,
            reason:
                'Day protein must be the rounded RAW sum (161.76 -> 161.8). '
                'Summing the five display-rounded values gives 161.9 — that is '
                'the rounded-sum bug this test exists to catch.',
          );
          expect(
            macros[1].quantityConsumed.toNutrientDisplay(),
            _dayCarbsDisplay,
          );
          expect(
            macros[2].quantityConsumed.toNutrientDisplay(),
            _dayFatDisplay,
          );
        },
      );
    });
  });

  group('Day totals rendered by NutritionProgressWidget', () {
    testWidgets('paints 161.8 / 122.8 / 67.6 — never the rounded-sum 161.9', (
      tester,
    ) async {
      // Real async zone: Drift + blocs cannot run under testWidgets fake time.
      final macros = await tester.runAsync(() async {
        final widgetDb = ReferenceDatabase(NativeDatabase.memory());
        try {
          final events = await enrichMealPlan(widgetDb);
          return await dayMacros(events);
        } finally {
          await widgetDb.close();
        }
      });

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('es')],
          home: Scaffold(
            body: SingleChildScrollView(
              child: NutritionProgressWidget(
                energyModel: EnergyModel(
                  fractionToFill: 0,
                  totalKcal: 2000,
                  rawKcalTaken: 1754,
                  spentKcal: 0,
                ),
                nutrientsList: macros!,
                selectedDate: DateTime(2026, 7, 16),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining(_dayProteinDisplay, findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining(_dayCarbsDisplay, findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining(_dayFatDisplay, findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('161.9', findRichText: true),
        findsNothing,
        reason:
            '161.9 on screen means the aggregation summed display-rounded '
            'per-food values instead of raw ones.',
      );
    });
  });
}
