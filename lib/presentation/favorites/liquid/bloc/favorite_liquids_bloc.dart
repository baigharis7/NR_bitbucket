import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/delete_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/get_liquid_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/remove_liquid_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/meal_time.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/presentation/common/bloc/base_bloc.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/favorite_liquids_actions.dart';
import 'package:nutrenaissance_flutter/presentation/favorites/liquid/bloc/favorite_liquids_state.dart';

class FavoriteLiquidsBloc extends BaseBloc<FavoriteLiquidsActions, FavoriteLiquidsState> {
  final GetLiquidFavoritesInteractor getLiquidFavoritesInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final DeleteLiquidFavoriteInteractor deleteLiquidFavoriteInteractor;
  final RemoveLiquidFavoriteFromLocalInteractor removeLiquidFavoriteFromLocalInteractor;

  FavoriteLiquidsBloc({
    required this.getLiquidFavoritesInteractor,
    required this.getUserIdInteractor,
    required this.removeLiquidFavoriteFromLocalInteractor,
    required this.deleteLiquidFavoriteInteractor,
  }) : super(FavoriteLiquidsState(
    isLoading: false,
    onError: null,
    liquidFavorites: [],
  ),) {
    on<InitializeState>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.liquidFavorites = await getLiquidFavoritesInteractor.execute();

      emit(state.copyWith(isLoading: false));
    });

    on<RemoveFavoriteAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        await deleteLiquidFavoriteInteractor.execute(getUserIdInteractor.execute(), event.liquidFavorite.eventDate);
        try {
          await removeLiquidFavoriteFromLocalInteractor.execute(event.liquidFavorite);
          state.liquidFavorites = await getLiquidFavoritesInteractor.execute();
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeLiquidFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteLiquidFavoriteError));
      }
    });
  }

  List<LiquidFavorite> getFavorites(MealTime? mealTime) {
    if (mealTime == null) {
      return [];
    } else {
      final list = <LiquidFavorite>[];
      for (var favorite in state.liquidFavorites!) {
        if (favorite.mealTime == mealTime.id) {
          list.add(favorite);
        }
      }
      return list;
    }
  }

  List<LiquidFavorite> getFavoritesSummary(MealTime mealTime) {
    final list = <LiquidFavorite>[];
    for (var favorite in state.liquidFavorites!) {
      if (favorite.mealTime == mealTime.id) {
        list.add(favorite);
      }
    }
    if (list.length == 1) {
      return list.sublist(0, 1);
    } else if (list.length == 2) {
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