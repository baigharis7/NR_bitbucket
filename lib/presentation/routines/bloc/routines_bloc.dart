import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/interactor/routines/get_routines_interactor.dart';
import '../../../domain/models/routines/sport_routine_completed.dart';

part 'routines_event.dart';

part 'routines_state.dart';

class RoutinesBloc extends Bloc<RoutinesEvent, RoutinesState> {
  final GetRoutinesInteractor getRoutinesInteractor;

  RoutinesBloc({
    required this.getRoutinesInteractor,
  }) : super(RoutinesState(isLoading: false)) {
    on<RoutinesInitialStateAction>((event, emit) async {
      state.routines = await getRoutinesInteractor.execute();

      emit(state.copyWith(isLoading: false));
    });
  }
}
