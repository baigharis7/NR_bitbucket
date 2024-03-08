import 'package:nutrenaissance_flutter/domain/interactor/recipes/get_recipe_favorites_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';

class GetRecipeFavoritesInteractorImpl extends GetRecipeFavoritesInteractor {
  final RecipesRepository recipesRepository;
  GetRecipeFavoritesInteractorImpl({required this.recipesRepository});

  @override
  Future<List<UploadRecipeFavorite>> execute() => recipesRepository.getRecipeFavorites();
}