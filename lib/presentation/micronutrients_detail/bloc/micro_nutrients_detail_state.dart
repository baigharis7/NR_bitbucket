part of 'micro_nutrients_detail_bloc.dart';

class MicroNutrientsDetailState {
  bool isLoading;
  List<NutrientsModel>? microNutrients;
  List<String>? userMicronutrients;
  List<FoodEventComplete>? weeklyFoodEvents;
  List<NutrientsWeeklyModel>? micronutrientsWeekly;
  NutrientsInfoMaster? nutrientsInfoMaster;
  List<UserRda>? userRdas;
  UserProfileModel? profile;

  MicroNutrientsDetailState({
    required this.isLoading,
    this.microNutrients,
    this.userMicronutrients,
    this.weeklyFoodEvents,
    this.micronutrientsWeekly,
    this.nutrientsInfoMaster,
    this.userRdas,
    this.profile,
  });

  MicroNutrientsDetailState copyWith({
    required bool isLoading,
    List<NutrientsModel>? microNutrients,
    List<String>? userMicronutrients,
    List<FoodEventComplete>? weeklyFoodEvents,
    List<NutrientsWeeklyModel>? micronutrientsWeekly,
    NutrientsInfoMaster? nutrientsInfoMaster,
    List<UserRda>? userRdas,
    UserProfileModel? profile,
  }) {
    return MicroNutrientsDetailState(
      isLoading: isLoading,
      microNutrients: microNutrients ?? this.microNutrients,
      userMicronutrients: userMicronutrients ?? this.userMicronutrients,
      weeklyFoodEvents: weeklyFoodEvents ?? this.weeklyFoodEvents,
      micronutrientsWeekly: micronutrientsWeekly ?? this.micronutrientsWeekly,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
      userRdas: userRdas ?? this.userRdas,
      profile: profile ?? this.profile,
    );
  }
}
