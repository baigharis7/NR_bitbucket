import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../infrastructure/errors/error_types.dart';

part 'routines_tab_event.dart';
part 'routines_tab_state.dart';

class RoutinesTabBloc extends Bloc<RoutinesTabEvent, RoutinesTabState> {
  RoutinesTabBloc() : super(RoutinesTabState(isLoading: false)) {
    on<InitializeRoutinesTabEvent>((event, emit) {});
  }
}
