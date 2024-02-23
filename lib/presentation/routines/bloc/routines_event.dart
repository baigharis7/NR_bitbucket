part of 'routines_bloc.dart';

// @immutable
abstract class RoutinesEvent {}

class RoutinesInitialStateAction extends RoutinesEvent {}

class RoutineDeleteEventAction extends RoutinesEvent {
  final SportRoutineCompleted sportRoutineCompleted;
  final Function onFinish;

  RoutineDeleteEventAction({required this.sportRoutineCompleted, required this.onFinish});
}