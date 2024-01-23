import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/interactor/liquidevents/get_today_liquid_events_interactor.dart';
import '../../../domain/models/liquidevents/liquid_event_complete.dart';
import '../../../domain/models/watervents/water_event_master.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';

part 'liquid_summary_detail_event.dart';
part 'liquid_summary_detail_state.dart';

class LiquidSummaryDetailBloc extends Bloc<LiquidSummaryDetailEvent, LiquidSummaryDetailState> {
  final GetTodayLiquidEventsInteractor getLiquidEventsOfTodayInteractor;
  LiquidSummaryDetailBloc({required this.getLiquidEventsOfTodayInteractor}) : super(LiquidSummaryDetailState(isLoading: false)) {
    on<LoadLiquidSummaryEventAction>((event, emit) async {
      state.waterEvents = event.waterEvents;
      state.todayLiquidEvents = await getLiquidEventsOfTodayInteractor.execute();

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);
}
