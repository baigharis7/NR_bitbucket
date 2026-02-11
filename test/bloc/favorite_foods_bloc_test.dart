import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_state.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_bloc.dart';

import 'bloc_test_mocks.mocks.dart';

void main() {
  late MockGetFoodFavoritesInteractor mockGetFavorites;
  late MockGetUserIdInteractor mockGetUserId;
  late MockDeleteFoodFavoriteInteractor mockDeleteFavorite;
  late MockRemoveFoodFavoriteFromLocalInteractor mockRemoveLocal;
  late MockIsNecessaryToShowExplainingCardInteractor mockShowCard;
  late MockSaveExplainingCardInteractionInteractor mockSaveCard;

  setUp(() {
    mockGetFavorites = MockGetFoodFavoritesInteractor();
    mockGetUserId = MockGetUserIdInteractor();
    mockDeleteFavorite = MockDeleteFoodFavoriteInteractor();
    mockRemoveLocal = MockRemoveFoodFavoriteFromLocalInteractor();
    mockShowCard = MockIsNecessaryToShowExplainingCardInteractor();
    mockSaveCard = MockSaveExplainingCardInteractionInteractor();
  });

  FavoriteFoodsBloc _buildBloc() => FavoriteFoodsBloc(
        getFoodFavoritesInteractor: mockGetFavorites,
        getUserIdInteractor: mockGetUserId,
        deleteFoodFavoriteInteractor: mockDeleteFavorite,
        removeFoodFavoriteFromLocalInteractor: mockRemoveLocal,
        isNecessaryToShowExplainingCardInteractor: mockShowCard,
        saveExplainingCardInteractionInteractor: mockSaveCard,
      );

  FoodFavorite _testFavorite({int? eventDate, int? mealTime}) => FoodFavorite(
    ingredients: [],
    drinks: [],
    mealTime: mealTime ?? 0,
    userId: 'user1',
    eventId: 1,
    eventDate: eventDate ?? 1700000000,
    title: 'Test Favorite',
  );

  group('FavoriteFoodsBloc', () {
    blocTest<FavoriteFoodsBloc, FavoriteFoodsState>(
      'initial state has empty favorites and showCard false',
      build: _buildBloc,
      verify: (bloc) {
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.foodFavorites, isEmpty);
        expect(bloc.state.showCard, isFalse);
      },
    );

    blocTest<FavoriteFoodsBloc, FavoriteFoodsState>(
      'InitializeState loads favorites and card visibility',
      build: () {
        when(mockGetFavorites.execute())
            .thenAnswer((_) async => [_testFavorite()]);
        when(mockShowCard.execute(ExplainingCardRefs.addFoodFavorite.index))
            .thenAnswer((_) async => true);
        return _buildBloc();
      },
      act: (bloc) => bloc.add(InitializeState()),
      expect: () => [
        isA<FavoriteFoodsState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<FavoriteFoodsState>()
            .having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (bloc) {
        expect(bloc.state.foodFavorites?.length, 1);
        expect(bloc.state.showCard, isTrue);
      },
    );

    blocTest<FavoriteFoodsBloc, FavoriteFoodsState>(
      'RemoveFavoriteAction success deletes remote + local and calls onFinish',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user1');
        when(mockDeleteFavorite.execute(any, any))
            .thenAnswer((_) async => true);
        when(mockRemoveLocal.execute(any)).thenAnswer((_) async => true);
        when(mockGetFavorites.execute()).thenAnswer((_) async => []);
        return _buildBloc();
      },
      act: (bloc) {
        bool finished = false;
        bloc.add(RemoveFavoriteAction(
          foodFavorite: _testFavorite(),
          onFinish: () => finished = true,
        ));
        return Future.delayed(
          const Duration(milliseconds: 100),
          () => expect(finished, isTrue),
        );
      },
      expect: () => [
        isA<FavoriteFoodsState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<FavoriteFoodsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError', isNull),
      ],
    );

    blocTest<FavoriteFoodsBloc, FavoriteFoodsState>(
      'RemoveFavoriteAction remote delete error emits deleteFoodFavoriteError',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user1');
        when(mockDeleteFavorite.execute(any, any))
            .thenThrow(Exception('network error'));
        return _buildBloc();
      },
      act: (bloc) => bloc.add(RemoveFavoriteAction(
        foodFavorite: _testFavorite(),
        onFinish: () {},
      )),
      expect: () => [
        isA<FavoriteFoodsState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<FavoriteFoodsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError',
                ErrorTypes.deleteFoodFavoriteError),
      ],
    );

    blocTest<FavoriteFoodsBloc, FavoriteFoodsState>(
      'RemoveFavoriteAction local remove error emits removeFoodFavoriteError',
      build: () {
        when(mockGetUserId.execute()).thenReturn('user1');
        when(mockDeleteFavorite.execute(any, any))
            .thenAnswer((_) async => true);
        when(mockRemoveLocal.execute(any))
            .thenThrow(Exception('local db error'));
        return _buildBloc();
      },
      act: (bloc) => bloc.add(RemoveFavoriteAction(
        foodFavorite: _testFavorite(),
        onFinish: () {},
      )),
      expect: () => [
        isA<FavoriteFoodsState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<FavoriteFoodsState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.onError, 'onError',
                ErrorTypes.removeFoodFavoriteError),
      ],
    );

    blocTest<FavoriteFoodsBloc, FavoriteFoodsState>(
      'HideExplainingCardAction sets showCard false and saves',
      build: _buildBloc,
      act: (bloc) => bloc.add(HideExplainingCardAction()),
      verify: (bloc) {
        expect(bloc.state.showCard, isFalse);
        verify(mockSaveCard
                .execute(ExplainingCardRefs.addFoodFavorite.index))
            .called(1);
      },
    );
  });
}
