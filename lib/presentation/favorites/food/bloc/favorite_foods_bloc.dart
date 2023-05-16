import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/is_necessary_to_show_explaining_card_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/explainingcards/save_explaining_card_interaction_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/explainingcards/explaining_card_model.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/food/bloc/favorite_foods_state.dart';

class FavoriteFoodsBloc extends BaseBloc<FavoriteFoodsActions, FavoriteFoodsState> {
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final DeleteFoodFavoriteInteractor deleteFoodFavoriteInteractor;
  final RemoveFoodFavoriteFromLocalInteractor removeFoodFavoriteFromLocalInteractor;
  final IsNecessaryToShowExplainingCardInteractor isNecessaryToShowExplainingCardInteractor;
  final SaveExplainingCardInteractionInteractor saveExplainingCardInteractionInteractor;

  FavoriteFoodsBloc({
    required this.getFoodFavoritesInteractor,
    required this.getUserIdInteractor,
    required this.removeFoodFavoriteFromLocalInteractor,
    required this.deleteFoodFavoriteInteractor,
    required this.isNecessaryToShowExplainingCardInteractor,
    required this.saveExplainingCardInteractionInteractor,
  }) : super(FavoriteFoodsState(
    isLoading: false,
    onError: null,
    foodFavorites: [],
    showCard: false,
  ),) {
    on<InitializeState>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.foodFavorites = await getFoodFavoritesInteractor.execute();
      state.showCard = await isNecessaryToShowExplainingCardInteractor.execute(ExplainingCardRefs.addFoodFavorite.index);

      emit(state.copyWith(isLoading: false));
    });

    on<RemoveFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        await deleteFoodFavoriteInteractor.execute(getUserIdInteractor.execute(), event.foodFavorite.eventDate);
        try {
          await removeFoodFavoriteFromLocalInteractor.execute(event.foodFavorite);
          state.foodFavorites = await getFoodFavoritesInteractor.execute();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeFoodFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodFavoriteError));
      }
    });

    on<HideExplainingCardAction>((event, emit) {
      state.showCard = false;
      saveExplainingCardInteractionInteractor.execute(ExplainingCardRefs.addFoodFavorite.index);

      emit(state.copyWith(isLoading: false));
    });
  }

  List<FoodFavorite> getFavorites(MealTime? mealTime) {
    if (mealTime == null) {
      return [];
    } else {
      final list = <FoodFavorite>[];
      for (var favorite in state.foodFavorites!) {
        if (favorite.mealTime == mealTime.id) {
          list.add(favorite);
        }
      }
      return list;
    }
  }

  List<FoodFavorite> getFavoritesSummary(MealTime mealTime) {
    final list = <FoodFavorite>[];
    for (var favorite in state.foodFavorites!) {
      if (favorite.mealTime == mealTime.id) {
        list.add(favorite);
      }
    }
    if (list.length == 1) {
      return list.sublist(0, 1);
    } else if (list.length >= 2) {
      return list.sublist(0, 2);
    } else {
      return [];
    }
  }

  MealTime? getMealTimeById(int id) {
    if (id == 0) {
      return Breakfast();
    } else if (id == 1) {
      return Lunch();
    } else if (id == 2) {
      return Dinner();
    } else if (id == 3) {
      return Snack();
    } else {
      return null;
    }
  }


}