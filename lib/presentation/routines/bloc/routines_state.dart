part of 'routines_bloc.dart';

// @immutable
// abstract class RoutinesState {}

class RoutinesState {
  bool isLoading;
  ErrorTypes? onError;
  List<SportRoutineCompleted>? routines;
  List<AddSportFavorite>? sportsFavorite;

  RoutinesState({
    required this.isLoading,
    this.onError,
    this.routines,
    this.sportsFavorite,
  });

  RoutinesState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<SportRoutineCompleted>? routines,
    List<AddSportFavorite>? sportsFavorite,
  }) {
    return RoutinesState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      routines: routines ?? this.routines,
      sportsFavorite: sportsFavorite ?? this.sportsFavorite,
    );
  }
}
