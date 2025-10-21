part of 'routines_tab_bloc.dart';

// @immutable
// abstract class RoutinesTabState {}

class RoutinesTabState {
  bool isLoading;
  ErrorTypes? onError;
  UnitsInfoMaster? unitsInfoMaster;
  List<FoodRoutineEvent>? mealRoutines;
  FoodsAndDrinksNamesMaster? foodNames;
  List<SportRoutineCompleted>? sportRoutines;
  List<SupplementSimple>? supplementRoutines;
  SportsInfoMaster? sportsInfo;
  SupplementsInfoMaster? supplementsInfo;

  RoutinesTabState({
    required this.isLoading,
    this.onError,
    this.unitsInfoMaster,
    this.mealRoutines,
    this.foodNames,
    this.sportRoutines,
    this.supplementRoutines,
    this.sportsInfo,
    this.supplementsInfo,
  });

  RoutinesTabState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    UnitsInfoMaster? unitsInfoMaster,
    List<FoodRoutineEvent>? mealRoutines,
    FoodsAndDrinksNamesMaster? foodNames,
    List<SportRoutineCompleted>? sportRoutines,
    List<SupplementSimple>? supplementRoutines,
    SportsInfoMaster? sportsInfo,
    SupplementsInfoMaster? supplementsInfo,
  }) {
    return RoutinesTabState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      mealRoutines: mealRoutines ?? this.mealRoutines,
      foodNames: foodNames ?? this.foodNames,
      sportRoutines: sportRoutines ?? this.sportRoutines,
      supplementRoutines: supplementRoutines ?? this.supplementRoutines,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      supplementsInfo: supplementsInfo ?? this.supplementsInfo,
    );
  }
}
