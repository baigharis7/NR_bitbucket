part of 'update_meal_bloc.dart';

// @immutable
// abstract class UpdateMealState {}

class UpdateMealState {
  bool isLoading;
  ErrorTypes? onError;
  FoodsAndDrinksNamesMaster? foodNames;
  OilTypesResponse? oilTypes;
  ConversionFactorsResponse? conversionFactors;
  CookingMethodsMaster? cookingMethodsMaster;
  CookingMethodsInfoMaster? cookingMethodsInfoMaster;
  UnitsFoodsMaster? unitsFoodsMaster;
  UnitsInfoMaster? unitsInfoMaster;
  FoodFavorite? foodEvent;

  UpdateMealState({
    required this.isLoading,
    this.onError,
    this.foodNames,
    this.oilTypes,
    this.conversionFactors,
    this.cookingMethodsMaster,
    this.cookingMethodsInfoMaster,
    this.unitsFoodsMaster,
    this.unitsInfoMaster,
    this.foodEvent,
  });

  UpdateMealState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    FoodsAndDrinksNamesMaster? foodNames,
    OilTypesResponse? oilTypes,
    ConversionFactorsResponse? conversionFactors,
    CookingMethodsMaster? cookingMethodsMaster,
    CookingMethodsInfoMaster? cookingMethodsInfoMaster,
    UnitsFoodsMaster? unitsFoodsMaster,
    UnitsInfoMaster? unitsInfoMaster,
    FoodFavorite? foodEvent,
  }) {
    return UpdateMealState(
      isLoading: isLoading,
      onError: onError,
      foodNames: foodNames ?? this.foodNames,
      oilTypes: oilTypes ?? this.oilTypes,
      conversionFactors: conversionFactors ?? this.conversionFactors,
      cookingMethodsMaster: cookingMethodsMaster ?? this.cookingMethodsMaster,
      cookingMethodsInfoMaster: cookingMethodsInfoMaster ?? this.cookingMethodsInfoMaster,
      unitsFoodsMaster: unitsFoodsMaster ?? this.unitsFoodsMaster,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      foodEvent: foodEvent ?? this.foodEvent,
    );
  }
}
