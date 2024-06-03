import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/favorites_mapper.dart';
import 'package:nutrenaissance_flutter/infrastructure/mappers/sport_routine_mappers.dart';

import '../../../domain/interactor/favorites/sport/delete_sport_favorite_interactor.dart';
import '../../../domain/interactor/favorites/sport/get_sport_favorites_interactor.dart';
import '../../../domain/interactor/favorites/sport/remove_sport_favorite_from_local_interactor.dart';
import '../../../domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import '../../../domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import '../../../domain/interactor/routines/delete_sport_routine_interactor.dart';
import '../../../domain/interactor/routines/get_routines_interactor.dart';
import '../../../domain/interactor/routines/remove_sport_routine_interactor.dart';
import '../../../domain/models/routines/sport_routine_completed.dart';

part 'routines_event.dart';

part 'routines_state.dart';

class RoutinesBloc extends Bloc<RoutinesEvent, RoutinesState> {
  final GetRoutinesInteractor getRoutinesInteractor;
  final GetUserIdInteractor getUserIdInteractor;
  final DeleteSportRoutineInteractor deleteSportRoutineInteractor;
  final RemoveSportRoutineInteractor removeSportRoutineInteractor;
  final UploadSportFavoriteInteractor uploadSportFavoriteInteractor;
  final SaveSportFavoriteInteractor saveSportFavoriteInteractor;
  final DeleteSportFavoriteInteractor deleteSportFavoriteInteractor;
  final RemoveSportFavoriteInteractor removeSportFavoriteInteractor;
  final GetSportFavoritesInteractor getSportFavoritesInteractor;


  RoutinesBloc({
    required this.getRoutinesInteractor,
    required this.getUserIdInteractor,
    required this.deleteSportRoutineInteractor,
    required this.removeSportRoutineInteractor,
    required this.uploadSportFavoriteInteractor,
    required this.saveSportFavoriteInteractor,
    required this.deleteSportFavoriteInteractor,
    required this.removeSportFavoriteInteractor,
    required this.getSportFavoritesInteractor,
  }) : super(RoutinesState(isLoading: false)) {
    on<RoutinesInitialStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.routines = await getRoutinesInteractor.execute();
      state.sportsFavorite = await getSportFavoritesInteractor.execute();

      emit(state.copyWith(isLoading: false));
    });

    on<RoutineDeleteEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final deleteResult = await deleteSportRoutineInteractor.execute(getUserIdInteractor.execute(), event.sportRoutineCompleted.eventId ?? -1);
        try {
          final removeResult = await removeSportRoutineInteractor.execute(event.sportRoutineCompleted);
          emit(state.copyWith(isLoading: false, onError: null));
          event.onFinish.call();
        } catch (_) {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportFavoriteError));
        }
      } catch (_) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportFavoriteError));
      }
    },);

    on<RoutineFavoriteEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      AddSportFavorite sportFavorite = mapToSportFavoriteFromRoutine(event.sportRoutineCompleted);
      try {
        final sportEventComplete = await uploadSportFavoriteInteractor.execute(sportFavorite);
        try {
          await saveSportFavoriteInteractor.execute(sportFavorite, false);
          event.onFinish.call();
          emit(state.copyWith(isLoading: false, onError: null));
        } catch (error) {
          state.onError = ErrorTypes.locallySavingSportEventError;
          emit(state.copyWith(isLoading: false, onError: state.onError,));
        }
      } catch (error) {
        state.onError = ErrorTypes.uploadingSportEventError;
        emit(state.copyWith(isLoading: false, onError: state.onError,));
      }
    },);

    on<RemoveRoutineFavoriteEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      AddSportFavorite sportFavorite = mapToSportFavoriteFromRoutine(event.sportRoutineCompleted);
      final userId = getUserIdInteractor.execute();
      try {
        final deleteFavorite = await deleteSportFavoriteInteractor.execute(userId, sportFavorite.eventDate!);
          try {
            final removeFromLocalResult = await removeSportFavoriteInteractor.execute(sportFavorite);
            event.onFinish.call();
            emit(state.copyWith(isLoading: false, onError: null));
          } catch (error) {
            emit(state.copyWith(isLoading: false, onError: ErrorTypes.removeSportFavoriteError));
          }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.deleteSportFavoriteError));
      }
    },);
  }

  AddSportFavorite? isFoundObjectFromFavoriteList(AddSportFavorite sportFavoriteFromEvent) {
    AddSportFavorite? object;
    bool isFound = false;
    parentLoop: for (AddSportFavorite favObject in state.sportsFavorite.orEmpty()) {
      object = favObject;
      if (favObject.info?.length == sportFavoriteFromEvent.info?.length) {
        childLoop: for (AddSportFavInfo matchingObject in sportFavoriteFromEvent.info.orEmpty()) {
          isFound = favObject.info.orEmpty().any((sportItem) => sportItem.id == matchingObject.id && sportItem.intensity == matchingObject.intensity && sportItem.minutes == matchingObject.minutes);
          if (isFound == true) break parentLoop;
        }
      }
    }
    return isFound ? object : null;
  }
}
