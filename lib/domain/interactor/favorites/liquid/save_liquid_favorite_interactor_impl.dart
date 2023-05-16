import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/save_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class SaveLiquidFavoriteInteractorImpl extends SaveLiquidFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  SaveLiquidFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<void> execute(LiquidFavorite liquidFavorite) async => await favoritesRepository.saveLiquidFavorite(liquidFavorite);

}