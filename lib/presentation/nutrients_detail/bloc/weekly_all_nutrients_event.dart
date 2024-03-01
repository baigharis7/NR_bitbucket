part of 'weekly_all_nutrients_bloc.dart';

// @immutable
abstract class WeeklyAllNutrientsEventActions {}

class InitializationEventAction extends WeeklyAllNutrientsEventActions {}

class UpdateWeeklyListOfNutrients extends WeeklyAllNutrientsEventActions {
  final List<NutrientsModel> weeklyMicronutrients;

  UpdateWeeklyListOfNutrients({required this.weeklyMicronutrients});
}
