part of 'routines_bloc.dart';

// @immutable
// abstract class RoutinesState {}

class RoutinesState {
  bool isLoading;
  ErrorTypes? onError;
  List<SportRoutineCompleted>? routines;

  RoutinesState({
    required this.isLoading,
    this.onError,
    this.routines,
  });

  RoutinesState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<SportRoutineCompleted>? routines,
  }) {
    return RoutinesState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      routines: routines ?? this.routines,
    );
  }
}
