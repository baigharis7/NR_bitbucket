import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_arguments_model.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_actions.dart';
import 'package:nutrenaissance_flutter/presentation/foodevent/bloc/add_food_event_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetUserIdInteractor mockGetUserId;
  late MockSaveFoodEventInteractor mockSaveFoodEvent;
  late MockUploadFoodEventInteractor mockUploadFoodEvent;
  late MockGetMasterFileInteractor mockGetMasterFile;
  late MockGetFoodFavoritesInteractor mockGetFoodFavorites;
  late MockGetWeekFoodEventsInteractor mockGetWeekFoodEvents;
  late MockUploadFoodFavoriteInteractor mockUploadFoodFavorite;
  late MockSaveFoodFavoriteInteractor mockSaveFoodFavorite;
  late MockUploadFoodRoutineInteractor mockUploadFoodRoutine;
  late MockSaveFoodRoutineInteractor mockSaveFoodRoutine;
  late MockDeleteFoodFavoriteInteractor mockDeleteFoodFavorite;
  late MockRemoveFoodFavoriteFromLocalInteractor mockRemoveFoodFavoriteFromLocal;
  late MockGetRecentFoodItemsInteractor mockGetRecentFoodItems;

  setUp(() {
    mockGetUserId = MockGetUserIdInteractor();
    mockSaveFoodEvent = MockSaveFoodEventInteractor();
    mockUploadFoodEvent = MockUploadFoodEventInteractor();
    mockGetMasterFile = MockGetMasterFileInteractor();
    mockGetFoodFavorites = MockGetFoodFavoritesInteractor();
    mockGetWeekFoodEvents = MockGetWeekFoodEventsInteractor();
    mockUploadFoodFavorite = MockUploadFoodFavoriteInteractor();
    mockSaveFoodFavorite = MockSaveFoodFavoriteInteractor();
    mockUploadFoodRoutine = MockUploadFoodRoutineInteractor();
    mockSaveFoodRoutine = MockSaveFoodRoutineInteractor();
    mockDeleteFoodFavorite = MockDeleteFoodFavoriteInteractor();
    mockRemoveFoodFavoriteFromLocal = MockRemoveFoodFavoriteFromLocalInteractor();
    mockGetRecentFoodItems = MockGetRecentFoodItemsInteractor();
  });

  AddFoodEventBloc buildBloc() => AddFoodEventBloc(
        getUserIdInteractor: mockGetUserId,
        saveFoodEventInteractor: mockSaveFoodEvent,
        uploadFoodEventInteractor: mockUploadFoodEvent,
        getMasterFileInteractor: mockGetMasterFile,
        getFoodFavoritesInteractor: mockGetFoodFavorites,
        getWeekFoodEventsInteractor: mockGetWeekFoodEvents,
        uploadFoodFavoriteInteractor: mockUploadFoodFavorite,
        saveFoodFavoriteInteractor: mockSaveFoodFavorite,
        uploadFoodRoutineInteractor: mockUploadFoodRoutine,
        saveFoodRoutineInteractor: mockSaveFoodRoutine,
        deleteFoodFavoriteInteractor: mockDeleteFoodFavorite,
        removeFoodFavoriteFromLocalInteractor: mockRemoveFoodFavoriteFromLocal,
        getRecentFoodItemsInteractor: mockGetRecentFoodItems,
      );

  group('AddFoodEventBloc', () {
    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'initial state has empty food names and isLoading false',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.foodNames!.foodsAndDrinksNames!.foodNames, isEmpty);
        expect(bloc.state.isEdit, false);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateEventDateEventAction sets eventDate on foodEvent',
      build: buildBloc,
      act: (bloc) {
        final date = DateTime(2026, 3, 10);
        bloc.add(UpdateEventDateEventAction(dateTime: date));
      },
      verify: (bloc) {
        expect(bloc.state.foodEvent!.eventDate, DateTime(2026, 3, 10).millisecondsSinceEpoch);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'AddFoodNameEventAction sets title on foodEvent',
      build: buildBloc,
      act: (bloc) => bloc.add(AddFoodNameEventAction(foodName: 'Chicken Salad')),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.title, 'Chicken Salad');
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'AddFoodMealTypeEventAction sets mealType on foodEvent',
      build: buildBloc,
      act: (bloc) => bloc.add(AddFoodMealTypeEventAction(mealType: 2)),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.mealTime, 2);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateIsFavoriteEventAction toggles isFavorite',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateIsFavoriteEventAction()),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.isFavorite, true);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateIsFavoriteEventAction toggles isFavorite off when already true',
      build: () {
        final bloc = buildBloc();
        bloc.state.foodEvent!.isFavorite = true;
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateIsFavoriteEventAction()),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.isFavorite, false);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateIsCreateRoutineEventAction toggles isRoutine',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateIsCreateRoutineEventAction()),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.isRoutine, true);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateIsCreateRoutineEventAction auto-initializes time for snack routines',
      build: () {
        final bloc = buildBloc();
        bloc.state.foodEvent!.mealTime = 3; // Snack
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateIsCreateRoutineEventAction()),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.isRoutine, true);
        expect(bloc.state.foodEvent!.time, isNotNull);
        expect(bloc.state.foodEvent!.time!.isNotEmpty, true);
        expect(bloc.state.foodEvent!.time!.contains(':'), true);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateIsCreateRoutineEventAction does not auto-init time for non-snack routines',
      build: () {
        final bloc = buildBloc();
        bloc.state.foodEvent!.mealTime = 1; // Lunch
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateIsCreateRoutineEventAction()),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.isRoutine, true);
        // Non-snack food routines do not get auto-initialized time
        expect(bloc.state.foodEvent!.time, isNull);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateIsCreateRoutineEventAction does not overwrite existing snack time',
      build: () {
        final bloc = buildBloc();
        bloc.state.foodEvent!.mealTime = 3; // Snack
        bloc.state.foodEvent!.time = '16:00';
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateIsCreateRoutineEventAction()),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.time, '16:00');
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateCreteDishEventAction toggles dish flag',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateCreteDishEventAction()),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.dish, true);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateScheduleTimeAddFoodEventActions sets time',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateScheduleTimeAddFoodEventActions(scheduleTime: '12:30')),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.time, '12:30');
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateDaysOfWeekEventAction adds day to list',
      build: buildBloc,
      act: (bloc) => bloc.add(UpdateDaysOfWeekEventAction(day: 5)),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.daysOfWeek, contains(5));
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'UpdateDaysOfWeekEventAction toggles day off when already present',
      build: () {
        final bloc = buildBloc();
        bloc.state.foodEvent!.daysOfWeek = [2, 5];
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateDaysOfWeekEventAction(day: 5)),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.daysOfWeek, isNot(contains(5)));
        expect(bloc.state.foodEvent!.daysOfWeek, contains(2));
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'ResetFoodEventInfoAction clears error and isEdit',
      build: () {
        final bloc = buildBloc();
        bloc.state.isEdit = true;
        return bloc;
      },
      act: (bloc) => bloc.add(ResetFoodEventInfoAction()),
      expect: () => [
        isA<AddFoodEventState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', null)
            .having((s) => s.isEdit, 'isEdit', false),
      ],
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'AddFoodArgumentModelEventAction with preSelectRoutine sets isRoutine true',
      build: buildBloc,
      act: (bloc) => bloc.add(AddFoodArgumentModelEventAction(
        foodArgumentsModel: FoodArgumentsModel(
          mealTime: MealTime(id: 0, name: 'Breakfast', time: '08:00'),
          selectedDateTime: DateTime(2026, 2, 25),
          preSelectRoutine: true,
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.isRoutine, true);
        expect(bloc.state.foodEvent!.isFavorite, isNot(true));
        expect(bloc.state.foodEvent!.mealTime, 0);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'AddFoodArgumentModelEventAction with preSelectFavorite sets isFavorite true',
      build: buildBloc,
      act: (bloc) => bloc.add(AddFoodArgumentModelEventAction(
        foodArgumentsModel: FoodArgumentsModel(
          mealTime: MealTime(id: 1, name: 'Lunch', time: '12:00'),
          selectedDateTime: DateTime(2026, 2, 25),
          preSelectFavorite: true,
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.isFavorite, true);
        expect(bloc.state.foodEvent!.isRoutine, isNot(true));
        expect(bloc.state.foodEvent!.mealTime, 1);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'AddFoodArgumentModelEventAction without preselect keeps both unset',
      build: buildBloc,
      act: (bloc) => bloc.add(AddFoodArgumentModelEventAction(
        foodArgumentsModel: FoodArgumentsModel(
          mealTime: MealTime(id: 2, name: 'Dinner', time: '19:00'),
          selectedDateTime: DateTime(2026, 2, 25),
        ),
      )),
      verify: (bloc) {
        expect(bloc.state.foodEvent!.isFavorite, isNot(true));
        expect(bloc.state.foodEvent!.isRoutine, isNot(true));
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'initial state has favRecentTab = 0 (Recent)',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.favRecentTab, 0);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'SwitchFavRecentTabAction updates favRecentTab in state',
      build: buildBloc,
      act: (bloc) => bloc.add(SwitchFavRecentTabAction(tabIndex: 1)),
      verify: (bloc) {
        expect(bloc.state.favRecentTab, 1);
      },
    );

    blocTest<AddFoodEventBloc, AddFoodEventState>(
      'SwitchFavRecentTabAction switches back to Recent tab',
      build: buildBloc,
      seed: () => AddFoodEventState(isLoading: false, favRecentTab: 1),
      act: (bloc) => bloc.add(SwitchFavRecentTabAction(tabIndex: 0)),
      verify: (bloc) {
        expect(bloc.state.favRecentTab, 0);
      },
    );
  });
}
