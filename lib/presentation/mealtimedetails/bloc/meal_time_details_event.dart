part of 'meal_time_details_bloc.dart';

// @immutable
abstract class MealTimeDetailsEvent {}

class InitialMealTimeDetailsEventState extends MealTimeDetailsEvent {
  final DateTime? dateTime;

  InitialMealTimeDetailsEventState({this.dateTime});
}

class UpdateFoodArgumentsModelEventState extends MealTimeDetailsEvent {
  final FoodArgumentsModel foodArgumentsModel;

  UpdateFoodArgumentsModelEventState({required this.foodArgumentsModel});
}

class UpdateDateTimeMealTimeDetailsEvent extends MealTimeDetailsEvent {
  final DateTime dateTime;

  UpdateDateTimeMealTimeDetailsEvent({required this.dateTime});
}

class DeleteFoodMealTimeDetailsEventAction extends MealTimeDetailsEvent {
  final FoodEventComplete foodEventComplete;
  final Function onFinish;

  DeleteFoodMealTimeDetailsEventAction({required this.foodEventComplete, required this.onFinish});
}