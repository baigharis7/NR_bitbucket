part of 'routines_tab_bloc.dart';

// @immutable
abstract class RoutinesTabEvent {}

class InitializeRoutinesTabEvent extends RoutinesTabEvent {}

class DeleteFoodRoutineActionRoutinesTabEvent extends RoutinesTabEvent {
  final FoodRoutineEvent foodRoutineEvent;

  DeleteFoodRoutineActionRoutinesTabEvent({required this.foodRoutineEvent});
}

class DeleteSportRoutineAction extends RoutinesTabEvent {
  final SportRoutineCompleted sportRoutineCompleted;

  DeleteSportRoutineAction({required this.sportRoutineCompleted});
}
