import 'package:bloc/bloc.dart';

import '../../../domain/models/dashboard/nutrients_weekly_model.dart';
import '../../../infrastructure/errors/error_types.dart';

part 'micro_nutrients_weekly_event.dart';
part 'micro_nutrients_weekly_state.dart';

class MicroNutrientsWeeklyBloc extends Bloc<MicroNutrientsWeeklyEvent, MicroNutrientsWeeklyState> {
  MicroNutrientsWeeklyBloc() : super(MicroNutrientsWeeklyState(isLoading: false)) {
    on<InitializationEventAction>((event, emit) {

    });

    on<UpdateWeeklyListOfNutrients>((event, emit) {
      state.copyWith(isLoading: true);
      state.micronutrientsWeekly = event.micronutrientsWeekly;

      emit(state.copyWith(isLoading: false));
    });
  }
}
