import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/data/local/models/masterfiles/master_files_type.dart';
import 'package:nutrenaissance_flutter/infrastructure/helpers/date_time_helper.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/save_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/favorites/sport/upload_sport_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';
import 'package:nutrenaissance_flutter/infrastructure/services/dashboard_event_bus.dart';
import 'package:nutrenaissance_flutter/infrastructure/extensions/extensions.dart';

import '../../../domain/interactor/masterfiles/get_master_file_interactor.dart';
import '../../../domain/interactor/routines/save_routine_interactor.dart';
import '../../../domain/interactor/routines/upload_routine_interactor.dart';
import '../../../domain/models/favorites/sport/add_sport_favorite.dart';
import '../../../domain/models/masterfiles/sports_info_master.dart';
import '../../../infrastructure/mappers/food_event_mappers.dart';

part 'update_sport_event.dart';

part 'update_sport_state.dart';

class UpdateSportBloc extends Bloc<UpdateSportEvent, UpdateSportState> {
  final GetMasterFileInteractor getMasterFileInteractor;
  final UploadSportFavoriteInteractor uploadSportFavoriteInteractor;
  final SaveSportFavoriteInteractor saveSportFavoriteInteractor;
  final UploadRoutineInteractor uploadRoutineInteractor;
  final SaveRoutineInteractor saveRoutineInteractor;

  UpdateSportBloc({
    required this.getMasterFileInteractor,
    required this.uploadSportFavoriteInteractor,
    required this.saveSportFavoriteInteractor,
    required this.uploadRoutineInteractor,
    required this.saveRoutineInteractor,
  }) : super(UpdateSportState(isLoading: false)) {
    on<InitializationUpdateSportEvent>((event, emit) async {
      state.sportsInfo = await getMasterFileInteractor.execute(MasterFilesType.sportsInfo);

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<GetSportFromArgumentUpdateSportEvent>((event, emit) {
      state.sportSimple = event.sport;

      emit(state.copyWith(isLoading: false));
    });

    on<UpdateSportItemUpdateSportEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      final listOfIds = state.sportSimple?.info.orEmpty().map((e) => e.id).toList();

      if (listOfIds.orEmpty().contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimple!.info!.indexOf(state.sportSimple!.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimple!.info!.remove(state.sportSimple!.info![itemIndex]);
        state.sportSimple!.info!.add(event.sportInfo);
      } else {
        state.sportSimple?.info?.add(event.sportInfo);
      }
      emit(state.copyWith(isLoading: false, onError: null));
    },);

    on<RemoveSportItemUpdateSportEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      final listOfIds = state.sportSimple?.info.orEmpty().map((e) => e.id).toList();

      if (listOfIds.orEmpty().contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimple!.info!.indexOf(state.sportSimple!.info!.firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimple!.info!.remove(state.sportSimple!.info![itemIndex]);
      }

      if (state.sportSimple?.info?.isEmpty == true) event.isGoBack.call();

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateSportNameUpdateSportEvent>((event, emit) {
      state.sportSimple?.title = event.name;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateSportScheduleTimeUpdateSportEvent>((event, emit) {
      state.sportSimple?.scheduleTime = event.scheduleTime;

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateSportItemMinutesUpdateSportEvent>((event, emit) {
      emit(state.copyWith(isLoading: true, onError: null));
      if (state.sportSimple!.info.orEmpty().map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimple!.info.orEmpty().indexOf(state.sportSimple!.info.orEmpty().firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimple!.info.orEmpty()[itemIndex].minutes = event.sportInfo.minutes;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateSportItemIntensityUpdateSportEvent>((event, emit) {
      if (state.sportSimple!.info.orEmpty().map((sport) => sport.id).contains((event.sportInfo).id)) {
        final itemIndex = state.sportSimple!.info.orEmpty().indexOf(state.sportSimple!.info.orEmpty().firstWhere((food) => food.id == event.sportInfo.id));
        state.sportSimple!.info.orEmpty()[itemIndex].intensity = event.sportInfo.intensity;
      }
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateIsFavoriteUpdateSportEvent>((event, emit) {
      state.sportSimple?.isFavorite = event.isFavorite;
      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<UpdateIsRoutineUpdateSportEvent>((event, emit) {
      state.sportSimple?.isCreateRoutine = event.isRoutine;

      if (event.isRoutine && state.sportSimple?.scheduleTime.isEmptyOrNull() == true) {
        state.sportSimple?.scheduleTime = DateTimeHelper.timeOfDayTo24HrString(TimeOfDay.now());
      }

      emit(state.copyWith(isLoading: false, onError: null));
    });

    on<SaveUpdateSportUpdateSportEvent>((event, emit) {
      if (state.sportSimple?.isCreateRoutine == true) {
        if (state.sportSimple?.daysOfWeek?.orEmpty().isEmpty == true || state.sportSimple?.scheduleTime.isEmptyOrNull() == true) return;
        add(SaveUpdateSportRoutineUpdateSportEvent(onFinish: event.onFinish));
      } else {
        add(SaveUpdateSportFavoriteUpdateSportEvent(onFinish: event.onFinish));
      }
    });

    on<SaveUpdateSportFavoriteUpdateSportEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final uploadResult = await uploadSportFavoriteInteractor.execute(state.sportSimple!);
        if (uploadResult) {
          await saveSportFavoriteInteractor.execute(state.sportSimple!, true);

          _clearFields();
          emit(state.copyWith(isLoading: false, onError: null,));
          event.onFinish.call();
        } else {
          emit(state.copyWith(isLoading: false, onError: ErrorTypes.saveSportFavoriteError));
        }
      } catch (error) {
        emit(state.copyWith(isLoading: false, onError: ErrorTypes.uploadSportFavoriteError));
      }
    });

    on<SaveUpdateSportRoutineUpdateSportEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, onError: null));

      try {
        final sportRoutine = mapAddFavSportToSportRoutineCompleted(state.sportSimple!);
        final sportEventComplete = await uploadRoutineInteractor.execute(sportRoutine);
        try {
          await saveRoutineInteractor.execute(sportRoutine, true);
          DashboardEventBus.instance.notify(DataChangedCategory.sport);

          _clearFields();
          emit(state.copyWith(isLoading: false, onError: null));
          event.onFinish.call();
        } catch (error) {
          state.onError = ErrorTypes.locallySavingSportRoutineError;
          emit(state.copyWith(isLoading: false, onError: state.onError,));
        }
      } catch (error) {
        state.onError = ErrorTypes.uploadingSportRoutineError;
        emit(state.copyWith(isLoading: false, onError: state.onError,));
      }
    });
  }

  SportInfoMaster findSportById(int sportId) {
    return state.sportsInfo!.sportsInfoMaster.firstWhere((sport) => sport.id == sportId);
  }

  void _clearFields() {
    state.sportSimple = AddSportFavorite.empty();
  }
}
