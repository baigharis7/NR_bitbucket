import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/remove_liquid_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class RemoveLiquidFavoriteFromLocalInteractorImpl extends RemoveLiquidFavoriteFromLocalInteractor {
  final FavoritesRepository favoritesRepository;

  RemoveLiquidFavoriteFromLocalInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(LiquidFavorite liquidFavorite) async => favoritesRepository.removeLiquidFavoriteFromLocal(liquidFavorite);

}