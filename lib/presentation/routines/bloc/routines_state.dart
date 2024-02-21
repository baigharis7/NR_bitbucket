part of 'routines_bloc.dart';

// @immutable
// abstract class RoutinesState {}

class RoutinesState {
  bool isLoading;
  List<SportRoutineCompleted>? routines;

  RoutinesState({
    required this.isLoading,
    this.routines,
  });

  RoutinesState copyWith({
    required bool isLoading,
    List<SportRoutineCompleted>? routines,
  }) {
    return RoutinesState(
      isLoading: isLoading,
      routines: routines ?? this.routines,
    );
  }
}
