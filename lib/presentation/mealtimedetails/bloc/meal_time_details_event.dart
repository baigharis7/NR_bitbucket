part of 'meal_time_details_bloc.dart';

// @immutable
abstract class MealTimeDetailsEvent {}

class InitialMealTimeDetailsEventState extends MealTimeDetailsEvent {}

class UpdateMealTimeDetailsEventState extends MealTimeDetailsEvent {
  final MealTime mealTime;

  UpdateMealTimeDetailsEventState({required this.mealTime});
}
