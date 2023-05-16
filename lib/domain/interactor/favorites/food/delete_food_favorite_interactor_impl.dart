import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/delete_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class DeleteFoodFavoriteInteractorImpl extends DeleteFoodFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  DeleteFoodFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(String userId, int eventDate) async => await favoritesRepository.deleteFavoriteFoodFromCloud(userId, eventDate);

}