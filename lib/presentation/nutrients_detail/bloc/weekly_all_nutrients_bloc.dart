import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/models/dashboard/nutrients_model.dart';

part 'weekly_all_nutrients_event.dart';
part 'weekly_all_nutrients_state.dart';

class WeeklyAllNutrientsBloc extends Bloc<WeeklyAllNutrientsEventActions, WeeklyAllNutrientsState> {
  WeeklyAllNutrientsBloc() : super(WeeklyAllNutrientsState(isLoading: false,)) {
    on<InitializationEventAction>((event, emit) {
    });

    on<UpdateWeeklyListOfNutrients>((event, emit) {
      emit(state.copyWith(isLoading: true));
      state.weeklyMicronutrients = event.weeklyMicronutrients;

      emit(state.copyWith(isLoading: false));
    },);
  }
}
