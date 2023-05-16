import 'package:nutrenaissance_flutter/domain/interactor/favorites/food/upload_food_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/favorites/food/food_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/favorites/favorites_repository.dart';

class UploadFoodFavoriteInteractorImpl extends UploadFoodFavoriteInteractor {
  final FavoritesRepository favoritesRepository;

  UploadFoodFavoriteInteractorImpl({required this.favoritesRepository});

  @override
  Future<bool> execute(FoodFavorite foodFavorite) async => await favoritesRepository.uploadFoodFavorite(foodFavorite);
}