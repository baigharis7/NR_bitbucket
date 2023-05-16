import 'package:nutrenaissance_flutter/domain/models/favorites/sport/sport_favorite.dart';

abstract class RemoveSportFavoriteInteractor {
  Future<bool> execute(SportFavorite sportFavorite, String userId);
}