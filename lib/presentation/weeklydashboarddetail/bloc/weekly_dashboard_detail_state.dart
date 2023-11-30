part of 'weekly_dashboard_detail_bloc.dart';

// @immutable
// abstract class WeeklyDashboardDetailState {}

class WeeklyDashboardDetailState {
  bool isLoading;
  List<String>? userMicronutrients;
  List<UserRda>? userRdas;
  UserProfileModel? userProfile;
  NutrientsInfoMaster? nutrientsInfoMaster;
  List<FoodEventComplete>? weeklyFoodEvents;
  List<NutrientsWeeklyModel>? micronutrientsWeekly;
  List<NutrientsWeeklyModel>? macronutrientsWeekly;
  List<FoodEventComplete>? weeklyLiquidEvents;
  List<SportEventComplete>? weeklySportEvents;
  List<Map<String, dynamic>>? weeklyEnergyBalance;
  double? averageConsumedKcal;
  double? averageSpentKcal;

  WeeklyDashboardDetailState({
    required this.isLoading,
    this.userMicronutrients,
    this.userRdas,
    this.userProfile,
    this.nutrientsInfoMaster,
    this.weeklyFoodEvents,
    this.micronutrientsWeekly,
    this.macronutrientsWeekly,
    this.weeklyLiquidEvents,
    this.weeklySportEvents,
    this.weeklyEnergyBalance,
    this.averageConsumedKcal,
    this.averageSpentKcal,
  });

  WeeklyDashboardDetailState copyWith({
    required bool isLoading,
    List<String>? userMicronutrients,
    List<UserRda>? userRdas,
    UserProfileModel? userProfile,
    NutrientsInfoMaster? nutrientsInfoMaster,
    List<FoodEventComplete>? weeklyFoodEvents,
    List<NutrientsWeeklyModel>? micronutrientsWeekly,
    List<NutrientsWeeklyModel>? macronutrientsWeekly,
    List<FoodEventComplete>? weeklyLiquidEvents,
    List<SportEventComplete>? weeklySportEvents,
    List<Map<String, dynamic>>? weeklyEnergyBalance,
    double? averageConsumedKcal,
    double? averageSpentKcal,
  }) {
    return WeeklyDashboardDetailState(
      isLoading: isLoading,
      userMicronutrients: userMicronutrients ?? this.userMicronutrients,
      userRdas: userRdas ?? this.userRdas,
      userProfile: userProfile ?? this.userProfile,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
      weeklyFoodEvents: weeklyFoodEvents ?? this.weeklyFoodEvents,
      micronutrientsWeekly: micronutrientsWeekly ?? this.micronutrientsWeekly,
      macronutrientsWeekly: macronutrientsWeekly ?? this.macronutrientsWeekly,
      weeklyLiquidEvents: weeklyLiquidEvents ?? this.weeklyLiquidEvents,
      weeklySportEvents: weeklySportEvents ?? this.weeklySportEvents,
      weeklyEnergyBalance: weeklyEnergyBalance ?? this.weeklyEnergyBalance,
      averageConsumedKcal: averageConsumedKcal ?? this.averageConsumedKcal,
      averageSpentKcal: averageSpentKcal ?? this.averageSpentKcal,
    );
  }
}
