part of 'routines_tab_bloc.dart';

// @immutable
// abstract class RoutinesTabState {}

class RoutinesTabState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodRoutineEvent>? mealRoutines;
  FoodsAndDrinksNamesMaster? foodNames;
  List<SportRoutineCompleted>? sportRoutines;
  SportsInfoMaster? sportsInfo;

  RoutinesTabState({
    required this.isLoading,
    this.onError,
    this.mealRoutines,
    this.foodNames,
    this.sportRoutines,
    this.sportsInfo,
  });

  RoutinesTabState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodRoutineEvent>? mealRoutines,
    FoodsAndDrinksNamesMaster? foodNames,
    List<SportRoutineCompleted>? sportRoutines,
    SportsInfoMaster? sportsInfo,
  }) {
    return RoutinesTabState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      mealRoutines: mealRoutines ?? this.mealRoutines,
      foodNames: foodNames ?? this.foodNames,
      sportRoutines: sportRoutines ?? this.sportRoutines,
      sportsInfo: sportsInfo ?? this.sportsInfo,
    );
  }
}
