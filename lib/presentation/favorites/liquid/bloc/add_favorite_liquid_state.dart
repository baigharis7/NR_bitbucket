import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_info_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/cooking_methods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/food_names_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_foods_master.dart';
import 'package:nutrenaissance_flutter/domain/models/masterfiles/units_info_master.dart';
import 'package:nutrenaissance_flutter/infrastructure/errors/error_types.dart';

class AddFavoriteLiquidState {
  bool isLoading;
  ErrorTypes? onError;
  List<LiquidInFavorite>? liquidsInFavorite;
  FoodsAndDrinksNamesMaster? liquidNames;
  CookingMethodsMaster? cookingMethodsMaster;
  CookingMethodsInfoMaster? cookingMethodsInfoMaster;
  UnitsFoodsMaster? unitsFoodsMaster;
  UnitsInfoMaster? unitsInfoMaster;
  String? comment;
  String? favoriteName;
  int? mealTime;

  AddFavoriteLiquidState({
    required this.isLoading,
    this.onError,
    this.liquidsInFavorite,
    this.liquidNames,
    this.cookingMethodsMaster,
    this.cookingMethodsInfoMaster,
    this.unitsInfoMaster,
    this.unitsFoodsMaster,
    this.comment,
    this.favoriteName,
    this.mealTime,
  });

  AddFavoriteLiquidState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<LiquidInFavorite>? liquidsInFavorite,
    FoodsAndDrinksNamesMaster? liquidNames,
    CookingMethodsMaster? cookingMethodsMaster,
    CookingMethodsInfoMaster? cookingMethodsInfoMaster,
    UnitsFoodsMaster? unitsFoodsMaster,
    UnitsInfoMaster? unitsInfoMaster,
    String? comment,
    String? favoriteName,
    int? mealTime,
  }) {
    return AddFavoriteLiquidState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      liquidsInFavorite: liquidsInFavorite ?? this.liquidsInFavorite,
      liquidNames: liquidNames ?? this.liquidNames,
      cookingMethodsMaster: cookingMethodsMaster ?? this.cookingMethodsMaster,
      cookingMethodsInfoMaster: cookingMethodsInfoMaster ?? this.cookingMethodsInfoMaster,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
      unitsFoodsMaster: unitsFoodsMaster ?? this.unitsFoodsMaster,
      comment: comment ?? this.comment,
      favoriteName: favoriteName ?? this.favoriteName,
      mealTime: mealTime ?? this.mealTime,
    );
  }
}