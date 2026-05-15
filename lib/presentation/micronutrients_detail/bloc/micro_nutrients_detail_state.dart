part of 'micro_nutrients_detail_bloc.dart';

class MicroNutrientsDetailState {
  bool isLoading;
  List<NutrientsModel>? microNutrients;
  List<NutrientsModel>? temporaryMicronutrients;
  List<FoodEventComplete>? weeklyFoodEvents;
  List<NutrientsWeeklyModel>? micronutrientsWeekly;
  List<NutrientsWeeklyModel>? temporaryMicronutrientsWeekly;
  NutrientsInfoMaster? nutrientsInfoMaster;
  UserProfileModel? profile;
  List<FoodEventComplete>? foodEvents;
  List<SupplementSimple>? supplementEvents;
  SupplementsInfoMaster? supplementsInfoMaster;
  List<NutrientsModel>? allMicronutrients;
  List<NutrientsModel>? filteredNutrientsLess15RDA;
  List<NutrientsWeeklyModel>? filteredNutrientsLess15RDAWeekly;
  List<NutrientsWeeklyModel>? allMicronutrientsWeekly;

  MicroNutrientsDetailState({
    required this.isLoading,
    this.microNutrients,
    this.temporaryMicronutrients,
    this.weeklyFoodEvents,
    this.micronutrientsWeekly,
    this.temporaryMicronutrientsWeekly,
    this.nutrientsInfoMaster,
    this.profile,
    this.foodEvents,
    this.supplementEvents,
    this.supplementsInfoMaster,
    this.allMicronutrients,
    this.filteredNutrientsLess15RDA,
    this.filteredNutrientsLess15RDAWeekly,
    this.allMicronutrientsWeekly,
  });

  MicroNutrientsDetailState copyWith({
    required bool isLoading,
    List<NutrientsModel>? microNutrients,
    List<NutrientsModel>? temporaryMicronutrients,
    List<FoodEventComplete>? weeklyFoodEvents,
    List<NutrientsWeeklyModel>? micronutrientsWeekly,
    List<NutrientsWeeklyModel>? temporaryMicronutrientsWeekly,
    NutrientsInfoMaster? nutrientsInfoMaster,
    UserProfileModel? profile,
    List<FoodEventComplete>? foodEvents,
    List<SupplementSimple>? supplementEvents,
    SupplementsInfoMaster? supplementsInfoMaster,
    List<NutrientsModel>? allMicronutrients,
    List<NutrientsModel>? filteredNutrientsLess15RDA,
    List<NutrientsWeeklyModel>? filteredNutrientsLess15RDAWeekly,
    List<NutrientsWeeklyModel>? allMicronutrientsWeekly,
  }) {
    return MicroNutrientsDetailState(
      isLoading: isLoading,
      microNutrients: microNutrients ?? this.microNutrients,
      temporaryMicronutrients: temporaryMicronutrients ?? this.temporaryMicronutrients,
      weeklyFoodEvents: weeklyFoodEvents ?? this.weeklyFoodEvents,
      micronutrientsWeekly: micronutrientsWeekly ?? this.micronutrientsWeekly,
      temporaryMicronutrientsWeekly: temporaryMicronutrientsWeekly ?? this.temporaryMicronutrientsWeekly,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
      profile: profile ?? this.profile,
      foodEvents: foodEvents ?? this.foodEvents,
      supplementEvents: supplementEvents ?? this.supplementEvents,
      supplementsInfoMaster: supplementsInfoMaster ?? this.supplementsInfoMaster,
      allMicronutrients:  allMicronutrients ?? this.allMicronutrients,
      filteredNutrientsLess15RDA: filteredNutrientsLess15RDA ?? this.filteredNutrientsLess15RDA,
      filteredNutrientsLess15RDAWeekly: filteredNutrientsLess15RDAWeekly ?? this.filteredNutrientsLess15RDAWeekly,
      allMicronutrientsWeekly: allMicronutrientsWeekly ?? this.allMicronutrientsWeekly,
    );
  }
}
