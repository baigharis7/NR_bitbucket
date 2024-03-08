import 'package:nutrenaissance_flutter/domain/interactor/recipes/save_recipe_favorite_interactor.dart';
import 'package:nutrenaissance_flutter/domain/models/recipes/upload_recipe_favorite.dart';
import 'package:nutrenaissance_flutter/domain/repository/recipes/recipes_repository.dart';

class SaveRecipeFavoriteInteractorImpl extends SaveRecipeFavoriteInteractor {
  final RecipesRepository recipesRepository;
  SaveRecipeFavoriteInteractorImpl({required this.recipesRepository});

  @override
  Future<void> execute(UploadRecipeFavorite uploadRecipeFavorite) => recipesRepository.saveRecipeFavorite(uploadRecipeFavorite);

}