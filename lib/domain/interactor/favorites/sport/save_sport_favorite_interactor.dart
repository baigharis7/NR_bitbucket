import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

abstract class SaveSportFavoriteInteractor {
  Future<bool> execute(SportFavorite sportFavorite, bool isEdit);
}