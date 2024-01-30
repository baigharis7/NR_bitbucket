import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

import '../../../../domain/models/foodevents/food_event_complete.dart';

class CreateNewFoodFavoriteState {
  bool isLoading;
  ErrorTypes? onError;
  int? eventDate;
  bool? isEdit;
  FoodsAndDrinksNamesMaster? foodNames;
  List<FoodInFavorite>? foodsInFavorite;
  CookingMethodsMaster? cookingMethodsMaster;
  CookingMethodsInfoMaster? cookingMethodsInfoMaster;
  UnitsFoodsMaster? unitsFoodsMaster;
  UnitsInfoMaster? unitsInfoMaster;
  String? favoriteName;
  int? mealTime;
  String? comment;
  List<FoodFavorite>? frequentFoodEvents;
  List<FoodInFavorite>? foodsFromFrequent;

  CreateNewFoodFavoriteState({
    required this.isLoading,
    this.onError,
    this.eventDate,
    this.isEdit,
    this.foodNames,
    this.foodsInFavorite,
    this.cookingMethodsMaster,
    this.cookingMethodsInfoMaster,
    this.unitsFoodsMaster,
    this.unitsInfoMaster,
    this.favoriteName,
    this.mealTime,
    this.comment,
    this.frequentFoodEvents,
    this.foodsFromFrequent,
  });

  CreateNewFoodFavoriteState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    int? eventDate,
    bool? isEdit,
    FoodsAndDrinksNamesMaster? foodNames,
    List<FoodInFavorite>? foodsInFavorite,
    CookingMethodsMaster? cookingMethodsMaster,
    CookingMethodsInfoMaster? cookingMethodsInfoMaster,
    UnitsFoodsMaster? unitsFoodsMaster,
    UnitsInfoMaster? unitsInfoMaster,
    String? favoriteName,
    int? mealTime,
    String? comment,
    List<FoodFavorite>? frequentFoodEvents,
    List<FoodInFavorite>? foodsFromFrequent,
  }) {
    return CreateNewFoodFavoriteState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      eventDate: eventDate ?? this.eventDate,
      isEdit: isEdit ?? this.isEdit,
      foodNames: foodNames ?? this.foodNames,
      foodsInFavorite: foodsInFavorite ?? this.foodsInFavorite,
      cookingMethodsMaster: cookingMethodsMaster ?? this.cookingMethodsMaster,
      cookingMethodsInfoMaster: cookingMethodsInfoMaster ?? this.cookingMethodsInfoMaster,
      unitsFoodsMaster: unitsFoodsMaster ?? this.unitsFoodsMaster,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      favoriteName: favoriteName ?? this.favoriteName,
      mealTime: mealTime ?? this.mealTime,
      comment: comment ?? this.comment,
      frequentFoodEvents: frequentFoodEvents ?? this.frequentFoodEvents,
      foodsFromFrequent: foodsFromFrequent ?? this.foodsFromFrequent,
    );
  }

}