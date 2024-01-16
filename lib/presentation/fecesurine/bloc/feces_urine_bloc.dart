import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/urine.dart';

import '../../../domain/models/profile/feces.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'feces_urine_event.dart';
part 'feces_urine_state.dart';

class FecesUrineBloc extends Bloc<FecesUrineEvent, FecesUrineState> {
  FecesUrineBloc() : super(FecesUrineState(isLoading: false)) {
    on<InitializationEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.fecesList = Feces.listOfAllFeces();
      state.urinesList = Urines.listOfAllUrines();


      emit(state.copyWith(isLoading: false));
    });

    on<UpdateFecesEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.fecesSelected = event.feceId;

      emit(state.copyWith(isLoading: false));
    },);

    on<UpdateUrineEventAction>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.urinesSelected = event.urineId;

      emit(state.copyWith(isLoading: false));
    },);
  }
}
