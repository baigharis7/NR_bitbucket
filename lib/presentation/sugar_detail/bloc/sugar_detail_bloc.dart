import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/models/dashboard/sugar_&_fiber_model.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';

part 'sugar_detail_event.dart';
part 'sugar_detail_state.dart';

class SugarDetailBloc extends Bloc<SugarDetailEvent, SugarDetailState> {
  SugarDetailBloc() : super(SugarDetailState(
      isLoading: false
  )) {
    on<LoadSugarEventAction>((event, emit) {
      state.sugarAndFiberModel = event.sugarAndFiberModel;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);
}
