import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/liquidevents/liquid_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/utils/prefs_keys.dart';
import 'package:nutrenaissance_flutter/presentation/mealtimedetails/bloc/meal_time_details_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

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
  });

  /// Stubs all mocks needed for the full init flow.
  void stubInitMocks() {
    when(mockGetUserId.execute()).thenReturn('user123');
    when(mockGetProfile.execute()).thenAnswer((_) async => UserProfileModel(userId: 'user123'));
    when(mockGetMasterFile.execute(MasterFilesType.nutrientsInfo))
        .thenAnswer((_) async => NutrientsInfoMaster(nutrientsInfo: []));
    when(mockGetMasterFile.execute(MasterFilesType.foodsAndDrinksNames))
        .thenAnswer((_) async => FoodsAndDrinksNamesMaster(FoodsAndDrinkListsMaster(foodNames: [], drinkNames: [])));
    when(mockGetMasterFile.execute(MasterFilesType.unitsInfo))
        .thenAnswer((_) async => UnitsInfoMaster(unitsInfoMaster: []));
    when(mockGetFoodEventsOfToday.execute(dateTime: anyNamed('dateTime')))
        .thenAnswer((_) async => <FoodEventComplete>[]);
    when(mockGetTodayLiquidEvents.execute(dateTime: anyNamed('dateTime')))
        .thenAnswer((_) async => <LiquidEventComplete>[]);
    when(mockUpdateEvents.execute(userId: anyNamed('userId'), categoryType: anyNamed('categoryType'), fullSync: anyNamed('fullSync')))
        .thenAnswer((_) async => false);
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
}
