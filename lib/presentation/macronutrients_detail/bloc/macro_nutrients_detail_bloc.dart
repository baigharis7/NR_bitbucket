import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';

part 'macro_nutrients_detail_event.dart';
part 'macro_nutrients_detail_state.dart';

class MacroNutrientsDetailBloc extends Bloc<MacroNutrientsDetailEvent, MacroNutrientsDetailState> {
  MacroNutrientsDetailBloc() : super(MacroNutrientsDetailState(
    isLoading: false,
  ),) {
    on<LoadMacroNutrientsEventAction>((event, emit) {
      state.macronutrients = event.macronutrientsList;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);
}
