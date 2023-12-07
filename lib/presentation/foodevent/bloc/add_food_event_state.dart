import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/foodevents/food_event_simple.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class AddFoodEventState {
  bool isLoading;
  ErrorTypes? onError;
  FoodsAndDrinksNamesMaster? foodNames;
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
  bool? isEdit;
  List<FoodFavorite>? foodFavorites;

  AddFoodEventState({
    required this.isLoading,
    this.onError,
    this.foodNames,
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
    this.isEdit,
    this.foodFavorites,
  });

  AddFoodEventState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    FoodsAndDrinksNamesMaster? foodNames,
    List<FoodInEvent>? foodsInEvent,
    List<FoodInEvent>? foodsFromFavorite,
    CookingMethodsMaster? cookingMethodsMaster,
    CookingMethodsInfoMaster? cookingMethodsInfoMaster,
    UnitsFoodsMaster? unitsFoodsMaster,
    UnitsInfoMaster? unitsInfoMaster,
    String? foodName,
    String? comment,
    int? eventDate,
    bool? isEdit,
    List<FoodFavorite>? foodFavorites,
  }) {
    return AddFoodEventState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodNames: foodNames ?? this.foodNames,
      foodsInEvent: foodsInEvent ?? this.foodsInEvent,
      cookingMethodsMaster: cookingMethodsMaster ?? this.cookingMethodsMaster,
      cookingMethodsInfoMaster: cookingMethodsInfoMaster ?? this.cookingMethodsInfoMaster,
      unitsFoodsMaster: unitsFoodsMaster ?? this.unitsFoodsMaster,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      foodName: foodName ?? this.foodName,
      comment: comment ?? this.comment,
      eventDate: eventDate,
      isEdit: isEdit ?? this.isEdit,
      foodFavorites: foodFavorites ?? this.foodFavorites,
      foodsFromFavorite: foodsFromFavorite ?? this.foodsFromFavorite,
    );
  }
}