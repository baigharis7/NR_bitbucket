part of 'meal_time_details_bloc.dart';

// @immutable
// abstract class MealTimeDetailsState {}

class MealTimeDetailsState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodEventComplete>? foodEvents;
  UserProfileModel? profile;
  NutrientsInfoMaster? nutrientsInfoMaster;
  List<NutrientsModel>? micronutrients;
  List<NutrientsModel>? macronutrients;
  MealTime? mealTime;
  FoodsAndDrinksNamesMaster? foodNames;

  MealTimeDetailsState({required this.isLoading, this.onError, this.foodEvents, this.profile, this.nutrientsInfoMaster, this.micronutrients, this.macronutrients, this.mealTime, this.foodNames});

  MealTimeDetailsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodEventComplete>? foodEvents,
    UserProfileModel? profile,
    NutrientsInfoMaster? nutrientsInfoMaster,
    List<NutrientsModel>? micronutrients,
    List<NutrientsModel>? macronutrients,
    MealTime? mealTime,
    FoodsAndDrinksNamesMaster? foodNames,
  }) {
    return MealTimeDetailsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodEvents: foodEvents ?? this.foodEvents,
      profile: profile ?? this.profile,
      nutrientsInfoMaster: nutrientsInfoMaster ?? this.nutrientsInfoMaster,
      micronutrients: micronutrients ?? this.micronutrients,
      macronutrients: macronutrients ?? this.macronutrients,
      mealTime: mealTime ?? this.mealTime,
      foodNames: foodNames ?? this.foodNames,
    );
  }
}
