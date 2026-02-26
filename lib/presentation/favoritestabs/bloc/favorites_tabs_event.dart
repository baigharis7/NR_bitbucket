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

  DeleteFavoriteSportFavoritesTabsEvent({required this.sportFavorite,});
}

class DeleteSupplementFavoriteFavoritesTabsEvent extends FavoritesTabsEvent {
  final SupplementSimple supplementSimple;

  DeleteSupplementFavoriteFavoritesTabsEvent({required this.supplementSimple});
}

class _RefreshFavoritesCategoryEvent extends FavoritesTabsEvent {
  final DataChangedCategory category;

  _RefreshFavoritesCategoryEvent(this.category);
}
