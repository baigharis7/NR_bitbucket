import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';

abstract class SaveLiquidFavoriteInteractor {
  Future<void> execute(LiquidFavorite liquidFavorite);
}