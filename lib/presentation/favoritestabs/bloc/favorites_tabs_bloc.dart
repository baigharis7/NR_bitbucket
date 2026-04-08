import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/masterfiles/get_master_file_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/delete_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/get_supplement_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/supplements/remove_supplement_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';

import '../../../domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import '../../../domain/interactor/favorites/sport/delete_sport_favorite_interactor.dart';
import '../../../domain/interactor/favorites/sport/remove_sport_favorite_from_local_interactor.dart';
import '../../../domain/models/favorites/food/food_favorite.dart';
import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/masterfiles/food_names_master.dart';
import '../../../domain/models/masterfiles/sports_info_master.dart';
import '../../../domain/models/masterfiles/supplements_info_master.dart';
import '../../../domain/models/masterfiles/units_info_master.dart';
import '../../../domain/models/supplements/supplement_simple.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'favorites_tabs_event.dart';

part 'favorites_tabs_state.dart';

class FavoritesTabsBloc extends Bloc<FavoritesTabsEvent, FavoritesTabsState> {
  final GetFoodFavoritesInteractor getFoodFavoritesInteractor;
  final DeleteFoodFavoriteInteractor deleteFoodFavoriteInteractor;
  final RemoveFoodFavoriteFromLocalInteractor removeFoodFavoriteFromLocalInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final GetMasterFileInteractor getMasterFileInteractor;
  final GetSportFavoritesInteractor getSportFavoritesInteractor;
  final GetSupplementFavoritesInteractor getSupplementFavoritesInteractor;
  final DeleteSportFavoriteInteractor deleteSportFavoriteInteractor;
  final RemoveSportFavoriteInteractor removeSportFavoriteInteractor;
  final DeleteSupplementFavoriteInteractor deleteSupplementFavoriteInteractor;
  final RemoveSupplementFavoriteInteractor removeSupplementFavoriteInteractor;
  late final StreamSubscription<DataChangedCategory> _eventBusSubscription;

  FavoritesTabsBloc({
    required this.getFoodFavoritesInteractor,
    required this.deleteFoodFavoriteInteractor,
    required this.removeFoodFavoriteFromLocalInteractor,
    required this.getUserIdInteractor,
    required this.getMasterFileInteractor,
    required this.getSportFavoritesInteractor,
    required this.getSupplementFavoritesInteractor,
    required this.deleteSportFavoriteInteractor,
    required this.removeSportFavoriteInteractor,
    required this.deleteSupplementFavoriteInteractor,
    required this.removeSupplementFavoriteInteractor,
  }) : super(FavoritesTabsState(
            isLoading: false,
            foodNames: FoodsAndDrinksNamesMaster(
              FoodsAndDrinkListsMaster(
                foodNames: [],
                drinkNames: [],
              ),
            ),
  ),) {
    _eventBusSubscription = DashboardEventBus.instance.stream.listen((category) {
      if (category == DataChangedCategory.food ||
          category == DataChangedCategory.sport ||
          category == DataChangedCategory.supplement) {
        add(_RefreshFavoritesCategoryEvent(category));
      }
    });

    on<InitializeFavoritesTabsEvent>((event, emit) async {
      state.favFoods = await getFoodFavoritesInteractor.execute();
      state.foodNames = await getMasterFileInteractor.execute(MasterFilesType.foodsAndDrinksNames);
      state.foodNames?.foodsAndDrinksNames?.foodNames?.removeWhere((f) => f.included == 1);
      state.foodNames?.foodsAndDrinksNames?.drinkNames?.removeWhere((f) => f.included == 1);
      state.unitsInfoMaster = await getMasterFileInteractor.execute(MasterFilesType.unitsInfo);
      state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);
      state.supplementsInfo = await getMasterFileInteractor.execute(MasterFilesType.supplementsInfo);
      state.foodNames?.foodsAndDrinksNames?.foodNames?.addAll(state.foodNames?.foodsAndDrinksNames?.drinkNames ?? []);
      state.favSports = await getSportFavoritesInteractor.execute();
      state.favSupplements = await getSupplementFavoritesInteractor.execute();

      emit(state.copyWith(isLoading: false));
    });

    on<RemoveFavoriteFoodFavoritesTabsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        await deleteFoodFavoriteInteractor.execute(getUserIdInteractor.execute(), event.foodFavorite.eventId.orZero());
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

    on<DeleteFavoriteSportFavoritesTabsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final userId = getUserIdInteractor.execute();
      try {
        final deleteFavorite = await deleteSportFavoriteInteractor.execute(userId, event.sportFavorite.eventId!);
        if (deleteFavorite) {
          try {
            final removeFromLocalResult = await removeSportFavoriteInteractor.execute(event.sportFavorite);
            if (removeFromLocalResult) {
              state.favSports = await getSportFavoritesInteractor.execute();
              emit(state.copyWith(isLoading: false, onError: null));
            } else {
              emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSportFavoriteError));
            }
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSportFavoriteError));
          }
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportFavoriteError));
      }
    });

    on<DeleteSupplementFavoriteFavoritesTabsEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await deleteSupplementFavoriteInteractor.execute(event.supplementSimple);
        try {
          await removeSupplementFavoriteInteractor.execute(event.supplementSimple);
          state.favSupplements = await getSupplementFavoritesInteractor.execute();

          emit(state.copyWith(isLoading: false, onError: null));
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSupplementEventError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSupplementEventError));
      }
    });

    on<_RefreshFavoritesCategoryEvent>((event, emit) async {
      switch (event.category) {
        case DataChangedCategory.food:
          state.favFoods = await getFoodFavoritesInteractor.execute();
          break;
        case DataChangedCategory.sport:
          state.favSports = await getSportFavoritesInteractor.execute();
          break;
        case DataChangedCategory.supplement:
          state.favSupplements = await getSupplementFavoritesInteractor.execute();
          break;
        default:
          return;
      }
      emit(state.copyWith(isLoading: false));
    });
  }

  @override
  Future<void> close() {
    _eventBusSubscription.cancel();
    return super.close();
  }
}
