part of 'item_update_bloc.dart';

// @immutable
// abstract class ItemUpdateState {}

class ItemUpdateState {
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

  ItemUpdateState({
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

  ItemUpdateState copyWith({
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
    return ItemUpdateState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodNames: foodNames ?? this.foodNames,
      oilTypes: oilTypes ?? this.oilTypes,
      conversionFactors: conversionFactors ?? this.conversionFactors,
      cookingMethodsMaster: cookingMethodsMaster ?? this.cookingMethodsMaster,
      cookingMethodsInfoMaster:
          cookingMethodsInfoMaster ?? this.cookingMethodsInfoMaster,
      unitsFoodsMaster: unitsFoodsMaster ?? this.unitsFoodsMaster,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      foodEvent: foodEvent ?? this.foodEvent,
    );
  }
}
