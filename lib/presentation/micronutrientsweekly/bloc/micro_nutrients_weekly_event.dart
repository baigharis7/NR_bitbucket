part of 'micro_nutrients_weekly_bloc.dart';

// @immutable
abstract class MicroNutrientsWeeklyEvent {}

class InitializationEventAction extends MicroNutrientsWeeklyEvent {}

class UpdateWeeklyListOfNutrients extends MicroNutrientsWeeklyEvent {
  final List<NutrientsWeeklyModel> micronutrientsWeekly;

  UpdateWeeklyListOfNutrients({required this.micronutrientsWeekly});
}
