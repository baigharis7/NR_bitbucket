import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';

abstract class GetRecentSportItemsInteractor {
  Future<List<AddSportFavorite>> execute();
}
