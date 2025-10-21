part of 'favorites_tabs_bloc.dart';

// @immutable
abstract class FavoritesTabsEvent {}

class InitializeFavoritesTabsEvent extends FavoritesTabsEvent {}

class RemoveFavoriteFoodFavoritesTabsEvent extends FavoritesTabsEvent {
  final FoodFavorite foodFavorite;

  RemoveFavoriteFoodFavoritesTabsEvent({required this.foodFavorite});
}

class DeleteFavoriteSportFavoritesTabsEvent extends FavoritesTabsEvent {
  AddSportFavorite sportFavorite;
  Function onFinish;

  DeleteFavoriteSportFavoritesTabsEvent({required this.sportFavorite, required this.onFinish});
}
