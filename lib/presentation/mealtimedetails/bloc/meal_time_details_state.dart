part of 'meal_time_details_bloc.dart';

// @immutable
// abstract class MealTimeDetailsState {}

class MealTimeDetailsState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodEventComplete>? foodEvents;
  UserProfileModel? profile;
  NutrientsInfoMaster? nutrientsInfoMaster;
  UnitsInfoMaster? unitsInfoMaster;
  List<NutrientsModel>? micronutrients;
  List<NutrientsModel>? macronutrients;
  MealTime? mealTime;
  FoodsAndDrinksNamesMaster? foodNames;
  DateTime? selectedDateTime;

  MealTimeDetailsState({required this.isLoading, this.onError, this.foodEvents, this.profile, this.nutrientsInfoMaster, this.unitsInfoMaster, this.micronutrients, this.macronutrients, this.mealTime, this.foodNames, this.selectedDateTime});

  MealTimeDetailsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodEventComplete>? foodEvents,
    UserProfileModel? profile,
    NutrientsInfoMaster? nutrientsInfoMaster,
    UnitsInfoMaster? unitsInfoMaster,
    List<NutrientsModel>? micronutrients,
    List<NutrientsModel>? macronutrients,
    MealTime? mealTime,
    FoodsAndDrinksNamesMaster? foodNames,
    DateTime? selectedDateTime,
  }) {
    return MealTimeDetailsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodEvents: foodEvents ?? this.foodEvents,
      profile: profile ?? this.profile,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      micronutrients: micronutrients ?? this.micronutrients,
      macronutrients: macronutrients ?? this.macronutrients,
      mealTime: mealTime ?? this.mealTime,
      foodNames: foodNames ?? this.foodNames,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
    );
  }
}
