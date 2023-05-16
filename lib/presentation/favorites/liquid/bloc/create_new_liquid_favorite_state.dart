import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class CreateNewLiquidFavoriteState {
  bool isLoading;
  ErrorTypes? onError;
  FoodsAndDrinksNamesMaster? liquidNames;
  List<LiquidInFavorite>? liquidsInFavorite;
  CookingMethodsMaster? cookingMethodsMaster;
  CookingMethodsInfoMaster? cookingMethodsInfoMaster;
  UnitsFoodsMaster? unitsLiquidsMaster;
  UnitsInfoMaster? unitsInfoMaster;
  String? favoriteName;
  int? mealTime;

  CreateNewLiquidFavoriteState({
    required this.isLoading,
    this.onError,
    this.liquidNames,
    this.liquidsInFavorite,
    this.cookingMethodsMaster,
    this.cookingMethodsInfoMaster,
    this.unitsLiquidsMaster,
    this.unitsInfoMaster,
    this.favoriteName,
    this.mealTime,
  });

  CreateNewLiquidFavoriteState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    FoodsAndDrinksNamesMaster? liquidNames,
    List<LiquidInFavorite>? liquidsInFavorite,
    CookingMethodsMaster? cookingMethodsMaster,
    CookingMethodsInfoMaster? cookingMethodsInfoMaster,
    UnitsFoodsMaster? unitsLiquidsMaster,
    UnitsInfoMaster? unitsInfoMaster,
    String? favoriteName,
    int? mealTime,
  }) {
    return CreateNewLiquidFavoriteState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      liquidNames: liquidNames ?? this.liquidNames,
      liquidsInFavorite: liquidsInFavorite ?? this.liquidsInFavorite,
      cookingMethodsMaster: cookingMethodsMaster ?? this.cookingMethodsMaster,
      cookingMethodsInfoMaster: cookingMethodsInfoMaster ?? this.cookingMethodsInfoMaster,
      unitsLiquidsMaster: unitsLiquidsMaster ?? this.unitsLiquidsMaster,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      favoriteName: favoriteName ?? this.favoriteName,
      mealTime: mealTime ?? this.mealTime,
    );
  }

}