import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';

abstract class GetLiquidFavoritesInteractor {
  Future<List<LiquidFavorite>> execute();
}