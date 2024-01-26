import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nutrenaissance_flutter/domain/interactor/liquidevents/get_week_liquid_events_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/profile/get_profile_interactor.dart';
import 'package:nutrenaissance_flutter/domain/interactor/sportevents/get_week_sports_interactor.dart';

import '../../../domain/interactor/foodevents/get_week_food_events_interactor.dart';
import '../../../domain/models/dashboard/energy_model.dart';
import '../../../domain/models/foodevents/food_event_complete.dart';
import '../../../domain/models/profile/user_profile_model.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';
import '../../../infrastructure/helpers/date_time_helper.dart';

part 'energy_balance_detail_event.dart';
part 'energy_balance_detail_state.dart';

class EnergyBalanceDetailBloc extends Bloc<EnergyBalanceDetailEvent, EnergyBalanceDetailState> {
  final GetWeekFoodEventsInteractor getWeekFoodEventsInteractor;
  final GetWeekLiquidEventsInteractor getWeekLiquidEventsInteractor;
  final GetWeekSportsInteractor getWeekSportsInteractor;
  final GetProfileInteractor getProfileInteractor;

  EnergyBalanceDetailBloc({
    required this.getWeekFoodEventsInteractor,
    required this.getWeekLiquidEventsInteractor,
    required this.getWeekSportsInteractor,
    required this.getProfileInteractor,
}) : super(EnergyBalanceDetailState(isLoading: false)) {
    on<InitializeEventAction>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final a = await getWeekFoodEventsInteractor.execute();
      state.weeklyFoodEvents = a;
      state.weeklyLiquidEvents = await getWeekLiquidEventsInteractor.execute();
      state.weeklySportEvents = await getWeekSportsInteractor.execute();
      state.userProfile = await getProfileInteractor.execute();

      state.averageConsumedKcal = consumedKcal();
      state.averageSpentKcal = spentKcal();
      state.weeklyEnergyBalance = getWeeklyEnergyLevel();

      emit(state.copyWith(isLoading: false));
    },);

    on<LoadEnergyBalanceEventAction>((event, emit) {
      state.energyModel = event.energyModel;

      emit(state.copyWith(isLoading: false));
    });
  }

  String getTodayMessage(String todayString, String locale) => DateTimeHelper().formatDashboardTodayMessage(todayString, locale);

  double consumedKcal() {
    double foodKcalConsumed = 0;
    for (var event in state.weeklyFoodEvents ?? []) {
      foodKcalConsumed =
          foodKcalConsumed + (event.eventKcals ?? 0.0);
    }

    double liquidKcalConsumed = 0;
    for (var event in state.weeklyLiquidEvents ?? []) {
      liquidKcalConsumed =
          liquidKcalConsumed + (event.eventKcals ?? 0.0);
    }
    return foodKcalConsumed+liquidKcalConsumed;
  }

  double spentKcal() {
    double sportKcalConsumed = 0;
    for (var event in state.weeklySportEvents ?? []) {
      sportKcalConsumed =
          sportKcalConsumed + (event.eventKcals ?? 0.0);
    }
    return sportKcalConsumed;
  }

  List<Map<String, dynamic>> getWeeklyEnergyLevel() {
    List<Map<String, dynamic>> weeklyData = [];
    int latestDate = 1;
    for (var event in state.weeklyFoodEvents ?? []) {
      int weekDay =
          DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
      if (weekDay > latestDate) latestDate = weekDay;
    }

    for (var eventWeekDay = 1; eventWeekDay <= 7; eventWeekDay++) {
      //FoodEvents
      final eventsOfFoodWeekDay = <FoodEventComplete>[];
      for (var event in state.weeklyFoodEvents ?? []) {
        final eventDate =
            DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfFoodWeekDay.add(event);
        }
      }
      double nutrientConsumed = 0;
      for (var event in eventsOfFoodWeekDay) {
        nutrientConsumed =
            nutrientConsumed + (event.eventKcals ?? 0.0);
      }

      //LiquidEvents
      final eventsOfLiquidWeekDay = <FoodEventComplete>[];
      for (var event in state.weeklyLiquidEvents ?? []) {
        final eventDate =
            DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfLiquidWeekDay.add(event);
        }
      }
      double liquidConsumed = 0;
      for (var event in eventsOfLiquidWeekDay) {
        liquidConsumed =
            liquidConsumed + (event.eventKcals ?? 0.0);
      }

      //SportEvents
      final eventsOfSportWeekDay = <SportEventComplete>[];
      for (var event in state.weeklySportEvents ?? []) {
        final eventDate =
            DateTimeHelper().setDateFromMilliseconds(event.eventDate!).weekday;
        if (eventDate == eventWeekDay) {
          eventsOfSportWeekDay.add(event);
        }
      }
      double sportConsumed = 0;
      for (var event in eventsOfSportWeekDay) {
        sportConsumed =
            sportConsumed + (event.eventKcals ?? 0.0);
      }

      var totalEnergyBalance = (nutrientConsumed + liquidConsumed - sportConsumed) / (state.userProfile?.kcal ?? 0);
      if (totalEnergyBalance > 1) totalEnergyBalance = 1;
      if (totalEnergyBalance < 0) totalEnergyBalance = 0.0;
      weeklyData
          .add({'day': eventWeekDay, 'Kcal': totalEnergyBalance});
    }

    weeklyData.sort((a, b) => (a['day']!).compareTo(b['day']!));
    return weeklyData;
  }
}
