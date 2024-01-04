part of 'macro_nutrients_detail_bloc.dart';


class MacroNutrientsDetailState {
  bool isLoading;
  List<NutrientsModel>? macronutrients;
  List<NutrientsWeeklyModel>? macronutrientsWeekly;
  NutrientsInfoMaster? nutrientsInfoMaster;
  UserProfileModel? userProfile;
  List<FoodEventComplete>? weeklyFoodEvents;

  MacroNutrientsDetailState({
    required this.isLoading,
    this.macronutrients,
    this.macronutrientsWeekly,
    this.nutrientsInfoMaster,
    this.userProfile,
    this.weeklyFoodEvents,
  });

  MacroNutrientsDetailState copyWith({
    required isLoading,
    List<NutrientsModel>? macronutrients,
    List<NutrientsWeeklyModel>? macronutrientsWeekly,
    NutrientsInfoMaster? nutrientsInfoMaster,
    UserProfileModel? userProfile,
    List<FoodEventComplete>? weeklyFoodEvents,
  }) {
    return MacroNutrientsDetailState(
      isLoading: isLoading ?? this.isLoading,
      macronutrients: macronutrients ?? this.macronutrients,
      macronutrientsWeekly: macronutrientsWeekly ?? this.macronutrientsWeekly,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
      userProfile: userProfile ?? this.userProfile,
      weeklyFoodEvents: weeklyFoodEvents ?? this.weeklyFoodEvents,
    );
  }
}
