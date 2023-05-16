import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/get_food_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class GetFoodFavoritesInteractorImpl extends GetFoodFavoritesInteractor {
  final FavoritesRepository favoritesRepository;

  GetFoodFavoritesInteractorImpl({required this.favoritesRepository});

  @override
  Future<List<FoodFavorite>> execute() async => await favoritesRepository.getFoodFavorites();

}