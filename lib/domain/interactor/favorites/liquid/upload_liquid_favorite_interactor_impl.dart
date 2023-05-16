import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/upload_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/liquid/liquid_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';


class UploadLiquidFavoriteInteractorImpl extends UploadLiquidFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  UploadLiquidFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(LiquidFavorite liquidFavorite) async => await favoritesRepository.uploadLiquidFavorite(liquidFavorite);
}