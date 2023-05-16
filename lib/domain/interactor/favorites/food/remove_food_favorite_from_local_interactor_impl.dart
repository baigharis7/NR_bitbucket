import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/remove_food_favorite_from_local_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class RemoveFoodFavoriteFromLocalInteractorImpl extends RemoveFoodFavoriteFromLocalInteractor {
  final FavoritesRepository favoritesRepository;

  RemoveFoodFavoriteFromLocalInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(FoodFavorite foodFavorite) async => favoritesRepository.removeFoodFavoriteFromLocal(foodFavorite);

}