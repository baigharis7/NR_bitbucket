import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';

abstract class RemoveLiquidFavoriteFromLocalInteractor {
  Future<bool> execute(LiquidFavorite liquidFavorite);
}