part of 'favorites_tabs_bloc.dart';

// @immutable
// abstract class FavoritesTabsState {}

class FavoritesTabsState {
  bool isLoading;
  ErrorTypes? onError;
  List<FoodFavorite>? favFoods;
  FoodsAndDrinksNamesMaster? foodNames;

  FavoritesTabsState({
    required this.isLoading,
    this.onError,
    this.favFoods,
    this.foodNames,
  });

  FavoritesTabsState copyWith({
    required bool isLoading,
    ErrorTypes? onError,
    List<FoodFavorite>? favFoods,
    FoodsAndDrinksNamesMaster? foodNames,
  }) {
    return FavoritesTabsState(
      isLoading: isLoading,
      onError: onError ?? this.onError,
      favFoods: favFoods ?? this.favFoods,
      foodNames: foodNames ?? this.foodNames,
    );
  }
}
