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

  FavoritesTabsState({
    required this.isLoading,
    this.onError,
    this.favFoods,
    this.foodNames,
    this.favSports,
    this.sportsInfo,
  });

  FavoritesTabsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodFavorite>? favFoods,
    FoodsAndDrinksNamesMaster? foodNames,
    List<AddSportFavorite>? favSports,
    SportsInfoMaster? sportsInfo,
  }) {
    return FavoritesTabsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      favFoods: favFoods ?? this.favFoods,
      foodNames: foodNames ?? this.foodNames,
      favSports: favSports ?? this.favSports,
      sportsInfo: sportsInfo ?? this.sportsInfo,
    );
  }
}
