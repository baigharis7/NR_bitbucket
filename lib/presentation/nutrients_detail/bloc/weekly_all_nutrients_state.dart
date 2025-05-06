part of 'weekly_all_nutrients_bloc.dart';

// @immutable
// abstract class WeeklyAllNutrientsState {}

class WeeklyAllNutrientsState {
  bool isLoading;
  ErrorTypes? onError;
  List<NutrientsModel>? weeklyMicronutrients;
  UserProfileModel? profile;
  NutrientsInfoMaster? nutrientsInfoMaster;
  List<FoodEventComplete>? weeklyFoodEvents;

  WeeklyAllNutrientsState({
    required this.isLoading,
    this.onError,
    this.weeklyMicronutrients,
    this.profile,
    this.nutrientsInfoMaster,
  });

  WeeklyAllNutrientsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<NutrientsModel>? weeklyMicronutrients,
    UserProfileModel? profile,
    NutrientsInfoMaster? nutrientsInfoMaster,
  }) {
    return WeeklyAllNutrientsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      weeklyMicronutrients: weeklyMicronutrients ?? this.weeklyMicronutrients,
      profile: profile ?? this.profile,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
    );
  }
}
