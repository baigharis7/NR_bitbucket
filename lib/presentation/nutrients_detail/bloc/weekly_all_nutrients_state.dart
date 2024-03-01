part of 'weekly_all_nutrients_bloc.dart';

// @immutable
// abstract class WeeklyAllNutrientsState {}

class WeeklyAllNutrientsState {
  bool isLoading;
  ErrorTypes? onError;
  List<NutrientsModel>? weeklyMicronutrients;

  WeeklyAllNutrientsState({
    required this.isLoading,
    this.onError,
    this.weeklyMicronutrients,
  });

  WeeklyAllNutrientsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<NutrientsModel>? weeklyMicronutrients,
  }) {
    return WeeklyAllNutrientsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      weeklyMicronutrients: weeklyMicronutrients ?? this.weeklyMicronutrients,
    );
  }
}
