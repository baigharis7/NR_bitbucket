import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_actions.dart';
import 'package:nutrenaissance_flutter/presentation/journal/bloc/journal_food_state.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetFoodEventsOfTodayInteractor mockGetFoodEventsOfToday;
  late MockGetFoodFavoritesInteractor mockGetFoodFavorites;
  late MockGetWeekFoodEventsInteractor mockGetWeekFoodEvents;
  late MockGetUserKcalInteractor mockGetUserKcal;
  late MockIsNecessaryToShowExplainingCardInteractor mockIsNecessaryToShowExplainingCard;
  late MockSaveExplainingCardInteractionInteractor mockSaveExplainingCardInteraction;
  late MockSaveFoodFavoriteInteractor mockSaveFoodFavorite;
  late MockUploadFoodFavoriteInteractor mockUploadFoodFavorite;
  late MockGetUserIdInteractor mockGetUserId;
  late MockRemoveFoodFavoriteFromLocalInteractor mockRemoveFoodFavoriteFromLocal;
  late MockDeleteFoodFavoriteInteractor mockDeleteFoodFavorite;
  late MockDeleteFoodEventInteractor mockDeleteFoodEvent;
  late MockRemoveFoodEventInteractor mockRemoveFoodEvent;

  setUp(() {
    mockGetFoodEventsOfToday = MockGetFoodEventsOfTodayInteractor();
    mockGetFoodFavorites = MockGetFoodFavoritesInteractor();
    mockGetWeekFoodEvents = MockGetWeekFoodEventsInteractor();
    mockGetUserKcal = MockGetUserKcalInteractor();
    mockIsNecessaryToShowExplainingCard = MockIsNecessaryToShowExplainingCardInteractor();
    mockSaveExplainingCardInteraction = MockSaveExplainingCardInteractionInteractor();
    mockSaveFoodFavorite = MockSaveFoodFavoriteInteractor();
    mockUploadFoodFavorite = MockUploadFoodFavoriteInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockRemoveFoodFavoriteFromLocal = MockRemoveFoodFavoriteFromLocalInteractor();
    mockDeleteFoodFavorite = MockDeleteFoodFavoriteInteractor();
    mockDeleteFoodEvent = MockDeleteFoodEventInteractor();
    mockRemoveFoodEvent = MockRemoveFoodEventInteractor();
  });

  JournalFoodBloc buildBloc() => JournalFoodBloc(
        getFoodEventsOfTodayInteractor: mockGetFoodEventsOfToday,
        getFoodFavoritesInteractor: mockGetFoodFavorites,
        getWeekFoodEventsInteractor: mockGetWeekFoodEvents,
        getUserKcalInteractor: mockGetUserKcal,
        isNecessaryToShowExplainingCardInteractor: mockIsNecessaryToShowExplainingCard,
        saveExplainingCardInteractionInteractor: mockSaveExplainingCardInteraction,
        saveFoodFavoriteInteractor: mockSaveFoodFavorite,
        uploadFoodFavoriteInteractor: mockUploadFoodFavorite,
        getUserIdInteractor: mockGetUserId,
        removeFoodFavoriteFromLocalInteractor: mockRemoveFoodFavoriteFromLocal,
        deleteFoodFavoriteInteractor: mockDeleteFoodFavorite,
        deleteFoodEventInteractor: mockDeleteFoodEvent,
        removeFoodEventInteractor: mockRemoveFoodEvent,
      );

  group('JournalFoodBloc', () {
    blocTest<JournalFoodBloc, JournalFoodState>(
      'initial state is not loading with empty lists',
      build: buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, false);
        expect(bloc.state.todayFoodEvents, isEmpty);
        expect(bloc.state.foodFavorites, isEmpty);
        expect(bloc.state.weeklyData, isEmpty);
        expect(bloc.state.userKcal, 0);
        expect(bloc.state.showCard, false);
      },
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'InitializeStateAction loads all data',
      build: () {
        when(mockGetUserKcal.execute()).thenAnswer((_) async => 2000);
        when(mockGetFoodEventsOfToday.execute()).thenAnswer((_) async => <FoodEventComplete>[]);
        when(mockGetFoodFavorites.execute()).thenAnswer((_) async => <FoodFavorite>[]);
        when(mockGetWeekFoodEvents.execute()).thenAnswer((_) async => <FoodEventComplete>[]);
        when(mockIsNecessaryToShowExplainingCard.execute(any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(InitializeStateAction()),
      expect: () => [
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        expect(bloc.state.userKcal, 2000);
        expect(bloc.state.showCard, true);
        verify(mockGetUserKcal.execute()).called(1);
        verify(mockGetFoodEventsOfToday.execute()).called(1);
        verify(mockGetFoodFavorites.execute()).called(1);
        verify(mockGetWeekFoodEvents.execute()).called(1);
        verify(mockIsNecessaryToShowExplainingCard.execute(any)).called(1);
      },
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'HideExplainingCardAction sets showCard to false and saves interaction',
      build: () {
        when(mockSaveExplainingCardInteraction.execute(any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      seed: () => JournalFoodState(isLoading: false, showCard: true, todayFoodEvents: [], foodFavorites: [], weeklyData: [], userKcal: 0),
      act: (bloc) => bloc.add(HideExplainingCardAction()),
      verify: (bloc) {
        expect(bloc.state.showCard, false);
        verify(mockSaveExplainingCardInteraction.execute(any)).called(1);
      },
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'AddFoodNameAction sets favoriteName',
      build: buildBloc,
      act: (bloc) => bloc.add(AddFoodNameAction(name: 'My Recipe')),
      verify: (bloc) {
        expect(bloc.state.favoriteName, 'My Recipe');
      },
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'AddMealTimeAction sets mealTime',
      build: buildBloc,
      act: (bloc) => bloc.add(AddMealTimeAction(mealTime: 2)),
      verify: (bloc) {
        expect(bloc.state.mealTime, 2);
      },
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'FinishAddingFavoriteAction uploads and saves favorite on success',
      build: () {
        when(mockUploadFoodFavorite.execute(any)).thenAnswer((_) async => true);
        when(mockSaveFoodFavorite.execute(any, any)).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) {
        var called = false;
        bloc.add(FinishAddingFavoriteAction(
          foodEvent: FoodEventComplete(
            userId: 'user1',
            eventDate: 1000,
            eventId: 1,
            foodName: 'Test Food',
            mealType: 1,
            foodInfo: [],
          ),
          onFinish: () { called = true; },
        ));
      },
      expect: () => [
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockUploadFoodFavorite.execute(any)).called(1);
        verify(mockSaveFoodFavorite.execute(any, false)).called(1);
      },
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'FinishAddingFavoriteAction emits upload error when upload fails',
      build: () {
        when(mockUploadFoodFavorite.execute(any)).thenThrow(Exception('upload failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(FinishAddingFavoriteAction(
        foodEvent: FoodEventComplete(
          userId: 'user1',
          eventDate: 1000,
          eventId: 1,
          foodName: 'Test Food',
          mealType: 1,
          foodInfo: [],
        ),
        onFinish: () {},
      )),
      expect: () => [
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalFoodState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.uploadFoodFavoriteError),
      ],
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'DeleteFoodEventAction deletes remotely and locally on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteFoodEvent.execute(any, any)).thenAnswer((_) async => true);
        when(mockRemoveFoodEvent.execute(any)).thenAnswer((_) async => true);
        when(mockGetFoodFavorites.execute()).thenAnswer((_) async => <FoodFavorite>[]);
        return buildBloc();
      },
      act: (bloc) {
        var called = false;
        bloc.add(DeleteFoodEventAction(
          foodEventComplete: FoodEventComplete(userId: 'user123', eventDate: 1000, eventId: 1),
          onFinish: () { called = true; },
        ));
      },
      expect: () => [
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockDeleteFoodEvent.execute('user123', 1)).called(1);
        verify(mockRemoveFoodEvent.execute(any)).called(1);
        verify(mockGetFoodFavorites.execute()).called(1);
      },
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'DeleteFoodEventAction emits error when remote delete fails',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteFoodEvent.execute(any, any)).thenThrow(Exception('network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(DeleteFoodEventAction(
        foodEventComplete: FoodEventComplete(userId: 'user123', eventDate: 1000, eventId: 1),
        onFinish: () {},
      )),
      expect: () => [
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalFoodState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', ErrorTypes.deleteFoodFavoriteError),
      ],
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'RemoveFavoriteAction deletes remotely and removes locally on success',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user123');
        when(mockDeleteFoodFavorite.execute(any, any)).thenAnswer((_) async => true);
        when(mockRemoveFoodFavoriteFromLocal.execute(any)).thenAnswer((_) async => true);
        when(mockGetFoodFavorites.execute()).thenAnswer((_) async => <FoodFavorite>[]);
        return buildBloc();
      },
      act: (bloc) {
        var called = false;
        bloc.add(RemoveFavoriteAction(
          foodFavorite: FoodFavorite(title: 'Fav', eventDate: 500, ingredients: [], drinks: [], mealTime: 1),
          onFinish: () { called = true; },
        ));
      },
      expect: () => [
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', true),
        isA<JournalFoodState>().having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        verify(mockDeleteFoodFavorite.execute('user123', 500)).called(1);
        verify(mockRemoveFoodFavoriteFromLocal.execute(any)).called(1);
      },
    );

    blocTest<JournalFoodBloc, JournalFoodState>(
      'RemoveFavoriteAction does nothing when foodFavorite is null',
      build: buildBloc,
      act: (bloc) => bloc.add(RemoveFavoriteAction(foodFavorite: null, onFinish: () {})),
      expect: () => [],
    );
  });
}
