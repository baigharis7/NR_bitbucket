import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

import '../../../models/favorites/sport/add_sport_favorite.dart';

abstract class GetSportFavoritesInteractor {
  Future<List<AddSportFavorite>> execute();
}