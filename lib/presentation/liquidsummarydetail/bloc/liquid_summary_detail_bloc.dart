import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/models/watervents/water_event_master.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';

part 'liquid_summary_detail_event.dart';
part 'liquid_summary_detail_state.dart';

class LiquidSummaryDetailBloc extends Bloc<LiquidSummaryDetailEvent, LiquidSummaryDetailState> {
  LiquidSummaryDetailBloc() : super(LiquidSummaryDetailState(isLoading: false)) {
    on<LoadLiquidSummaryEventAction>((event, emit) {
      state.waterEvents = event.waterEvents;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);
}
