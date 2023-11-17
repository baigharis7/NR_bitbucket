import 'package:nutrenaissance_flutter/domain/models/favorites/sport/add_sport_favorite.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

abstract class UploadSportFavoriteInteractor {
  Future<bool> execute(AddSportFavorite sportFavorite);
}