import 'package:nutrenaissance_flutter/domain/interactor/favorites/liquid/delete_liquid_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class DeleteLiquidFavoriteInteractorImpl extends DeleteLiquidFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  DeleteLiquidFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(String userId, int eventDate) async => await favoritesRepository.deleteFavoriteLiquidFromCloud(userId, eventDate);

}