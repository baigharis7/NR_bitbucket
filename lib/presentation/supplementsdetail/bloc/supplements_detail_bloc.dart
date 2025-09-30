import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

part 'supplements_detail_event.dart';
part 'supplements_detail_state.dart';

class SupplementsDetailBloc extends Bloc<SupplementsDetailEvent, SupplementsDetailState> {
  SupplementsDetailBloc() : super(SupplementsDetailState(isLoading: false)) {
    on<InitializeSupplementsDetailEvent>((event, emit) {

    });

    on<UpdateEventsDateSupplementsDetailEvent>((event, emit) {
      state.eventDate = event.dateTime;

      emit(state.copyWith(isLoading: false));
    });
  }
}
