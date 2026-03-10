import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/objectives_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/profile_computation_service.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/bloc/meal_time_details_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

class FakeProfileComputationService extends Fake implements ProfileComputationService {
  Map<int, List<String>>? result;

  @override
  Future<Map<int, List<String>>?> getObjectiveNutrientsMap(List<int> objectiveIds) async => result;
}

/// Creates a Params with all 116 positional args (null by default).
/// Pass named overrides for specific nutrients.
Params makeParams({double? calcium, double? iron, double? sodium}) {
  return Params(
    null, null, null, null, null, null, null, null, null, null, // 1-10
    null, null, null, // 11-13: c18_2N_6, c18_3N_3, cadmium
    calcium, // 14: calcium
    null, null, null, null, null, null, null, null, null, null, // 15-24
    null, null, null, null, null, null, null, null, null, null, // 25-34
    null, null, null, // 35-37: histidine, hydroxyproline, iodine
    iron, // 38: iron
    null, null, null, null, null, null, null, null, null, null, // 39-48
    null, null, null, null, null, null, null, null, null, null, // 49-58
    null, null, // 59-60: selenium, serin
    sodium, // 61: sodium
    null, null, null, null, null, null, null, null, null, null, // 62-71
    null, null, null, null, null, null, null, null, null, null, // 72-81
    null, null, null, null, null, null, null, null, null, null, // 82-91
    null, null, null, null, null, null, null, null, null, null, // 92-101
    null, null, null, null, null, null, null, null, null, null, // 102-111
    null, null, null, null, null, // 112-116
  );
}

/// Creates a FoodInfo with all 8 positional args.
FoodInfo makeFoodInfo({Params? params}) {
  return FoodInfo(null, null, null, null, null, null, params, null);
}

