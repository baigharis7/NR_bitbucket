import 'package:nutrenaissance_flutter/domain/interactor/recipes/remove_recipe_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';

class RemoveRecipeFavoriteInteractorImpl extends RemoveRecipeFavoriteInteractor {
  final RecipesRepository recipesRepository;

  RemoveRecipeFavoriteInteractorImpl({required this.recipesRepository});

  @override
  Future<void> execute(UploadRecipeFavorite uploadRecipeFavorite) => recipesRepository.removeRecipeFavorite(uploadRecipeFavorite);

}