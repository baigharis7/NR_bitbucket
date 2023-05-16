import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/save_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class SaveFoodFavoriteInteractorImpl extends SaveFoodFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  SaveFoodFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<void> execute(FoodFavorite foodFavorite, bool isEdit) async => await favoritesRepository.saveFoodFavorite(foodFavorite, isEdit);

}