import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class AddFavoriteFoodState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodInFavorite>? foodsInFavorite;
  List<FoodFavorite>? favoriteFoods;
  FoodsAndDrinksNamesMaster? foodNames;
  CookingMethodsMaster? cookingMethodsMaster;
  CookingMethodsInfoMaster? cookingMethodsInfoMaster;
  UnitsFoodsMaster? unitsFoodsMaster;
  UnitsInfoMaster? unitsInfoMaster;
  String? comment;
  bool? dish;
  String? favoriteName;
  int? mealTime;
  bool? isEdit;
  int? eventDate;

  AddFavoriteFoodState({
    required this.isLoading,
    this.onError,
    this.foodsInFavorite,
    this.favoriteFoods,
    this.foodNames,
    this.cookingMethodsMaster,
    this.cookingMethodsInfoMaster,
    this.unitsFoodsMaster,
    this.unitsInfoMaster,
    this.comment,
    this.dish,
    this.favoriteName,
    this.mealTime,
    this.isEdit,
    this.eventDate,
  });

  AddFavoriteFoodState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodInFavorite>? foodsInFavorite,
    List<FoodFavorite>? favoriteFoods,
    FoodsAndDrinksNamesMaster? foodNames,
    CookingMethodsMaster? cookingMethodsMaster,
    CookingMethodsInfoMaster? cookingMethodsInfoMaster,
    UnitsFoodsMaster? unitsFoodsMaster,
    UnitsInfoMaster? unitsInfoMaster,
    String? comment,
    bool? dish,
    String? favoriteName,
    int? mealTime,
    bool? isEdit,
    int? eventDate,
  }) {
    return AddFavoriteFoodState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      foodsInFavorite: foodsInFavorite ?? this.foodsInFavorite,
      favoriteFoods: favoriteFoods ?? this.favoriteFoods,
      foodNames: foodNames ?? this.foodNames,
      cookingMethodsMaster: cookingMethodsMaster ?? this.cookingMethodsMaster,
      cookingMethodsInfoMaster: cookingMethodsInfoMaster ?? this.cookingMethodsInfoMaster,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      unitsFoodsMaster: unitsFoodsMaster ?? this.unitsFoodsMaster,
      comment: comment ?? this.comment,
      dish: dish ?? this.dish,
      favoriteName: favoriteName ?? this.favoriteName,
      mealTime: mealTime ?? this.mealTime,
      isEdit: isEdit ?? this.isEdit,
      eventDate: eventDate ?? this.eventDate,
    );
  }
}