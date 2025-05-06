part of 'micro_nutrients_detail_bloc.dart';

class MicroNutrientsDetailState {
  bool isLoading;
  List<NutrientsModel>? microNutrients;
  List<FoodEventComplete>? weeklyFoodEvents;
  List<NutrientsWeeklyModel>? micronutrientsWeekly;
  NutrientsInfoMaster? nutrientsInfoMaster;
  UserProfileModel? profile;

  MicroNutrientsDetailState({
    required this.isLoading,
    this.microNutrients,
    this.weeklyFoodEvents,
    this.micronutrientsWeekly,
    this.nutrientsInfoMaster,
    this.profile,
  });

  MicroNutrientsDetailState copyWith({
    required bool isLoading,
    List<NutrientsModel>? microNutrients,
    List<FoodEventComplete>? weeklyFoodEvents,
    List<NutrientsWeeklyModel>? micronutrientsWeekly,
    NutrientsInfoMaster? nutrientsInfoMaster,
    UserProfileModel? profile,
  }) {
    return MicroNutrientsDetailState(
      isLoading: isLoading,
      microNutrients: microNutrients ?? this.microNutrients,
      weeklyFoodEvents: weeklyFoodEvents ?? this.weeklyFoodEvents,
      micronutrientsWeekly: micronutrientsWeekly ?? this.micronutrientsWeekly,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
      profile: profile ?? this.profile,
    );
  }
}
