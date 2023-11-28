import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/models/dashboard/energy_model.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';

part 'energy_balance_detail_event.dart';
part 'energy_balance_detail_state.dart';

class EnergyBalanceDetailBloc extends Bloc<EnergyBalanceDetailEvent, EnergyBalanceDetailState> {
  EnergyBalanceDetailBloc() : super(EnergyBalanceDetailState(isLoading: false)) {
    on<LoadEnergyBalanceEventAction>((event, emit) {
      state.energyModel = event.energyModel;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);
}
