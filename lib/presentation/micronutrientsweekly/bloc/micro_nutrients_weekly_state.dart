part of 'micro_nutrients_weekly_bloc.dart';

// @immutable
// abstract class MicroNutrientsWeeklyState {}

class MicroNutrientsWeeklyState {
  bool isLoading;
  ErrorTypes? onError;
  List<NutrientsWeeklyModel>? micronutrientsWeekly;

  MicroNutrientsWeeklyState({ required this.isLoading, this.onError, this.micronutrientsWeekly});

  MicroNutrientsWeeklyState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<NutrientsWeeklyModel>? micronutrientsWeekly,
  }) {
    return MicroNutrientsWeeklyState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      micronutrientsWeekly: micronutrientsWeekly ?? this.micronutrientsWeekly,
    );
  }
}
