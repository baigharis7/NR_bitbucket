import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';

abstract class UploadLiquidFavoriteInteractor {
  Future<bool> execute(LiquidFavorite liquidFavorite);
}