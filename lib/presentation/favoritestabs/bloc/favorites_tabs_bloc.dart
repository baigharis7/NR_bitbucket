import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import '../../../domain/models/favorites/food/food_favorite.dart';
import '../../../domain/models/masterfiles/food_names_master.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'favorites_tabs_event.dart';

part 'favorites_tabs_state.dart';

class FavoritesTabsBloc extends Bloc<FavoritesTabsEvent, FavoritesTabsState> {
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor;
  final DeleteFoodFavoriteInteractor deleteFoodFavoriteInteractor;
  final RemoveFoodFavoriteFromLocalInteractor
      removeFoodFavoriteFromLocalInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;

  FavoritesTabsBloc({
    required this.getFoodFavoritesInteractor,
    required this.deleteFoodFavoriteInteractor,
    required this.removeFoodFavoriteFromLocalInteractor,
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
  }) : super(FavoritesTabsState(
            isLoading: false,
            foodNames: FoodsAndDrinksNamesMaster(
              FoodsAndDrinkListsMaster(
                foodNames: [],
                drinkNames: [],
              ),
            ),
  ),) {
    on<InitializeFavoritesTabsEvent>((event, emit) async {
      state.favFoods = await getFoodFavoritesInteractor.execute();
      state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.foodNames?.foodsAndDrinksNames?.foodNames?.addAll(state.foodNames?.foodsAndDrinksNames?.drinkNames ?? []);

      emit(state.copyWith(isLoading: false));
    });

    on<RemoveFavoriteFoodFavoritesTabsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        await deleteFoodFavoriteInteractor.execute(
            getUserIdInteractor.execute(), event.foodFavorite.eventDate.orZero());
        try {
          await removeFoodFavoriteFromLocalInteractor.execute(event.foodFavorite);
          state.favFoods = await getFoodFavoritesInteractor.execute();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeFoodFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteFoodFavoriteError));
      }
    });
  }
}
