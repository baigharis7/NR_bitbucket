import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/get_liquid_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class GetLiquidFavoritesInteractorImpl extends GetLiquidFavoritesInteractor {
  final FavoritesRepository favoritesRepository;

  GetLiquidFavoritesInteractorImpl({required this.favoritesRepository});

  @override
  Future<List<LiquidFavorite>> execute() async => await favoritesRepository.getLiquidFavorites();

}