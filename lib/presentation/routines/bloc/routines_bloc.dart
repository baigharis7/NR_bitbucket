import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/preferences/get_user_id_interactor.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

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


  RoutinesBloc({
    required this.getRoutinesInteractor,
    required this.getUserIdInteractor,
    required this.deleteSportRoutineInteractor,
    required this.removeSportRoutineInteractor,
  }) : super(RoutinesState(isLoading: false)) {
    on<RoutinesInitialStateAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      state.routines = await getRoutinesInteractor.execute();

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
  }
}
