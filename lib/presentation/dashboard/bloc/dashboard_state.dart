import 'package:nutrenaissance_flutter/domain/models/dashboard/energy_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/nutrients_model.dart';
import 'package:nutrenaissance_flutter/domain/models/dashboard/sugar_&_fiber_model.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_complete.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/nutrients_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/profile/user_profile_model.dart';
import 'package:nutrenaissance_flutter/domain/models/watervents/water_event_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/models/liquidevents/liquid_event_complete.dart';
import '../../../domain/models/sportevents/sport_event_complete.dart';

class DashboardState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodEventComplete>? foodEvents;
  List<LiquidEventComplete>? todayLiquidEvents;
  List<String>? userMicronutrients;
  List<int>? userObjectives;
  NutrientsInfoMaster? nutrientsInfoMaster;
  List<UserRda>? userRdas;
  String? advice;
  List<NutrientsModel>? micronutrients;
  List<NutrientsModel>? macronutrients;
  int? userKcal;
  EnergyModel? energyModel;
  List<WaterEventMaster>? waterEvents;
  bool? showCard;
  SugarAndFiberModel? sugarAndFiberModel;
  List<FoodEventComplete>? weeklyFoodEvents;
  List<FoodEventComplete>? weeklyLiquidEvents;
  List<SportEventComplete>? weeklySportEvents;
  List<NutrientsModel>? weeklyMicronutrients;

  DashboardState({
    required this.isLoading,
    this.onError,
    this.foodEvents,
    this.todayLiquidEvents,
    this.userMicronutrients,
    this.userObjectives,
    this.nutrientsInfoMaster,
    this.userRdas,
    this.advice,
    this.micronutrients,
    this.macronutrients,
    this.userKcal,
    this.energyModel,
    this.waterEvents,
    this.showCard,
    this.sugarAndFiberModel,
    this.weeklyFoodEvents,
    this.weeklyLiquidEvents,
    this.weeklySportEvents,
    this.weeklyMicronutrients,
  });

  DashboardState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodEventComplete>? foodEvents,
    List<LiquidEventComplete>? todayLiquidEvents,
    bool? infoLoaded,
    List<String>? userMicronutrients,
    List<int>? userObjectives,
    NutrientsInfoMaster? nutrientsInfoMaster,
    List<UserRda>? userRdas,
    String? advice,
    List<NutrientsModel>? micronutrients,
    List<NutrientsModel>? macronutrients,
    int? userKcal,
    EnergyModel? energyModel,
    List<WaterEventMaster>? waterEvents,
    bool? showCard,
    SugarAndFiberModel? sugarAndFiberModel,
    List<FoodEventComplete>? weeklyFoodEvents,
    List<FoodEventComplete>? weeklyLiquidEvents,
    List<SportEventComplete>? weeklySportEvents,
    List<NutrientsModel>? weeklyMicronutrients,
  }) {
    return DashboardState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodEvents: foodEvents ?? this.foodEvents,
      todayLiquidEvents: todayLiquidEvents ?? this.todayLiquidEvents,
      userMicronutrients: userMicronutrients ?? this.userMicronutrients,
      userObjectives: userObjectives ?? this.userObjectives,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
      userRdas: userRdas ?? this.userRdas,
      advice: advice ?? this.advice,
      micronutrients: micronutrients ?? this.micronutrients,
      macronutrients: macronutrients ?? this.macronutrients,
      userKcal: userKcal ?? this.userKcal,
      energyModel: energyModel ?? this.energyModel,
      waterEvents: waterEvents ?? this.waterEvents,
      showCard: showCard ?? this.showCard,
      sugarAndFiberModel: sugarAndFiberModel ?? this.sugarAndFiberModel,
      weeklyFoodEvents: weeklyFoodEvents ?? this.weeklyFoodEvents,
      weeklyLiquidEvents: weeklyLiquidEvents ?? this.weeklyLiquidEvents,
      weeklySportEvents: weeklySportEvents ?? this.weeklySportEvents,
      weeklyMicronutrients: weeklyMicronutrients ?? this.weeklyMicronutrients,
    );
  }

}