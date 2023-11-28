import 'package:bloc/bloc.dart';

import '../../../domain/models/dashboard/nutrients_model.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';

part 'micro_nutrients_detail_event.dart';
part 'micro_nutrients_detail_state.dart';

class MicroNutrientsDetailBloc extends Bloc<MicroNutrientsDetailEvent, MicroNutrientsDetailState> {
  MicroNutrientsDetailBloc() : super(MicroNutrientsDetailState(
    isLoading: false,
  ),
  ) {
    on<LoadMicroNutrientsDetails>((event, emit) {
      state.microNutrients = event.micronutrientsList;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);
}
