import 'package:nutrenaissance_flutter/data/api/masterfiles/model/conversion_factors_response.dart';
import 'package:nutrenaissance_flutter/data/api/masterfiles/model/oil_types_response.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../domain/models/foodevents/food_event_complete.dart';

class AddFoodEventState {
  bool isLoading;
  ErrorTypes? onError;
  FoodsAndDrinksNamesMaster? foodNames;
  OilTypesResponse? oilTypes;
  ConversionFactorsResponse? conversionFactors;
  List<FoodInEvent>? foodsInEvent;
  List<FoodInEvent>? foodsFromFavorite;
  CookingMethodsMaster? cookingMethodsMaster;
  CookingMethodsInfoMaster? cookingMethodsInfoMaster;
  UnitsFoodsMaster? unitsFoodsMaster;
  UnitsInfoMaster? unitsInfoMaster;
  String? foodName;
  String? comment;
  int? eventDate;
  int? eventId;
  int? mealType;
  bool? isEdit;
  List<FoodFavorite>? foodFavorites;
  List<FoodEventComplete>? weeklyFoodEvents;
  bool? isCreateDish;
  bool? isFavorite;
  bool? isCreateRoutine;

  AddFoodEventState({
    required this.isLoading,
    this.onError,
    this.foodNames,
    this.oilTypes,
    this.conversionFactors,
    this.foodsInEvent,
    this.foodsFromFavorite,
    this.cookingMethodsMaster,
    this.cookingMethodsInfoMaster,
    this.unitsFoodsMaster,
    this.unitsInfoMaster,
    this.foodName,
    this.comment,
    this.eventDate,
    this.eventId,
    this.mealType,
    this.isEdit,
    this.foodFavorites,
    this.weeklyFoodEvents,
    this.isCreateDish,
    this.isFavorite,
    this.isCreateRoutine,
  });

  AddFoodEventState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    FoodsAndDrinksNamesMaster? foodNames,
    OilTypesResponse? oilTypes,
    ConversionFactorsResponse? conversionFactors,
    List<FoodInEvent>? foodsInEvent,
    List<FoodInEvent>? foodsFromFavorite,
    CookingMethodsMaster? cookingMethodsMaster,
    CookingMethodsInfoMaster? cookingMethodsInfoMaster,
    UnitsFoodsMaster? unitsFoodsMaster,
    UnitsInfoMaster? unitsInfoMaster,
    String? foodName,
    String? comment,
    int? eventDate,
    int? eventId,
    int? mealType,
    bool? isEdit,
    List<FoodFavorite>? foodFavorites,
    List<FoodEventComplete>? weeklyFoodEvents,
    bool? isCreateDish,
    bool? isFavorite,
    bool? isCreateRoutine,
  }) {
    return AddFoodEventState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodNames: foodNames ?? this.foodNames,
      oilTypes: oilTypes ?? this.oilTypes,
      conversionFactors: conversionFactors ?? this.conversionFactors,
      foodsInEvent: foodsInEvent ?? this.foodsInEvent,
      cookingMethodsMaster: cookingMethodsMaster ?? this.cookingMethodsMaster,
      cookingMethodsInfoMaster: cookingMethodsInfoMaster ?? this.cookingMethodsInfoMaster,
      unitsFoodsMaster: unitsFoodsMaster ?? this.unitsFoodsMaster,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      foodName: foodName ?? this.foodName,
      comment: comment ?? this.comment,
      eventDate: eventDate ?? this.eventDate,
      eventId: eventId ?? this.eventId,
      mealType: mealType ?? this.mealType,
      isEdit: isEdit ?? this.isEdit,
      foodFavorites: foodFavorites ?? this.foodFavorites,
      foodsFromFavorite: foodsFromFavorite ?? this.foodsFromFavorite,
      weeklyFoodEvents: weeklyFoodEvents ?? this.weeklyFoodEvents,
      isCreateDish: isCreateDish ?? this.isCreateDish,
      isFavorite: isFavorite ?? this.isFavorite,
      isCreateRoutine: isCreateRoutine ?? this.isCreateRoutine,
    );
  }
}