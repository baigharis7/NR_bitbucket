part of 'favorites_tabs_bloc.dart';

// @immutable
// abstract class FavoritesTabsState {}

class FavoritesTabsState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodFavorite>? favFoods;
  FoodsAndDrinksNamesMaster? foodNames;
  List<AddSportFavorite>? favSports;
  SportsInfoMaster? sportsInfo;
  SupplementsInfoMaster? supplementsInfo;
  List<SupplementSimple>? favSupplements;
  UnitsInfoMaster? unitsInfoMaster;

  FavoritesTabsState({
    required this.isLoading,
    this.onError,
    this.favFoods,
    this.foodNames,
    this.favSports,
    this.sportsInfo,
    this.supplementsInfo,
    this.favSupplements,
    this.unitsInfoMaster,
  });

  FavoritesTabsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodFavorite>? favFoods,
    FoodsAndDrinksNamesMaster? foodNames,
    List<AddSportFavorite>? favSports,
    SportsInfoMaster? sportsInfo,
    SupplementsInfoMaster? supplementsInfo,
    List<SupplementSimple>? favSupplements,
    UnitsInfoMaster? unitsInfoMaster,
  }) {
    return FavoritesTabsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      favFoods: favFoods ?? this.favFoods,
      foodNames: foodNames ?? this.foodNames,
      favSports: favSports ?? this.favSports,
      sportsInfo: sportsInfo ?? this.sportsInfo,
      supplementsInfo: supplementsInfo ?? this.supplementsInfo,
      favSupplements: favSupplements ?? this.favSupplements,
      unitsInfoMaster: unitsInfoMaster ?? this.unitsInfoMaster,
    );
  }
}
