import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

class SportFavoritesActions {
  SportFavoritesActions();
}

class InitializeStateAction extends SportFavoritesActions {
  InitializeStateAction();
}

class RemoveFavoriteAction extends SportFavoritesActions {
  final AddSportFavorite sportFavorite;
  final Function onFinish;

  RemoveFavoriteAction({required this.onFinish, required this.sportFavorite});
}

class HideExplainingCardAction extends SportFavoritesActions {
  HideExplainingCardAction();
}