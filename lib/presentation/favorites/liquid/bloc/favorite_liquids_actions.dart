import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';

class FavoriteLiquidsActions {
  FavoriteLiquidsActions();
}

class InitializeState extends FavoriteLiquidsActions {
  InitializeState();
}

class RemoveFavoriteAction extends FavoriteLiquidsActions {
  final LiquidFavorite liquidFavorite;
  final Function onFinish;

  RemoveFavoriteAction({required this.onFinish, required this.liquidFavorite});
}