void main() {
  late MockGetUserIdInteractor mockGetUserId;
  late MockGetFoodEventsOfTodayInteractor mockGetFoodEventsOfToday;
  late MockGetTodayLiquidEventsInteractor mockGetTodayLiquidEvents;
  late MockGetProfileInteractor mockGetProfile;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockDeleteFoodEventInteractor mockDeleteFoodEvent;
  late MockRemoveFoodEventInteractor mockRemoveFoodEvent;
  late MockUpdateEventsInteractor mockUpdateEvents;
  late MockPreferencesRepository mockPreferencesRepository;
  late FakeProfileComputationService fakeProfileComputation;

  setUp(() {
    mockGetUserId = MockGetUserIdInteractor();
    mockGetFoodEventsOfToday = MockGetFoodEventsOfTodayInteractor();
    mockGetTodayLiquidEvents = MockGetTodayLiquidEventsInteractor();
    mockGetProfile = MockGetProfileInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockDeleteFoodEvent = MockDeleteFoodEventInteractor();
    mockRemoveFoodEvent = MockRemoveFoodEventInteractor();
    mockUpdateEvents = MockUpdateEventsInteractor();
    mockPreferencesRepository = MockPreferencesRepository();
    fakeProfileComputation = FakeProfileComputationService();
  });

  /// Stubs all mocks needed for the full init flow.
  void stubInitMocks({
    UserProfileModel? profile,
    List<NutrientInfoMaster>? nutrientsInfo,
    List<FoodEventComplete>? foodEvents,
    Map<int, List<String>>? objectiveNutrientsMap,
  }) {
    when(mockGetUserId.execute()).thenReturn('user123');
    when(mockGetProfile.execute()).thenAnswer((_) async =>
        profile ?? UserProfileModel(userId: 'user123'));
    when(mockGetMasterFile.execute(MasterFilesType.nutrientsInfo))
        .thenAnswer((_) async => NutrientsInfoMaster(nutrientsInfo: nutrientsInfo ?? []));
    when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
        .thenAnswer((_) async => FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(foodNames: [], drinkNames: [])));
    when(mockGetMasterFile.execute(MasterFilesType.unitsInfo))
        .thenAnswer((_) async => UnitsInfoMaster(unitsInfoMaster: []));
    when(mockGetMasterFile.execute(MasterFilesType.objectivesInfo))
        .thenAnswer((_) async => ObjectivesInfoMaster(objectives: [], metabolicObjectives: [], bodyCompositionObjectives: []));
    when(mockGetFoodEventsOfToday.execute(dateTime: anyNamed('dateTime')))
        .thenAnswer((_) async => foodEvents ?? <FoodEventComplete>[]);
    when(mockGetTodayLiquidEvents.execute(dateTime: anyNamed('dateTime')))
        .thenAnswer((_) async => <LiquidEventComplete>[]);
    when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
        .thenAnswer((_) async => false);
    fakeProfileComputation.result = objectiveNutrientsMap;
  }

  MealTimeDetailsBloc buildBloc() => MealTimeDetailsBloc(
        getUserIdInteractor: mockGetUserId,
        getFoodEventsOfTodayInteractor: mockGetFoodEventsOfToday,
        getLiquidEventsOfTodayInteractor: mockGetTodayLiquidEvents,
        getProfileInteractor: mockGetProfile,
        getMasterFileInteractor: mockGetMasterFile,
        deleteFoodEventInteractor: mockDeleteFoodEvent,
        removeFoodEventInteractor: mockRemoveFoodEvent,
        updateEventsInteractor: mockUpdateEvents,
        preferencesRepository: mockPreferencesRepository,
        profileComputationService: fakeProfileComputation,
      );

  group('MealTimeDetailsBloc - DeleteFoodMealTimeDetailsEventAction', () {
    blocTest<MealTimeDetailsBloc, MealTimeDetailsState>(
      'delete succeeds without triggering sync',
      build: () {
        stubInitMocks();
        when(mockDeleteFoodEvent.execute(any, any)).thenAnswer((_) async => true);
        when(mockRemoveFoodEvent.execute(any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) async {
        // First init to populate state (nutrientsInfoMaster, profile, etc.)
        bloc.add(InitialMealTimeDetailsEventState(dateTime: DateTime(2026, 3, 1)));
        await Future.delayed(const Duration(milliseconds: 300));
        // Reset mock call counts so we can verify delete doesn't trigger sync
        clearInteractions(mockUpdateEvents);
        // Now delete
        bloc.add(DeleteFoodMealTimeDetailsEventAction(
          foodEventComplete: FoodEventComplete(
            userId: 'user123',
            eventId: 1,
            mealType: 0,
          ),
          onFinish: () {},
        ));
      },
      verify: (bloc) {
        verify(mockDeleteFoodEvent.execute(any, any)).called(1);
        verify(mockRemoveFoodEvent.execute(any)).called(1);
        // Must NOT trigger sync after delete — otherwise deleted item reappears
        verifyNever(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')));
      },
    );

    blocTest<MealTimeDetailsBloc, MealTimeDetailsState>(
      'delete emits error when remote delete fails',
      build: () {
        when(mockDeleteFoodEvent.execute(any, any)).thenThrow(Exception('fail'));
        when(mockRemoveFoodEvent.execute(any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteFoodMealTimeDetailsEventAction(
        foodEventComplete: FoodEventComplete(
          userId: 'user123',
          eventId: 1,
          mealType: 0,
        ),
        onFinish: () {},
      )),
      expect: () => [
        isA<MealTimeDetailsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MealTimeDetailsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteFoodEventError),
      ],
    );

    blocTest<MealTimeDetailsBloc, MealTimeDetailsState>(
      'delete emits error when local remove fails',
      build: () {
        when(mockDeleteFoodEvent.execute(any, any)).thenAnswer((_) async => true);
        when(mockRemoveFoodEvent.execute(any)).thenThrow(Exception('local fail'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteFoodMealTimeDetailsEventAction(
        foodEventComplete: FoodEventComplete(
          userId: 'user123',
          eventId: 1,
          mealType: 0,
        ),
        onFinish: () {},
      )),
      expect: () => [
        isA<MealTimeDetailsState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MealTimeDetailsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.removeFoodEventError),
      ],
    );
  });

  group('MealTimeDetailsBloc - Micronutrients grouping', () {
    blocTest<MealTimeDetailsBloc, MealTimeDetailsState>(
      'builds grouped objective nutrients after init',
      build: () {
        stubInitMocks(
          profile: UserProfileModel(
            userId: 'user123',
            objectives: [1, 2],
            userAll: ['calcium', 'vitD', 'iron', 'vitB12'],
            userRdas: UserRdas(userRdas: []),
          ),
          nutrientsInfo: [
            NutrientInfoMaster(officialName: 'calcium', unit: 'mg', en: 'Calcium', es: 'Calcio'),
            NutrientInfoMaster(officialName: 'vitD', unit: 'µg', en: 'Vitamin D', es: 'Vitamina D'),
            NutrientInfoMaster(officialName: 'iron', unit: 'mg', en: 'Iron', es: 'Hierro'),
            NutrientInfoMaster(officialName: 'vitB12', unit: 'µg', en: 'Vitamin B12', es: 'Vitamina B12'),
            NutrientInfoMaster(officialName: 'sodium', unit: 'mg', en: 'Sodium', es: 'Sodio'),
          ],
          foodEvents: [
            FoodEventComplete(
              userId: 'user123',
              eventId: 1,
              mealType: 0,
              foodInfo: [
                makeFoodInfo(params: makeParams(calcium: 320.0, iron: 8.0)),
              ],
            ),
          ],
          objectiveNutrientsMap: {
            1: ['calcium', 'vitD'],
            2: ['iron', 'vitB12'],
          },
        );
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(UpdateFoodArgumentsModelEventState(
          foodArgumentsModel: FoodArgumentsModel(mealTime: MealTime(id: 0), selectedDateTime: DateTime(2026, 3, 1)),
        ));
        await Future.delayed(const Duration(milliseconds: 300));
      },
      verify: (bloc) {
        final state = bloc.state;
        // Grouped objective nutrients should be populated
        expect(state.groupedObjectiveNutrients, isNotNull);
        expect(state.groupedObjectiveNutrients!.keys, containsAll([1, 2]));

        // Objective 1: calcium has value 320, vitD is 0 → only calcium
        final obj1Nutrients = state.groupedObjectiveNutrients![1]!;
        expect(obj1Nutrients.length, 1);
        expect(obj1Nutrients[0].nutrientInfoMaster.officialName, 'calcium');
        expect(obj1Nutrients[0].quantityConsumed, 320.0);

        // Objective 2: iron has value 8, vitB12 is 0 → only iron
        final obj2Nutrients = state.groupedObjectiveNutrients![2]!;
        expect(obj2Nutrients.length, 1);
        expect(obj2Nutrients[0].nutrientInfoMaster.officialName, 'iron');
        expect(obj2Nutrients[0].quantityConsumed, 8.0);
      },
    );

    blocTest<MealTimeDetailsBloc, MealTimeDetailsState>(
      'other micronutrients excludes objective nutrients',
      build: () {
        stubInitMocks(
          profile: UserProfileModel(
            userId: 'user123',
            objectives: [1],
            userAll: ['calcium'],
            userRdas: UserRdas(userRdas: []),
          ),
          nutrientsInfo: [
            NutrientInfoMaster(officialName: 'calcium', unit: 'mg', en: 'Calcium', es: 'Calcio'),
            NutrientInfoMaster(officialName: 'sodium', unit: 'mg', en: 'Sodium', es: 'Sodio'),
            NutrientInfoMaster(officialName: 'vitC', unit: 'mg', en: 'Vitamin C', es: 'Vitamina C'),
          ],
          foodEvents: [
            FoodEventComplete(
              userId: 'user123',
              eventId: 1,
              mealType: 0,
              foodInfo: [
                makeFoodInfo(params: makeParams(calcium: 500.0)),
              ],
            ),
          ],
          objectiveNutrientsMap: {
            1: ['calcium'],
          },
        );
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(UpdateFoodArgumentsModelEventState(
          foodArgumentsModel: FoodArgumentsModel(mealTime: MealTime(id: 0), selectedDateTime: DateTime(2026, 3, 1)),
        ));
        await Future.delayed(const Duration(milliseconds: 300));
      },
      verify: (bloc) {
        final state = bloc.state;
        expect(state.otherMicronutrients, isNotNull);
        // calcium is in objectives → should NOT appear in other
        final otherNames = state.otherMicronutrients!.map((n) => n.nutrientInfoMaster.officialName).toList();
        expect(otherNames, isNot(contains('calcium')));
      },
    );

    blocTest<MealTimeDetailsBloc, MealTimeDetailsState>(
      'handles null objective nutrients map gracefully',
      build: () {
        stubInitMocks(
          profile: UserProfileModel(userId: 'user123', userAll: [], userRdas: UserRdas(userRdas: [])),
          objectiveNutrientsMap: null,
        );
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(UpdateFoodArgumentsModelEventState(
          foodArgumentsModel: FoodArgumentsModel(mealTime: MealTime(id: 0), selectedDateTime: DateTime(2026, 3, 1)),
        ));
        await Future.delayed(const Duration(milliseconds: 300));
      },
      verify: (bloc) {
        // Should not crash, groupedObjectiveNutrients stays null
        expect(bloc.state.groupedObjectiveNutrients, isNull);
        expect(bloc.state.otherMicronutrients, isNotNull);
      },
    );
  });
}
