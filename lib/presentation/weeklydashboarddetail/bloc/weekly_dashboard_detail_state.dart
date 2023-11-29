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

  WeeklyDashboardDetailState({required this.isLoading, this.userMicronutrients, this.userRdas, this.userProfile, this.nutrientsInfoMaster, this.weeklyFoodEvents, this.micronutrientsWeekly, this.macronutrientsWeekly});

  WeeklyDashboardDetailState copyWith({
    required bool isLoading,
    List<String>? userMicronutrients,
    List<UserRda>? userRdas,
    UserProfileModel? userProfile,
    NutrientsInfoMaster? nutrientsInfoMaster,
    List<FoodEventComplete>? weeklyFoodEvents,
    List<NutrientsWeeklyModel>? micronutrientsWeekly,
    List<NutrientsWeeklyModel>? macronutrientsWeekly,
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
    );
  }
}
