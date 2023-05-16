import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

abstract class GetSportFavoritesInteractor {
  Future<List<SportFavorite>> execute();
}